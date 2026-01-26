/// Field types in PDF AcroForms.
///
/// These correspond to the `/FT` entry in PDF field dictionaries:
/// - `/Tx` -> [text]
/// - `/Btn` -> [button]
/// - `/Ch` -> [choice]
/// - `/Sig` -> [signature]
enum PdfFieldType {
  /// Text field (`/FT /Tx`).
  ///
  /// Can be single-line or multi-line based on field flags.
  text,

  /// Button field (`/FT /Btn`).
  ///
  /// Includes checkboxes, radio buttons, and push buttons.
  button,

  /// Choice field (`/FT /Ch`).
  ///
  /// Includes dropdown lists (combo boxes) and list boxes.
  choice,

  /// Signature field (`/FT /Sig`).
  ///
  /// Used for digital signatures.
  signature,

  /// Unknown or unsupported field type.
  unknown,
}

/// Text alignment for form fields.
///
/// Corresponds to the `/Q` entry in PDF field dictionaries:
/// - `0` -> [left]
/// - `1` -> [center]
/// - `2` -> [right]
enum PdfTextAlignment {
  /// Left-aligned text (default).
  left,

  /// Center-aligned text.
  center,

  /// Right-aligned text.
  right,
}
