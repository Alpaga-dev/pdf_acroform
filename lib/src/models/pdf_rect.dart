import 'package:meta/meta.dart';

/// Rectangle coordinates in PDF coordinate space.
///
/// PDF uses a coordinate system where:
/// - The origin (0, 0) is at the bottom-left corner of the page
/// - X increases to the right
/// - Y increases upward
/// - Units are in points (72 points = 1 inch)
///
/// The rectangle is defined by two diagonal corners: (x1, y1) and (x2, y2).
/// These may be in any order (x1 may be greater than x2, etc.).
@immutable
class PdfRect {
  /// Creates a [PdfRect] with the given corner coordinates.
  const PdfRect(this.x1, this.y1, this.x2, this.y2);

  /// Creates a [PdfRect] from a JSON map.
  ///
  /// Expects keys: `x`, `y`, `width`, `height`.
  factory PdfRect.fromJson(Map<String, dynamic> json) {
    final x = (json['x'] as num).toDouble();
    final y = (json['y'] as num).toDouble();
    final width = (json['width'] as num).toDouble();
    final height = (json['height'] as num).toDouble();
    return PdfRect(x, y, x + width, y + height);
  }

  /// First X coordinate.
  final double x1;

  /// First Y coordinate.
  final double y1;

  /// Second X coordinate.
  final double x2;

  /// Second Y coordinate.
  final double y2;

  /// The width of the rectangle in points.
  double get width => (x2 - x1).abs();

  /// The height of the rectangle in points.
  double get height => (y2 - y1).abs();

  /// The leftmost X coordinate.
  double get left => x1 < x2 ? x1 : x2;

  /// The rightmost X coordinate.
  double get right => x1 > x2 ? x1 : x2;

  /// The bottom Y coordinate (smallest Y value).
  double get bottom => y1 < y2 ? y1 : y2;

  /// The top Y coordinate (largest Y value).
  double get top => y1 > y2 ? y1 : y2;

  /// Converts this rectangle to a JSON-serializable map.
  ///
  /// Returns a map with normalized coordinates:
  /// - `x`: left coordinate
  /// - `y`: bottom coordinate
  /// - `width`: rectangle width
  /// - `height`: rectangle height
  Map<String, double> toJson() => {
        'x': left,
        'y': bottom,
        'width': width,
        'height': height,
      };

  @override
  String toString() => 'PdfRect($x1, $y1, $x2, $y2)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfRect &&
          runtimeType == other.runtimeType &&
          x1 == other.x1 &&
          y1 == other.y1 &&
          x2 == other.x2 &&
          y2 == other.y2;

  @override
  int get hashCode => Object.hash(x1, y1, x2, y2);
}
