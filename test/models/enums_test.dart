import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_acroform/pdf_acroform.dart';

void main() {
  group('PdfFieldType', () {
    test('has all expected values', () {
      expect(
          PdfFieldType.values,
          containsAll([
            PdfFieldType.text,
            PdfFieldType.button,
            PdfFieldType.choice,
            PdfFieldType.signature,
            PdfFieldType.unknown,
          ]));
    });

    test('can be converted to/from name', () {
      for (final type in PdfFieldType.values) {
        final name = type.name;
        final restored = PdfFieldType.values.byName(name);
        expect(restored, type);
      }
    });
  });

  group('PdfTextAlignment', () {
    test('has all expected values', () {
      expect(
          PdfTextAlignment.values,
          containsAll([
            PdfTextAlignment.left,
            PdfTextAlignment.center,
            PdfTextAlignment.right,
          ]));
    });

    test('can be converted to/from name', () {
      for (final alignment in PdfTextAlignment.values) {
        final name = alignment.name;
        final restored = PdfTextAlignment.values.byName(name);
        expect(restored, alignment);
      }
    });
  });
}
