import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_acroform/pdf_acroform.dart';

void main() {
  group('PdfFormField', () {
    group('formValue', () {
      test('returns null for empty defaultValue', () {
        const field = PdfFormField(
          name: 'test',
          type: PdfFieldType.text,
          rect: PdfRect(0, 0, 100, 20),
          pageIndex: 0,
          defaultValue: null,
        );

        expect(field.formValue, isNull);
      });

      test('returns null for empty string defaultValue', () {
        const field = PdfFormField(
          name: 'test',
          type: PdfFieldType.text,
          rect: PdfRect(0, 0, 100, 20),
          pageIndex: 0,
          defaultValue: '',
        );

        expect(field.formValue, isNull);
      });

      test('returns string value for text fields', () {
        const field = PdfFormField(
          name: 'test',
          type: PdfFieldType.text,
          rect: PdfRect(0, 0, 100, 20),
          pageIndex: 0,
          defaultValue: 'Hello World',
        );

        expect(field.formValue, 'Hello World');
      });

      test('returns true for button field with "Yes" value', () {
        const field = PdfFormField(
          name: 'checkbox',
          type: PdfFieldType.button,
          rect: PdfRect(0, 0, 20, 20),
          pageIndex: 0,
          defaultValue: 'Yes',
        );

        expect(field.formValue, true);
      });

      test('returns true for button field with "On" value', () {
        const field = PdfFormField(
          name: 'checkbox',
          type: PdfFieldType.button,
          rect: PdfRect(0, 0, 20, 20),
          pageIndex: 0,
          defaultValue: 'On',
        );

        expect(field.formValue, true);
      });

      test('returns false for button field with "Off" value', () {
        const field = PdfFormField(
          name: 'checkbox',
          type: PdfFieldType.button,
          rect: PdfRect(0, 0, 20, 20),
          pageIndex: 0,
          defaultValue: 'Off',
        );

        expect(field.formValue, false);
      });

      test('returns false for button field with "No" value', () {
        const field = PdfFormField(
          name: 'checkbox',
          type: PdfFieldType.button,
          rect: PdfRect(0, 0, 20, 20),
          pageIndex: 0,
          defaultValue: 'No',
        );

        expect(field.formValue, false);
      });

      test('returns false for button field with "0" value', () {
        const field = PdfFormField(
          name: 'checkbox',
          type: PdfFieldType.button,
          rect: PdfRect(0, 0, 20, 20),
          pageIndex: 0,
          defaultValue: '0',
        );

        expect(field.formValue, false);
      });
    });

    group('toJson/fromJson', () {
      test('round-trips a basic field', () {
        const field = PdfFormField(
          name: 'firstName',
          type: PdfFieldType.text,
          rect: PdfRect(100, 700, 300, 720),
          pageIndex: 0,
        );

        final json = field.toJson();
        final restored = PdfFormField.fromJson(json);

        expect(restored.name, field.name);
        expect(restored.type, field.type);
        expect(restored.pageIndex, field.pageIndex);
        expect(restored.rect.left, field.rect.left);
      });

      test('round-trips a field with all properties', () {
        const field = PdfFormField(
          name: 'comments',
          type: PdfFieldType.text,
          rect: PdfRect(100, 500, 500, 700),
          pageIndex: 1,
          defaultValue: 'Some text',
          isMultiline: true,
          isReadOnly: true,
          maxLength: 500,
          alignment: PdfTextAlignment.center,
        );

        final json = field.toJson();
        final restored = PdfFormField.fromJson(json);

        expect(restored.name, field.name);
        expect(restored.defaultValue, field.defaultValue);
        expect(restored.isMultiline, field.isMultiline);
        expect(restored.isReadOnly, field.isReadOnly);
        expect(restored.maxLength, field.maxLength);
        expect(restored.alignment, field.alignment);
      });

      test('round-trips a choice field with options', () {
        const field = PdfFormField(
          name: 'country',
          type: PdfFieldType.choice,
          rect: PdfRect(100, 700, 300, 720),
          pageIndex: 0,
          options: ['France', 'Germany', 'Spain'],
          isCombo: true,
        );

        final json = field.toJson();
        final restored = PdfFormField.fromJson(json);

        expect(restored.type, PdfFieldType.choice);
        expect(restored.options, ['France', 'Germany', 'Spain']);
        expect(restored.isCombo, true);
      });
    });

    group('equality', () {
      test('fields with same properties are equal', () {
        const field1 = PdfFormField(
          name: 'test',
          type: PdfFieldType.text,
          rect: PdfRect(0, 0, 100, 20),
          pageIndex: 0,
        );
        const field2 = PdfFormField(
          name: 'test',
          type: PdfFieldType.text,
          rect: PdfRect(0, 0, 100, 20),
          pageIndex: 0,
        );

        expect(field1, equals(field2));
      });

      test('fields with different names are not equal', () {
        const field1 = PdfFormField(
          name: 'test1',
          type: PdfFieldType.text,
          rect: PdfRect(0, 0, 100, 20),
          pageIndex: 0,
        );
        const field2 = PdfFormField(
          name: 'test2',
          type: PdfFieldType.text,
          rect: PdfRect(0, 0, 100, 20),
          pageIndex: 0,
        );

        expect(field1, isNot(equals(field2)));
      });
    });
  });

  group('PdfFormFieldListExtension', () {
    late List<PdfFormField> fields;

    setUp(() {
      fields = const [
        PdfFormField(
          name: 'firstName',
          type: PdfFieldType.text,
          rect: PdfRect(0, 0, 100, 20),
          pageIndex: 0,
          defaultValue: 'John',
        ),
        PdfFormField(
          name: 'lastName',
          type: PdfFieldType.text,
          rect: PdfRect(0, 0, 100, 20),
          pageIndex: 0,
          defaultValue: '',
        ),
        PdfFormField(
          name: 'newsletter',
          type: PdfFieldType.button,
          rect: PdfRect(0, 0, 20, 20),
          pageIndex: 0,
          defaultValue: 'Yes',
        ),
        PdfFormField(
          name: 'terms',
          type: PdfFieldType.button,
          rect: PdfRect(0, 0, 20, 20),
          pageIndex: 1,
          defaultValue: 'Off',
        ),
        PdfFormField(
          name: 'comments',
          type: PdfFieldType.text,
          rect: PdfRect(0, 0, 200, 100),
          pageIndex: 1,
        ),
      ];
    });

    group('extractFormData', () {
      test('extracts fields with values', () {
        final data = fields.extractFormData();

        expect(data['firstName'], 'John');
        expect(data['newsletter'], true);
        expect(data.containsKey('lastName'), false); // empty value
        expect(data.containsKey('terms'), false); // Off checkbox excluded
        expect(data.containsKey('comments'), false); // null value
      });

      test('includes off checkboxes when requested', () {
        final data = fields.extractFormData(includeOffCheckboxes: true);

        expect(data['terms'], false);
      });
    });

    group('forPage', () {
      test('returns fields for specified page', () {
        final page0Fields = fields.forPage(0);
        final page1Fields = fields.forPage(1);

        expect(page0Fields.length, 3);
        expect(page1Fields.length, 2);
        expect(page0Fields.every((f) => f.pageIndex == 0), true);
        expect(page1Fields.every((f) => f.pageIndex == 1), true);
      });

      test('returns empty list for page with no fields', () {
        final page5Fields = fields.forPage(5);
        expect(page5Fields, isEmpty);
      });
    });

    group('ofType', () {
      test('returns fields of specified type', () {
        final textFields = fields.ofType(PdfFieldType.text);
        final buttonFields = fields.ofType(PdfFieldType.button);

        expect(textFields.length, 3);
        expect(buttonFields.length, 2);
        expect(textFields.every((f) => f.type == PdfFieldType.text), true);
        expect(buttonFields.every((f) => f.type == PdfFieldType.button), true);
      });

      test('returns empty list for type with no fields', () {
        final signatureFields = fields.ofType(PdfFieldType.signature);
        expect(signatureFields, isEmpty);
      });
    });
  });
}
