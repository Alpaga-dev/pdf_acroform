import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_acroform/pdf_acroform.dart';

void main() {
  group('PdfRect', () {
    test('calculates dimensions correctly with standard coordinates', () {
      const rect = PdfRect(100, 200, 300, 250);

      expect(rect.width, 200);
      expect(rect.height, 50);
      expect(rect.left, 100);
      expect(rect.right, 300);
      expect(rect.bottom, 200);
      expect(rect.top, 250);
    });

    test('calculates dimensions correctly with reversed coordinates', () {
      // PDF sometimes has x2 < x1 or y2 < y1
      const rect = PdfRect(300, 250, 100, 200);

      expect(rect.width, 200);
      expect(rect.height, 50);
      expect(rect.left, 100);
      expect(rect.right, 300);
      expect(rect.bottom, 200);
      expect(rect.top, 250);
    });

    test('toJson returns normalized coordinates', () {
      const rect = PdfRect(100, 200, 300, 250);
      final json = rect.toJson();

      expect(json['x'], 100);
      expect(json['y'], 200);
      expect(json['width'], 200);
      expect(json['height'], 50);
    });

    test('fromJson creates correct rect', () {
      final json = {'x': 100.0, 'y': 200.0, 'width': 200.0, 'height': 50.0};
      final rect = PdfRect.fromJson(json);

      expect(rect.left, 100);
      expect(rect.bottom, 200);
      expect(rect.width, 200);
      expect(rect.height, 50);
    });

    test('equality works correctly', () {
      const rect1 = PdfRect(100, 200, 300, 250);
      const rect2 = PdfRect(100, 200, 300, 250);
      const rect3 = PdfRect(100, 200, 300, 260);

      expect(rect1, equals(rect2));
      expect(rect1, isNot(equals(rect3)));
    });

    test('hashCode is consistent with equality', () {
      const rect1 = PdfRect(100, 200, 300, 250);
      const rect2 = PdfRect(100, 200, 300, 250);

      expect(rect1.hashCode, equals(rect2.hashCode));
    });

    test('toString returns readable format', () {
      const rect = PdfRect(100, 200, 300, 250);
      expect(rect.toString(), 'PdfRect(100.0, 200.0, 300.0, 250.0)');
    });
  });
}
