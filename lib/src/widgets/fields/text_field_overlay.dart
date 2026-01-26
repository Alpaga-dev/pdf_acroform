import 'package:flutter/material.dart';
import 'package:pdf_acroform/src/models/models.dart';

/// A text field overlay widget for PDF form text fields.
///
/// Displays as static text by default, and switches to an editable
/// [TextField] when tapped. Supports multiline text, read-only mode,
/// max length, and text alignment.
class TextFieldOverlay extends StatefulWidget {
  /// Creates a [TextFieldOverlay].
  const TextFieldOverlay({
    required this.value,
    required this.onChanged,
    required this.fontSize,
    required this.fieldHeight,
    required this.style,
    super.key,
    this.isMultiline = false,
    this.isReadOnly = false,
    this.maxLength,
    this.alignment = PdfTextAlignment.left,
    this.onFocused,
  });

  /// The current text value.
  final String value;

  /// Called when the text value changes.
  final ValueChanged<String> onChanged;

  /// The font size in logical pixels.
  final double fontSize;

  /// The field height, used for padding calculations.
  final double fieldHeight;

  /// Whether this field supports multiple lines.
  final bool isMultiline;

  /// Whether this field is read-only.
  final bool isReadOnly;

  /// The maximum number of characters allowed.
  final int? maxLength;

  /// The text alignment.
  final PdfTextAlignment alignment;

  /// The style configuration for this field.
  final PdfFormStyle style;

  /// Called when the field receives focus.
  final VoidCallback? onFocused;

  @override
  State<TextFieldOverlay> createState() => _TextFieldOverlayState();
}

class _TextFieldOverlayState extends State<TextFieldOverlay> {
  TextEditingController? _controller;
  bool _isEditing = false;
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    if (widget.isReadOnly) return;
    _controller ??= TextEditingController();
    _controller!.text = widget.value;
    setState(() => _isEditing = true);
    widget.onFocused?.call();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _stopEditing() {
    setState(() => _isEditing = false);
  }

  TextAlign get _textAlign {
    switch (widget.alignment) {
      case PdfTextAlignment.center:
        return TextAlign.center;
      case PdfTextAlignment.right:
        return TextAlign.right;
      case PdfTextAlignment.left:
        return TextAlign.left;
    }
  }

  Alignment get _containerAlignment {
    if (widget.isMultiline) {
      switch (widget.alignment) {
        case PdfTextAlignment.center:
          return Alignment.topCenter;
        case PdfTextAlignment.right:
          return Alignment.topRight;
        case PdfTextAlignment.left:
          return Alignment.topLeft;
      }
    }
    switch (widget.alignment) {
      case PdfTextAlignment.center:
        return Alignment.center;
      case PdfTextAlignment.right:
        return Alignment.centerRight;
      case PdfTextAlignment.left:
        return Alignment.centerLeft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = (widget.fieldHeight * 0.1).clamp(2.0, 8.0);
    final verticalPadding = (widget.fieldHeight * 0.05).clamp(1.0, 4.0);
    final style = widget.style;

    return GestureDetector(
      onTap: _isEditing ? null : _startEditing,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isReadOnly
              ? style.effectiveReadOnlyFillColor
              : _isEditing
                  ? style.effectiveActiveFillColor
                  : style.effectiveFillColor,
          border: Border.all(
            color: _isEditing
                ? style.effectiveActiveBorderColor
                : style.effectiveBorderColor,
          ),
          borderRadius: BorderRadius.circular(style.borderRadius),
        ),
        clipBehavior: Clip.none,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: _isEditing ? _buildTextField() : _buildText(),
      ),
    );
  }

  TextStyle get _defaultTextStyle => TextStyle(
        fontSize: widget.fontSize,
        height: 1.2,
        color: Colors.black,
        fontWeight: FontWeight.normal,
        fontStyle: FontStyle.normal,
        decoration: TextDecoration.none,
      );

  TextStyle get _effectiveTextStyle {
    final baseStyle = widget.isReadOnly
        ? (widget.style.readOnlyTextStyle ?? widget.style.textStyle)
        : widget.style.textStyle;
    if (baseStyle != null) {
      return _defaultTextStyle.merge(baseStyle);
    }
    return _defaultTextStyle;
  }

  TextStyle get _effectiveReadOnlyTextStyle {
    final baseStyle = widget.style.readOnlyTextStyle ?? widget.style.textStyle;
    final defaultReadOnly = _defaultTextStyle.copyWith(color: Colors.grey[700]);
    if (baseStyle != null) {
      return defaultReadOnly.merge(baseStyle);
    }
    return defaultReadOnly;
  }

  Widget _buildText() {
    final textStyle =
        widget.isReadOnly ? _effectiveReadOnlyTextStyle : _effectiveTextStyle;
    return Align(
      alignment: _containerAlignment,
      child: Text(
        widget.value,
        style: textStyle,
        textAlign: _textAlign,
        maxLines: widget.isMultiline ? null : 1,
        overflow: TextOverflow.clip,
      ),
    );
  }

  Widget _buildTextField() {
    final style = widget.style;
    // Wrap in Theme to isolate from app theme
    return Theme(
      data: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: style.effectiveCursorColor,
          selectionColor: style.effectiveSelectionColor,
          selectionHandleColor: style.effectiveCursorColor,
        ),
      ),
      child: Align(
        alignment: _containerAlignment,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          onEditingComplete: widget.isMultiline ? null : _stopEditing,
          onTapOutside: (_) => _stopEditing(),
          style: _effectiveTextStyle,
          cursorColor: style.effectiveCursorColor,
          maxLines: widget.isMultiline ? null : 1,
          maxLength: widget.maxLength,
          textAlign: _textAlign,
          textAlignVertical: TextAlignVertical.top,
          scrollPadding: EdgeInsets.zero,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            counterText: '',
          ),
        ),
      ),
    );
  }
}
