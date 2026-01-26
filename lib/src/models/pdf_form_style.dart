import 'package:flutter/material.dart';

/// Style configuration for PDF form field overlays.
///
/// This class allows customization of the appearance of form fields
/// rendered by [PdfFormViewer].
///
/// Example:
/// ```dart
/// PdfFormStyle(
///   borderRadius: 4,
///   borderColor: Colors.blue,
///   fillColor: Colors.yellow.withOpacity(0.3),
///   textStyle: TextStyle(fontFamily: 'Courier'),
/// )
/// ```
///
/// To use your app's theme, you can extract styles from [ThemeData]:
/// ```dart
/// PdfFormStyle.fromTheme(Theme.of(context))
/// ```
@immutable
class PdfFormStyle {
  /// Creates a [PdfFormStyle] with custom values.
  const PdfFormStyle({
    this.borderRadius = 2,
    this.borderColor,
    this.activeBorderColor,
    this.fillColor,
    this.activeFillColor,
    this.readOnlyFillColor,
    this.textStyle,
    this.readOnlyTextStyle,
    this.cursorColor,
    this.selectionColor,
    this.checkColor,
    this.checkedFillColor,
  });

  /// Creates a [PdfFormStyle] from a [ThemeData].
  ///
  /// This is useful to match the form fields with your app's theme.
  ///
  /// Example:
  /// ```dart
  /// PdfFormViewer(
  ///   // ...
  ///   style: PdfFormStyle.fromTheme(Theme.of(context)),
  /// )
  /// ```
  factory PdfFormStyle.fromTheme(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final inputDecorationTheme = theme.inputDecorationTheme;

    return PdfFormStyle(
      borderRadius: 4,
      borderColor: inputDecorationTheme.border?.borderSide.color ??
          colorScheme.outline.withAlpha(77),
      activeBorderColor: inputDecorationTheme.focusedBorder?.borderSide.color ??
          colorScheme.primary,
      fillColor: inputDecorationTheme.fillColor ??
          colorScheme.surfaceContainerHighest.withAlpha(64),
      activeFillColor: colorScheme.surfaceContainerHighest.withAlpha(128),
      readOnlyFillColor: colorScheme.onSurface.withAlpha(30),
      textStyle: theme.textTheme.bodyMedium,
      readOnlyTextStyle: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withAlpha(153),
      ),
      cursorColor: colorScheme.primary,
      selectionColor: colorScheme.primary.withAlpha(77),
      checkColor: colorScheme.primary,
      checkedFillColor: colorScheme.primary.withAlpha(77),
    );
  }

  /// The border radius of form fields.
  ///
  /// Defaults to 2.
  final double borderRadius;

  /// The border color of form fields.
  ///
  /// Defaults to a semi-transparent blue.
  final Color? borderColor;

  /// The border color when a field is active/focused.
  ///
  /// Defaults to solid blue.
  final Color? activeBorderColor;

  /// The background fill color of form fields.
  ///
  /// Defaults to a semi-transparent yellow.
  final Color? fillColor;

  /// The background fill color when a field is active/focused.
  ///
  /// Defaults to a more opaque yellow.
  final Color? activeFillColor;

  /// The background fill color for read-only fields.
  ///
  /// Defaults to a semi-transparent grey.
  final Color? readOnlyFillColor;

  /// The text style for editable form fields.
  ///
  /// Note: The font size is calculated automatically based on field height,
  /// but can be overridden by specifying it in this style.
  final TextStyle? textStyle;

  /// The text style for read-only form fields.
  ///
  /// If not specified, falls back to [textStyle] with a grey color.
  final TextStyle? readOnlyTextStyle;

  /// The cursor color for text fields.
  ///
  /// Defaults to blue.
  final Color? cursorColor;

  /// The selection highlight color for text fields.
  ///
  /// Defaults to light blue.
  final Color? selectionColor;

  /// The color of the checkmark in checkbox fields.
  ///
  /// Defaults to blue.
  final Color? checkColor;

  /// The background fill color of checked checkbox fields.
  ///
  /// Defaults to semi-transparent blue.
  final Color? checkedFillColor;

  /// Returns the effective border color, using default if not specified.
  Color get effectiveBorderColor => borderColor ?? Colors.indigo.withAlpha(80);

  /// Returns the effective active border color, using default if not specified.
  Color get effectiveActiveBorderColor =>
      activeBorderColor ?? Colors.indigoAccent;

  /// Returns the effective fill color, using default if not specified.
  Color get effectiveFillColor => fillColor ?? Colors.amberAccent.withAlpha(36);

  /// Returns the effective active fill color, using default if not specified.
  Color get effectiveActiveFillColor =>
      activeFillColor ?? Colors.amberAccent.withAlpha(80);

  /// Returns the effective read-only fill color, using default if not specified.
  Color get effectiveReadOnlyFillColor =>
      readOnlyFillColor ?? Colors.grey.withAlpha(64);

  /// Returns the effective cursor color, using default if not specified.
  Color get effectiveCursorColor => cursorColor ?? Colors.indigoAccent;

  /// Returns the effective selection color, using default if not specified.
  Color get effectiveSelectionColor => selectionColor ?? Colors.lightBlueAccent;

  /// Returns the effective check color, using default if not specified.
  Color get effectiveCheckColor => checkColor ?? Colors.indigo;

  /// Returns the effective checked fill color, using default if not specified.
  Color get effectiveCheckedFillColor =>
      checkedFillColor ?? Colors.indigoAccent.withAlpha(50);

  /// Creates a copy of this style with the given fields replaced.
  PdfFormStyle copyWith({
    double? borderRadius,
    Color? borderColor,
    Color? activeBorderColor,
    Color? fillColor,
    Color? activeFillColor,
    Color? readOnlyFillColor,
    TextStyle? textStyle,
    TextStyle? readOnlyTextStyle,
    Color? cursorColor,
    Color? selectionColor,
    Color? checkColor,
    Color? checkedFillColor,
  }) {
    return PdfFormStyle(
      borderRadius: borderRadius ?? this.borderRadius,
      borderColor: borderColor ?? this.borderColor,
      activeBorderColor: activeBorderColor ?? this.activeBorderColor,
      fillColor: fillColor ?? this.fillColor,
      activeFillColor: activeFillColor ?? this.activeFillColor,
      readOnlyFillColor: readOnlyFillColor ?? this.readOnlyFillColor,
      textStyle: textStyle ?? this.textStyle,
      readOnlyTextStyle: readOnlyTextStyle ?? this.readOnlyTextStyle,
      cursorColor: cursorColor ?? this.cursorColor,
      selectionColor: selectionColor ?? this.selectionColor,
      checkColor: checkColor ?? this.checkColor,
      checkedFillColor: checkedFillColor ?? this.checkedFillColor,
    );
  }

  /// Default style with PDF-like appearance.
  static const PdfFormStyle defaultStyle = PdfFormStyle();
}
