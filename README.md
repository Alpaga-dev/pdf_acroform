# pdf_acroform

[![pub package](https://img.shields.io/pub/v/pdf_acroform.svg)](https://pub.dev/packages/pdf_acroform)
[![CI](https://github.com/alpaga-dev/pdf_acroform/actions/workflows/ci.yml/badge.svg)](https://github.com/alpaga-dev/pdf_acroform/actions/workflows/ci.yml)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A Dart/Flutter package for parsing PDF AcroForm fields and displaying interactive form overlays.

## Features

- Parse AcroForm fields from PDF documents
- Extract field metadata: name, type, position, default values
- Support for text fields, checkboxes, dropdowns, and more
- Field properties: multiline, read-only, max length, text alignment
- Flutter widget to display PDF with editable form overlays
- Pure Dart parser (works without Flutter)

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  pdf_acroform:
    git:
      url: https://github.com/alpaga-dev/pdf_acroform.git
```

## Usage

### Parsing PDF form fields (Dart)

```dart
import 'package:pdf_acroform/pdf_acroform.dart';

// Parse a PDF file
final parser = await AcroFormParser.fromFile('form.pdf');
final fields = await parser.extractFields();

// List all fields
for (final field in fields) {
  print('${field.name}: ${field.type}');
}

// Extract pre-filled values as a Map
final formData = fields.extractFormData();
print(formData); // {'firstName': 'John', 'newsletter': true, ...}

// Filter fields
final textFields = fields.ofType(PdfFieldType.text);
final page1Fields = fields.forPage(0);
```

### Displaying PDF with form overlays (Flutter)

```dart
import 'package:pdf_acroform/pdf_acroform.dart';
import 'package:pdf_acroform/pdf_acroform_viewer.dart';

class MyFormScreen extends StatefulWidget {
  @override
  State<MyFormScreen> createState() => _MyFormScreenState();
}

class _MyFormScreenState extends State<MyFormScreen> {
  List<PdfFormField>? _fields;
  Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final parser = await AcroFormParser.fromFile('form.pdf');
    final fields = await parser.extractFields();
    setState(() {
      _fields = fields;
      _formData = fields.extractFormData();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_fields == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return PdfFormViewer(
      pdfPath: 'form.pdf',
      fields: _fields!,
      formData: _formData,
      onFieldChanged: (name, value) {
        setState(() => _formData[name] = value);
      },
    );
  }
}
```

## Supported field types

| Type | Description |
|------|-------------|
| `text` | Single or multiline text input |
| `button` | Checkbox or radio button |
| `choice` | Dropdown or list selection |
| `signature` | Signature field (detected but not editable) |

## Field properties

The parser extracts the following properties when available:

- `name` - Fully qualified field name
- `type` - Field type (text, button, choice, signature)
- `rect` - Position and dimensions on the page
- `pageIndex` - Zero-based page number
- `defaultValue` - Pre-filled value
- `isMultiline` - Whether text field supports multiple lines
- `isReadOnly` - Whether field is editable
- `maxLength` - Maximum character count
- `alignment` - Text alignment (left, center, right)
- `options` - Available choices for dropdown fields

## Example app

See the `example/` directory for a complete demo application.

```bash
cd example
flutter run
```

## License

MIT
