/// A Dart library for parsing PDF AcroForm fields.
///
/// This library provides tools to extract form field metadata from PDF
/// documents using the AcroForm standard (ISO 32000).
///
/// ## Features
///
/// - Extract form fields from PDF files
/// - Support for text fields, checkboxes, dropdowns, and more
/// - Access field properties (multiline, read-only, max length, alignment)
/// - Pure Dart implementation (no Flutter dependency)
///
/// ## Usage
///
/// ```dart
/// import 'package:pdf_acroform/pdf_acroform.dart';
///
/// // Parse a PDF file
/// final parser = await AcroFormParser.fromFile('form.pdf');
/// final fields = await parser.extractFields();
///
/// // Access field information
/// for (final field in fields) {
///   print('${field.name}: ${field.type}');
/// }
///
/// // Extract pre-filled form data
/// final formData = fields.extractFormData();
/// ```
///
/// ## See also
///
/// - `pdf_acroform_viewer` library for Flutter widgets to display PDF forms
library;

export 'src/models/models.dart';
export 'src/parser/acroform_parser.dart';
