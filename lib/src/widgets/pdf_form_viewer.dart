import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pdf_acroform/src/models/models.dart';
import 'package:pdf_acroform/src/widgets/fields/fields.dart';
import 'package:pdfrx/pdfrx.dart' as pdfrx;

/// A widget that displays a PDF with interactive form field overlays.
///
/// This widget renders a PDF document and overlays editable form fields
/// at the correct positions based on the [fields] extracted from the PDF.
///
/// The form data is managed externally through [formData] and [onFieldChanged],
/// allowing for flexible state management.
///
/// Example:
/// ```dart
/// PdfFormViewer(
///   pdfPath: '/path/to/form.pdf',
///   fields: extractedFields,
///   formData: {'firstName': 'John', 'newsletter': true},
///   readOnlyFields: {'firstName'}, // These fields will be read-only
///   onFieldChanged: (name, value) {
///     setState(() => formData[name] = value);
///   },
/// )
/// ```
class PdfFormViewer extends StatefulWidget {
  /// Creates a [PdfFormViewer].
  const PdfFormViewer({
    required this.pdfPath,
    required this.fields,
    required this.formData,
    required this.onFieldChanged,
    this.readOnlyFields = const {},
    this.style = PdfFormStyle.defaultStyle,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.pageDropShadow = const BoxShadow(
      color: Colors.black38,
      blurRadius: 5,
      spreadRadius: 0,
      offset: Offset(2, 4),
    ),
    super.key,
  });

  /// The path to the PDF file to display.
  final String pdfPath;

  /// The list of form fields extracted from the PDF.
  ///
  /// Use [AcroFormParser.extractFields] to get this list.
  final List<PdfFormField> fields;

  /// The current form data as a map of field names to values.
  final Map<String, dynamic> formData;

  /// Called when a field value changes.
  ///
  /// The callback receives the field name and the new value.
  final void Function(String fieldName, dynamic value) onFieldChanged;

  /// Set of field names that should be displayed as read-only.
  ///
  /// Fields in this set will be non-editable regardless of their
  /// [PdfFormField.isReadOnly] property.
  final Set<String> readOnlyFields;

  /// Style configuration for form field overlays.
  ///
  /// Controls colors, borders, and text styles of form fields.
  /// By default, uses a PDF-like appearance independent of the app's theme.
  ///
  /// To match your app's theme, use [PdfFormStyle.fromTheme]:
  /// ```dart
  /// PdfFormViewer(
  ///   // ...
  ///   style: PdfFormStyle.fromTheme(Theme.of(context)),
  /// )
  /// ```
  final PdfFormStyle style;

  /// The background color of the PDF viewer.
  ///
  /// If null, defaults to grey.
  final Color? backgroundColor;

  /// The drop shadow for PDF pages.
  ///
  /// Defaults to the pdfrx default shadow.
  /// Set to `BoxShadow()` with no parameters to remove the shadow.
  final BoxShadow pageDropShadow;

  @override
  State<PdfFormViewer> createState() => _PdfFormViewerState();
}

class _PdfFormViewerState extends State<PdfFormViewer> {
  final _pdfController = pdfrx.PdfViewerController();
  pdfrx.PdfDocument? _document;

  late Map<int, List<PdfFormField>> _fieldsByPage;

  static const double _zoomStep = 0.25;
  static const double _minZoom = 0.5;
  static const double _maxZoom = 4;

  /// Scrolls the PDF viewer to make the given field visible.
  void _scrollToField(PdfFormField field) {
    if (_document == null) return;

    // Add a small delay to let the keyboard start appearing
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      try {
        // Create a rect for the field
        // PDF coordinates have origin at bottom-left
        final fieldRect = pdfrx.PdfRect(
          field.rect.left,
          field.rect.bottom,
          field.rect.right,
          field.rect.top,
        );

        final calculatedRect = _pdfController.calcRectForRectInsidePage(
          pageNumber: field.pageIndex + 1,
          rect: fieldRect,
        );

        // Normalize the rect (PDF coords have inverted Y axis)
        final targetRect = Rect.fromLTRB(
          calculatedRect.left,
          calculatedRect.top < calculatedRect.bottom ? calculatedRect.top : calculatedRect.bottom,
          calculatedRect.right,
          calculatedRect.top > calculatedRect.bottom ? calculatedRect.top : calculatedRect.bottom,
        );

        // Use ensureVisible to scroll the field into view
        unawaited(
          _pdfController.ensureVisible(
            targetRect,
            margin: 50,
            duration: const Duration(milliseconds: 200),
          ),
        );
      } on Exception catch (e) {
        debugPrint('Error scrolling to field: $e');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _buildFieldsCache();
    unawaited(_loadDocument());
  }

  @override
  void didUpdateWidget(covariant PdfFormViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fields != oldWidget.fields) {
      _buildFieldsCache();
    }
    if (widget.pdfPath != oldWidget.pdfPath) {
      unawaited(_loadDocument());
    }
  }

  void _buildFieldsCache() {
    _fieldsByPage = {};
    for (final field in widget.fields) {
      _fieldsByPage.putIfAbsent(field.pageIndex, () => []).add(field);
    }
  }

  Future<void> _loadDocument() async {
    try {
      final doc = await pdfrx.PdfDocument.openFile(widget.pdfPath);
      if (mounted) setState(() => _document = doc);
    } on Exception catch (e) {
      debugPrint('Error loading PDF document: $e');
    }
  }

  void _zoomIn() {
    final currentZoom = _pdfController.currentZoom;
    final newZoom = (currentZoom + _zoomStep).clamp(_minZoom, _maxZoom);
    unawaited(_pdfController.setZoom(_pdfController.centerPosition, newZoom));
  }

  void _zoomOut() {
    final currentZoom = _pdfController.currentZoom;
    final newZoom = (currentZoom - _zoomStep).clamp(_minZoom, _maxZoom);
    unawaited(_pdfController.setZoom(_pdfController.centerPosition, newZoom));
  }

  void _resetZoom() {
    unawaited(_pdfController.setZoom(_pdfController.centerPosition, 1));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        pdfrx.PdfViewer.file(
          widget.pdfPath,
          controller: _pdfController,
          params: pdfrx.PdfViewerParams(
            backgroundColor: widget.backgroundColor ?? Colors.grey,
            pageDropShadow: widget.pageDropShadow,
            enableTextSelection: false,
            annotationRenderingMode: pdfrx.PdfAnnotationRenderingMode.annotation,
            pageOverlaysBuilder: (context, pageRect, page) {
              return [
                _buildFieldsOverlay(pageRect, page.pageNumber),
              ];
            },
          ),
        ),
        Positioned(
          right: 16,
          top: 16,
          child: Column(
            children: [
              _ZoomButton(
                icon: Icons.add,
                onPressed: _zoomIn,
                tooltip: 'Zoom in',
              ),
              const SizedBox(height: 8),
              _ZoomButton(
                icon: Icons.remove,
                onPressed: _zoomOut,
                tooltip: 'Zoom out',
              ),
              const SizedBox(height: 8),
              _ZoomButton(
                icon: Icons.fit_screen,
                onPressed: _resetZoom,
                tooltip: 'Reset zoom',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFieldsOverlay(Rect pageRect, int pageNumber) {
    if (_document == null) return const SizedBox.shrink();

    final pageFields = _fieldsByPage[pageNumber - 1];
    if (pageFields == null || pageFields.isEmpty) {
      return const SizedBox.shrink();
    }

    final page = _document!.pages[pageNumber - 1];
    final pdfWidth = page.width;
    final pdfHeight = page.height;

    final scaleX = pageRect.width / pdfWidth;
    final scaleY = pageRect.height / pdfHeight;

    return Stack(
      children: [
        for (final field in pageFields)
          _PositionedField(
            field: field,
            scaleX: scaleX,
            scaleY: scaleY,
            pageHeight: pageRect.height,
            value: widget.formData[field.name],
            onChanged: (v) => widget.onFieldChanged(field.name, v),
            isReadOnly: field.isReadOnly || widget.readOnlyFields.contains(field.name),
            style: widget.style,
            onFocused: () => _scrollToField(field),
          ),
      ],
    );
  }
}

/// Internal widget that positions a form field overlay.
class _PositionedField extends StatelessWidget {
  const _PositionedField({
    required this.field,
    required this.scaleX,
    required this.scaleY,
    required this.pageHeight,
    required this.value,
    required this.onChanged,
    required this.isReadOnly,
    required this.style,
    this.onFocused,
  });

  final PdfFormField field;
  final double scaleX;
  final double scaleY;
  final double pageHeight;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final bool isReadOnly;
  final PdfFormStyle style;
  final VoidCallback? onFocused;

  @override
  Widget build(BuildContext context) {
    final left = field.rect.left * scaleX;
    final bottom = field.rect.bottom * scaleY;
    final width = field.rect.width * scaleX;
    final height = field.rect.height * scaleY;
    final top = pageHeight - bottom - height;

    final referenceHeight = field.isMultiline
        ? (field.rect.height / (field.rect.height / 12).ceil()) // divise en lignes de ~12pt
        : field.rect.height;
    final fontSize = (referenceHeight * scaleY * 0.65).clamp(1.0, 320.0);

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: RepaintBoundary(
        child: _buildFieldWidget(fontSize, height),
      ),
    );
  }

  Widget _buildFieldWidget(double fontSize, double fieldHeight) {
    final textStyle = style.textStyle != null
        ? style.textStyle!.copyWith(fontSize: fontSize, height: 1)
        : TextStyle(fontSize: fontSize, height: 1);

    final readOnlyTextStyle = style.textStyle != null
        ? style.readOnlyTextStyle!.copyWith(fontSize: fontSize, height: 1)
        : TextStyle(fontSize: fontSize, height: 1);

    final pdfFormStyle = style.copyWith(textStyle: textStyle, readOnlyTextStyle: readOnlyTextStyle);

    switch (field.type) {
      case PdfFieldType.button:
        return CheckboxField(
          value: value == true || value == 'Yes' || value == '/Yes',
          onChanged: isReadOnly ? null : onChanged,
          style: pdfFormStyle,
        );

      case PdfFieldType.choice:
        if (field.options != null && field.options!.isNotEmpty) {
          return DropdownFieldOverlay(
            value: value?.toString(),
            options: field.options!,
            onChanged: isReadOnly ? null : onChanged,
            fontSize: fontSize,
            fieldHeight: fieldHeight,
            alignment: field.alignment,
            style: pdfFormStyle,
          );
        }
        return TextFieldOverlay(
          value: value?.toString() ?? '',
          onChanged: onChanged,
          fontSize: fontSize,
          fieldHeight: fieldHeight,
          isMultiline: field.isMultiline,
          isReadOnly: isReadOnly,
          maxLength: field.maxLength,
          alignment: field.alignment,
          style: pdfFormStyle,
          onFocused: onFocused,
        );

      case PdfFieldType.text:
      case PdfFieldType.signature:
      case PdfFieldType.unknown:
        return TextFieldOverlay(
          value: value?.toString() ?? '',
          onChanged: onChanged,
          fontSize: fontSize,
          fieldHeight: fieldHeight,
          isMultiline: field.isMultiline,
          isReadOnly: isReadOnly,
          maxLength: field.maxLength,
          alignment: field.alignment,
          style: pdfFormStyle,
          onFocused: onFocused,
        );
    }
  }
}

/// A circular button for zoom controls.
class _ZoomButton extends StatelessWidget {
  const _ZoomButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20),
          ),
        ),
      ),
    );
  }
}
