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
  pdf_acroform: ^0.4.0
```

Then run:

```bash
flutter pub get
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
      readOnlyFields: {'signatureDate', 'referenceNumber'}, // Optional
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

## PdfFormViewer options

| Parameter | Type | Description |
|-----------|------|-------------|
| `pdfPath` | `String` | Path to the PDF file |
| `fields` | `List<PdfFormField>` | Fields extracted from the PDF |
| `formData` | `Map<String, dynamic>` | Current form values |
| `onFieldChanged` | `Function(String, dynamic)` | Callback when a field value changes |
| `readOnlyFields` | `Set<String>` | Field names to display as read-only (optional) |
| `style` | `PdfFormStyle` | Style configuration for form fields (optional) |
| `backgroundColor` | `Color?` | Background color of the PDF viewer (default: grey) |
| `pageDropShadow` | `BoxShadow` | Drop shadow for PDF pages (optional) |

The `readOnlyFields` parameter allows you to make specific fields non-editable at runtime, regardless of their read-only status in the PDF. This is useful for:
- Locking pre-filled fields that shouldn't be modified
- Implementing role-based field permissions
- Creating partial preview modes

## Styling form fields

By default, form fields use a PDF-like appearance (yellow background, blue borders) that is independent of your app's theme. You can customize the appearance using `PdfFormStyle`.

### Using your app's theme

To match form fields with your app's theme, use `PdfFormStyle.fromTheme()`:

```dart
PdfFormViewer(
  pdfPath: 'form.pdf',
  fields: _fields!,
  formData: _formData,
  style: PdfFormStyle.fromTheme(Theme.of(context)),
  onFieldChanged: (name, value) {
    setState(() => _formData[name] = value);
  },
)
```

### Custom styling

For fine-grained control, create a custom `PdfFormStyle`:

```dart
PdfFormViewer(
  pdfPath: 'form.pdf',
  fields: _fields!,
  formData: _formData,
  style: PdfFormStyle(
    borderRadius: 4,
    borderColor: Colors.grey,
    activeBorderColor: Colors.blue,
    fillColor: Colors.white,
    activeFillColor: Colors.blue.withOpacity(0.1),
    readOnlyFillColor: Colors.grey.withOpacity(0.2),
    textStyle: TextStyle(fontFamily: 'Roboto'),
    cursorColor: Colors.blue,
  ),
  onFieldChanged: (name, value) {
    setState(() => _formData[name] = value);
  },
)
```

### PdfFormStyle properties

| Property | Type | Description |
|----------|------|-------------|
| `borderRadius` | `double` | Corner radius of form fields (default: 2) |
| `borderColor` | `Color?` | Border color (default: semi-transparent blue) |
| `activeBorderColor` | `Color?` | Border color when focused (default: blue) |
| `fillColor` | `Color?` | Background color (default: semi-transparent yellow) |
| `activeFillColor` | `Color?` | Background when focused (default: more opaque yellow) |
| `readOnlyFillColor` | `Color?` | Background for read-only fields (default: grey) |
| `textStyle` | `TextStyle?` | Text style for editable fields |
| `readOnlyTextStyle` | `TextStyle?` | Text style for read-only fields |
| `cursorColor` | `Color?` | Cursor color (default: blue) |
| `selectionColor` | `Color?` | Text selection color (default: light blue) |
| `checkColor` | `Color?` | Checkmark color in checkboxes (default: blue) |
| `checkedFillColor` | `Color?` | Background color for checked checkboxes (default: semi-transparent blue) |

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

## Troubleshooting

### Unwanted scroll when focusing text fields

When tapping on a text field, you may experience unwanted scrolling behavior as the keyboard appears. This is caused by Flutter's default behavior of resizing the scaffold body to accommodate the keyboard.

To fix this, set `resizeToAvoidBottomInset: false` on your `Scaffold`:

```dart
Scaffold(
  resizeToAvoidBottomInset: false,
  body: PdfFormViewer(
    // ...
  ),
)
```

Similarly, if your widget tree includes a `SafeArea`, it may also cause unexpected scroll behavior. Consider removing it or adjusting your layout accordingly.

## Example app

See the `example/` directory for a complete demo application.

```bash
cd example
flutter run
```

## License

MIT
