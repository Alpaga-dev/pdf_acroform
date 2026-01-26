import 'package:meta/meta.dart';
import 'package:pdf_acroform/src/models/enums.dart';
import 'package:pdf_acroform/src/models/pdf_rect.dart';

/// Represents a single form field extracted from a PDF AcroForm.
///
/// This class contains all the metadata needed to render and interact
/// with a PDF form field, including its position, type, and various
/// properties that affect its behavior and appearance.
///
/// Example:
/// ```dart
/// final field = PdfFormField(
///   name: 'firstName',
///   type: PdfFieldType.text,
///   rect: PdfRect(100, 700, 300, 720),
///   pageIndex: 0,
/// );
/// ```
@immutable
class PdfFormField {
  /// Creates a [PdfFormField] with the given properties.
  const PdfFormField({
    required this.name,
    required this.type,
    required this.rect,
    required this.pageIndex,
    this.defaultValue,
    this.isMultiline = false,
    this.isReadOnly = false,
    this.maxLength,
    this.alignment = PdfTextAlignment.left,
    this.options,
    this.isCombo = true,
  });

  /// Creates a [PdfFormField] from a JSON map.
  factory PdfFormField.fromJson(Map<String, dynamic> json) {
    return PdfFormField(
      name: json['name'] as String,
      type: PdfFieldType.values.byName(json['type'] as String),
      rect: PdfRect.fromJson(json['rect'] as Map<String, dynamic>),
      pageIndex: json['pageIndex'] as int,
      defaultValue: json['defaultValue'] as String?,
      isMultiline: json['isMultiline'] as bool? ?? false,
      isReadOnly: json['isReadOnly'] as bool? ?? false,
      maxLength: json['maxLength'] as int?,
      alignment: json['alignment'] != null
          ? PdfTextAlignment.values.byName(json['alignment'] as String)
          : PdfTextAlignment.left,
      options: (json['options'] as List<dynamic>?)?.cast<String>(),
      isCombo: json['isCombo'] as bool? ?? true,
    );
  }

  /// The fully qualified field name.
  ///
  /// For nested fields, this includes the parent names separated by dots.
  /// Example: `"person.address.street"`.
  final String name;

  /// The type of form field.
  final PdfFieldType type;

  /// The rectangle defining the field's position on the page.
  ///
  /// Coordinates are in PDF points with origin at bottom-left.
  final PdfRect rect;

  /// The zero-based index of the page containing this field.
  final int pageIndex;

  /// The default/initial value of the field, if any.
  ///
  /// For text fields, this is the pre-filled text.
  /// For checkboxes, this is typically "Yes", "Off", or similar.
  final String? defaultValue;

  /// Whether this is a multi-line text field.
  ///
  /// Only applicable to [PdfFieldType.text] fields.
  /// Corresponds to the Multiline flag (bit 13) in `/Ff`.
  final bool isMultiline;

  /// Whether this field is read-only.
  ///
  /// Read-only fields cannot be modified by the user.
  /// Corresponds to the ReadOnly flag (bit 1) in `/Ff`.
  final bool isReadOnly;

  /// The maximum length of text allowed in this field.
  ///
  /// Only applicable to [PdfFieldType.text] fields.
  /// `null` means no limit. Corresponds to `/MaxLen`.
  final int? maxLength;

  /// The text alignment for this field.
  ///
  /// Corresponds to the `/Q` entry.
  final PdfTextAlignment alignment;

  /// The list of options for choice fields.
  ///
  /// Only applicable to [PdfFieldType.choice] fields.
  /// Corresponds to the `/Opt` entry.
  final List<String>? options;

  /// Whether this choice field is a combo box (dropdown).
  ///
  /// Only applicable to [PdfFieldType.choice] fields.
  /// - `true`: Combo box (dropdown) - user can only select from options
  /// - `false`: List box - displays multiple options at once
  ///
  /// Corresponds to the Combo flag (bit 18) in `/Ff`.
  final bool isCombo;

  /// Returns the form value, with type conversion for checkboxes.
  ///
  /// For [PdfFieldType.button] fields (checkboxes), converts string values
  /// like "Yes", "On", "1" to `true`, and "Off", "No", "0" to `false`.
  ///
  /// For other field types, returns the [defaultValue] as-is.
  ///
  /// Returns `null` if [defaultValue] is null or empty.
  dynamic get formValue {
    if (defaultValue == null || defaultValue!.isEmpty) return null;

    if (type == PdfFieldType.button) {
      final val = defaultValue!.toLowerCase();
      return val != 'off' && val != 'no' && val != '0';
    }

    return defaultValue;
  }

  /// Converts this field to a JSON-serializable map.
  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type.name,
        'rect': rect.toJson(),
        'pageIndex': pageIndex,
        if (defaultValue != null) 'defaultValue': defaultValue,
        if (isMultiline) 'isMultiline': isMultiline,
        if (isReadOnly) 'isReadOnly': isReadOnly,
        if (maxLength != null) 'maxLength': maxLength,
        if (alignment != PdfTextAlignment.left) 'alignment': alignment.name,
        if (options != null) 'options': options,
        if (!isCombo) 'isCombo': isCombo,
      };

  @override
  String toString() =>
      'PdfFormField(name: $name, type: $type, page: $pageIndex)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfFormField &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type &&
          rect == other.rect &&
          pageIndex == other.pageIndex;

  @override
  int get hashCode => Object.hash(name, type, rect, pageIndex);
}

/// Extension methods for lists of [PdfFormField].
extension PdfFormFieldListExtension on List<PdfFormField> {
  /// Extracts all field values as a Map suitable for form data.
  ///
  /// Only includes fields that have a non-empty value.
  ///
  /// Set [includeOffCheckboxes] to `true` to include checkboxes
  /// with value `false`. Defaults to `false`, which skips unchecked
  /// checkboxes.
  ///
  /// Returns a map where keys are field names and values are the field values.
  ///
  /// Example:
  /// ```dart
  /// final fields = await parser.extractFields();
  /// final formData = fields.extractFormData();
  /// print(formData); // {'firstName': 'John', 'newsletter': true}
  /// ```
  Map<String, dynamic> extractFormData({bool includeOffCheckboxes = false}) {
    final data = <String, dynamic>{};

    for (final field in this) {
      final value = field.formValue;
      if (value == null) continue;

      // Skip "Off" checkboxes unless explicitly requested
      final isOffCheckbox = field.type == PdfFieldType.button && value == false;
      if (!includeOffCheckboxes && isOffCheckbox) {
        continue;
      }

      data[field.name] = value;
    }

    return data;
  }

  /// Returns fields filtered by page index.
  ///
  /// Example:
  /// ```dart
  /// final page1Fields = fields.forPage(0);
  /// ```
  List<PdfFormField> forPage(int pageIndex) {
    return where((f) => f.pageIndex == pageIndex).toList();
  }

  /// Returns fields filtered by type.
  ///
  /// Example:
  /// ```dart
  /// final textFields = fields.ofType(PdfFieldType.text);
  /// ```
  List<PdfFormField> ofType(PdfFieldType type) {
    return where((f) => f.type == type).toList();
  }
}
