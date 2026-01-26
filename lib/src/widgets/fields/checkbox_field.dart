import 'package:flutter/material.dart';
import 'package:pdf_acroform/src/models/pdf_form_style.dart';

/// A checkbox overlay widget for PDF form button fields.
///
/// Displays a checkmark when checked, with visual feedback on tap.
/// Supports read-only mode when [onChanged] is null.
class CheckboxField extends StatelessWidget {
  /// Creates a [CheckboxField].
  const CheckboxField({
    required this.value,
    required this.onChanged,
    required this.style,
    super.key,
  });

  /// Whether the checkbox is currently checked.
  final bool value;

  /// Called when the checkbox is tapped.
  ///
  /// If null, the checkbox is read-only.
  final ValueChanged<bool>? onChanged;

  /// The style configuration for this field.
  final PdfFormStyle style;

  @override
  Widget build(BuildContext context) {
    final isReadOnly = onChanged == null;
    final checkmarkColor = isReadOnly ? Colors.grey : style.effectiveCheckColor;

    return GestureDetector(
      onTap: isReadOnly ? null : () => onChanged!(!value),
      child: Container(
        decoration: BoxDecoration(
          color: isReadOnly
              ? style.effectiveReadOnlyFillColor
              : value
                  ? style.effectiveCheckedFillColor
                  : style.effectiveFillColor,
          border: Border.all(color: style.effectiveBorderColor),
          borderRadius: BorderRadius.circular(style.borderRadius),
        ),
        child: value
            ? CustomPaint(
                painter: _CheckmarkPainter(color: checkmarkColor),
                size: Size.infinite,
              )
            : null,
      ),
    );
  }
}

/// Custom painter for rendering a checkmark.
class _CheckmarkPainter extends CustomPainter {
  _CheckmarkPainter({this.color = Colors.blue});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5)
      ..lineTo(size.width * 0.4, size.height * 0.7)
      ..lineTo(size.width * 0.8, size.height * 0.3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) =>
      color != oldDelegate.color;
}
