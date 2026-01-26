import 'dart:io';
import 'dart:typed_data';

import 'package:dart_pdf_reader/dart_pdf_reader.dart';
import 'package:pdf_acroform/src/models/models.dart';

/// Parser for extracting AcroForm fields from PDF documents.
///
/// AcroForm is the standard format for interactive forms in PDF documents,
/// as defined in the PDF specification (ISO 32000).
///
/// This parser extracts form field metadata including:
/// - Field names and types
/// - Position and dimensions
/// - Default values
/// - Field properties (multiline, read-only, max length, etc.)
/// - Choice field options
///
/// Example usage:
/// ```dart
/// // From file
/// final parser = await AcroFormParser.fromFile('form.pdf');
/// final fields = await parser.extractFields();
///
/// // From bytes
/// final bytes = await File('form.pdf').readAsBytes();
/// final parser = await AcroFormParser.fromBytes(bytes);
/// final fields = await parser.extractFields();
///
/// // Extract form data
/// final formData = fields.extractFormData();
/// ```
class AcroFormParser {
  AcroFormParser._(this._document);

  final PDFDocument _document;
  final Map<int, int> _pageObjectIdToIndex = {};

  /// Creates a parser from PDF file bytes.
  ///
  /// Throws if the bytes don't represent a valid PDF document.
  ///
  /// Example:
  /// ```dart
  /// final bytes = await File('form.pdf').readAsBytes();
  /// final parser = await AcroFormParser.fromBytes(bytes);
  /// ```
  static Future<AcroFormParser> fromBytes(Uint8List bytes) async {
    final stream = ByteStream(bytes);
    final document = await PDFParser(stream).parse();
    return AcroFormParser._(document);
  }

  /// Creates a parser from a PDF file path.
  ///
  /// Throws if the file doesn't exist or isn't a valid PDF.
  ///
  /// Example:
  /// ```dart
  /// final parser = await AcroFormParser.fromFile('form.pdf');
  /// ```
  static Future<AcroFormParser> fromFile(String path) async {
    final bytes = await File(path).readAsBytes();
    return fromBytes(bytes);
  }

  /// Extracts all form fields from the PDF.
  ///
  /// Returns an empty list if the PDF has no AcroForm or no fields.
  ///
  /// The returned fields contain all metadata needed to render
  /// interactive form overlays or process form data.
  ///
  /// Example:
  /// ```dart
  /// final fields = await parser.extractFields();
  /// for (final field in fields) {
  ///   print('${field.name}: ${field.type}');
  /// }
  /// ```
  Future<List<PdfFormField>> extractFields() async {
    final fields = <PdfFormField>[];

    try {
      await _buildPageIndex();

      final catalog = await _document.catalog;
      final catalogDict = catalog.dictionary;

      // Get AcroForm dictionary
      final acroFormRef = catalogDict[const PDFName('AcroForm')];
      if (acroFormRef == null) {
        return fields; // No AcroForm in this PDF
      }

      final acroForm = await _resolve(acroFormRef);
      if (acroForm is! PDFDictionary) {
        return fields;
      }

      // Get Fields array
      final fieldsRef = acroForm[const PDFName('Fields')];
      if (fieldsRef == null) {
        return fields;
      }

      final fieldsArray = await _resolve(fieldsRef);
      if (fieldsArray is! PDFArray) {
        return fields;
      }

      // Parse each field recursively
      for (final fieldRef in fieldsArray) {
        await _parseField(fieldRef, fields, '');
      }
    } on Exception catch (e) {
      // Log error but don't throw - return partial results
      // ignore: avoid_print
      print('Error parsing AcroForm: $e');
    }

    return fields;
  }

  /// Builds a mapping from page object IDs to page indices.
  Future<void> _buildPageIndex() async {
    final catalog = await _document.catalog;
    final pages = await catalog.getPages();

    for (var i = 0; i < pages.pageCount; i++) {
      final page = pages.getPageAtIndex(i);
      _pageObjectIdToIndex[identityHashCode(page.dictionary)] = i;
    }
  }

  /// Recursively parses a field and its children.
  Future<void> _parseField(
    PDFObject fieldRef,
    List<PdfFormField> results,
    String parentName,
  ) async {
    final field = await _resolve(fieldRef);
    if (field is! PDFDictionary) return;

    // Get field name from /T entry
    String? localName;
    final tValue = field[const PDFName('T')];
    if (tValue != null) {
      final resolved = await _resolve(tValue);
      if (resolved is PDFStringLike) {
        localName = resolved.asString();
      }
    }

    // Build fully qualified name
    final fullName = parentName.isEmpty
        ? (localName ?? '')
        : localName != null
            ? '$parentName.$localName'
            : parentName;

    // Check for Kids (nested fields)
    final kidsRef = field[const PDFName('Kids')];
    if (kidsRef != null) {
      final kids = await _resolve(kidsRef);
      if (kids is PDFArray) {
        for (final kid in kids) {
          await _parseField(kid, results, fullName);
        }
      }
    }

    // Extract field info if it has a Rect (widget annotation)
    final rectRef = field[const PDFName('Rect')];
    if (rectRef != null && fullName.isNotEmpty) {
      final rect = await _parseRect(rectRef);
      if (rect != null) {
        final type = await _parseFieldType(field);
        final defaultValue = await _parseDefaultValue(field);
        final pageIndex = await _getPageIndex(field);
        final flags = await _parseFieldFlags(field);
        final maxLength = await _parseMaxLength(field);
        final alignment = await _parseAlignment(field);
        final options =
            type == PdfFieldType.choice ? await _parseOptions(field) : null;

        results.add(
          PdfFormField(
            name: fullName,
            type: type,
            rect: rect,
            pageIndex: pageIndex,
            defaultValue: defaultValue,
            isMultiline: type == PdfFieldType.text && _isMultiline(flags),
            isReadOnly: _isReadOnly(flags),
            maxLength: maxLength,
            alignment: alignment,
            options: options,
            isCombo: _isCombo(flags),
          ),
        );
      }
    }
  }

  /// Gets the page index from the field's /P reference.
  Future<int> _getPageIndex(PDFDictionary field) async {
    final pageRef = field[const PDFName('P')];
    if (pageRef == null) return 0;

    final pageDict = await _resolve(pageRef);
    if (pageDict is PDFDictionary) {
      final index = _pageObjectIdToIndex[identityHashCode(pageDict)];
      if (index != null) return index;
    }
    return 0;
  }

  /// Parses rectangle coordinates from /Rect entry.
  Future<PdfRect?> _parseRect(PDFObject rectRef) async {
    final rect = await _resolve(rectRef);
    if (rect is! PDFArray || rect.length < 4) return null;

    final coords = <double>[];
    for (final item in rect) {
      final resolved = await _resolve(item);
      if (resolved is PDFNumber) {
        coords.add(resolved.toDouble());
      }
    }

    if (coords.length >= 4) {
      return PdfRect(coords[0], coords[1], coords[2], coords[3]);
    }
    return null;
  }

  /// Parses field type from /FT entry.
  Future<PdfFieldType> _parseFieldType(PDFDictionary field) async {
    final ftRef = field[const PDFName('FT')];
    if (ftRef == null) return PdfFieldType.unknown;

    final ft = await _resolve(ftRef);
    if (ft is PDFName) {
      switch (ft.value) {
        case 'Tx':
          return PdfFieldType.text;
        case 'Btn':
          return PdfFieldType.button;
        case 'Ch':
          return PdfFieldType.choice;
        case 'Sig':
          return PdfFieldType.signature;
      }
    }
    return PdfFieldType.unknown;
  }

  /// Parses default value from /V entry.
  Future<String?> _parseDefaultValue(PDFDictionary field) async {
    final vRef = field[const PDFName('V')];
    if (vRef == null) return null;

    final v = await _resolve(vRef);
    if (v is PDFStringLike) {
      return v.asString();
    } else if (v is PDFName) {
      return v.value;
    }
    return null;
  }

  /// Parses field flags from /Ff entry.
  Future<int> _parseFieldFlags(PDFDictionary field) async {
    final ffRef = field[const PDFName('Ff')];
    if (ffRef == null) return 0;

    final ff = await _resolve(ffRef);
    if (ff is PDFNumber) {
      return ff.toInt();
    }
    return 0;
  }

  /// Parses max length from /MaxLen entry.
  Future<int?> _parseMaxLength(PDFDictionary field) async {
    final maxLenRef = field[const PDFName('MaxLen')];
    if (maxLenRef == null) return null;

    final maxLen = await _resolve(maxLenRef);
    if (maxLen is PDFNumber) {
      return maxLen.toInt();
    }
    return null;
  }

  /// Parses text alignment from /Q entry.
  Future<PdfTextAlignment> _parseAlignment(PDFDictionary field) async {
    final qRef = field[const PDFName('Q')];
    if (qRef == null) return PdfTextAlignment.left;

    final q = await _resolve(qRef);
    if (q is PDFNumber) {
      switch (q.toInt()) {
        case 1:
          return PdfTextAlignment.center;
        case 2:
          return PdfTextAlignment.right;
        default:
          return PdfTextAlignment.left;
      }
    }
    return PdfTextAlignment.left;
  }

  /// Parses options from /Opt entry for choice fields.
  Future<List<String>?> _parseOptions(PDFDictionary field) async {
    final optRef = field[const PDFName('Opt')];
    if (optRef == null) return null;

    final opt = await _resolve(optRef);
    if (opt is! PDFArray) return null;

    final options = <String>[];
    for (final item in opt) {
      final resolved = await _resolve(item);
      if (resolved is PDFStringLike) {
        options.add(resolved.asString());
      } else if (resolved is PDFArray && resolved.isNotEmpty) {
        // Options can be [exportValue, displayValue] pairs
        final displayValue = await _resolve(resolved[1]);
        if (displayValue is PDFStringLike) {
          options.add(displayValue.asString());
        }
      }
    }
    return options.isNotEmpty ? options : null;
  }

  // Field flag bit checks

  /// Checks if multiline flag is set (bit 13, value 4096).
  bool _isMultiline(int flags) => (flags & 4096) != 0;

  /// Checks if read-only flag is set (bit 1, value 1).
  bool _isReadOnly(int flags) => (flags & 1) != 0;

  /// Checks if combo flag is set for choice fields (bit 18, value 131072).
  bool _isCombo(int flags) => (flags & 131072) != 0;

  /// Resolves indirect PDF object references.
  Future<PDFObject> _resolve(PDFObject obj) async {
    final resolved = await _document.resolve(obj);
    return resolved ?? obj;
  }
}
