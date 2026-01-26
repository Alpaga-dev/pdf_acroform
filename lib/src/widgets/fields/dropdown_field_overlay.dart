import 'package:flutter/material.dart';
import 'package:pdf_acroform/src/models/models.dart';

/// A dropdown overlay widget for PDF form choice fields.
///
/// Displays a dropdown button that allows selecting from a list of options.
/// Supports read-only mode and text alignment.
class DropdownFieldOverlay extends StatelessWidget {
  /// Creates a [DropdownFieldOverlay].
  const DropdownFieldOverlay({
    required this.value,
    required this.options,
    required this.onChanged,
    required this.fontSize,
    required this.fieldHeight,
    super.key,
    this.alignment = PdfTextAlignment.left,
  });

  /// The currently selected value.
  final String? value;

  /// The list of available options.
  final List<String> options;

  /// Called when the selection changes.
  ///
  /// If null, the dropdown is read-only.
  final ValueChanged<String>? onChanged;

  /// The font size in logical pixels.
  final double fontSize;

  /// The field height, used for padding calculations.
  final double fieldHeight;

  /// The text alignment.
  final PdfTextAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = (fieldHeight * 0.1).clamp(2.0, 8.0);
    final isReadOnly = onChanged == null;

    return Container(
      decoration: BoxDecoration(
        color: isReadOnly
            ? Colors.grey.withAlpha(64)
            : Colors.yellow.withAlpha(64),
        border: Border.all(color: Colors.blue.withAlpha(77)),
        borderRadius: BorderRadius.circular(2),
      ),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(value) ? value : null,
          isExpanded: true,
          isDense: true,
          icon: Icon(Icons.arrow_drop_down, size: fontSize * 1.2),
          style: TextStyle(
            fontSize: fontSize,
            color: isReadOnly ? Colors.grey[700] : Colors.black,
            height: 1.2,
          ),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: TextStyle(fontSize: fontSize),
              ),
            );
          }).toList(),
          onChanged: isReadOnly ? null : (v) => onChanged?.call(v ?? ''),
          hint: Text(
            value ?? '',
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
