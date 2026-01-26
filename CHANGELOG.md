# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.1] - 2026-01-26

### Changed

- Read-only fields now display with a grey background for better visual feedback

## [0.2.0] - 2026-01-26

### Added

- `readOnlyFields` parameter on `PdfFormViewer` to dynamically mark fields as read-only

## [0.1.1] - 2026-01-26

### Changed

- Reduced package description size for pub.dev compliance


## [0.1.0] - 2026-01-26

### Added

- Initial release
- `AcroFormParser` for extracting form fields from PDF documents
- Support for field types: text, button (checkbox), choice (dropdown), signature
- Field properties: multiline, read-only, max length, text alignment, options
- `PdfFormField` model with JSON serialization
- `PdfRect` model for field positioning
- Extension methods: `extractFormData()`, `forPage()`, `ofType()`
- `PdfFormViewer` Flutter widget for displaying PDF with form overlays
- Interactive field widgets: text input, checkbox, dropdown
- Zoom controls for PDF viewer
- Example application
- Unit tests for models
