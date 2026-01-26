/// Flutter widgets for displaying PDF forms with interactive overlays.
///
/// This library provides the [PdfFormViewer] widget that renders a PDF
/// document with editable form field overlays positioned correctly
/// based on AcroForm field coordinates.
///
/// ## Features
///
/// - Display PDF with form field overlays
/// - Interactive text fields, checkboxes, and dropdowns
/// - Zoom controls
/// - Support for field properties (multiline, read-only, alignment, etc.)
///
/// ## Usage
///
/// ```dart
/// import 'package:pdf_acroform/pdf_acroform.dart';
/// import 'package:pdf_acroform/pdf_acroform_viewer.dart';
///
/// // First, parse the PDF to get fields
/// final parser = await AcroFormParser.fromFile('form.pdf');
/// final fields = await parser.extractFields();
///
/// // Then display with the viewer
/// PdfFormViewer(
///   pdfPath: 'form.pdf',
///   fields: fields,
///   formData: formData,
///   onFieldChanged: (name, value) {
///     setState(() => formData[name] = value);
///   },
/// )
/// ```
///
/// ## Dependencies
///
/// This library requires Flutter and the `pdfrx` package for PDF rendering.
library;

export 'src/widgets/fields/fields.dart';
export 'src/widgets/pdf_form_viewer.dart';
