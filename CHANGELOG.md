# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-01-26

### Added

- `PdfFormStyle` class for comprehensive form field styling customization
- `PdfFormStyle.fromTheme()` factory to match form fields with your app's theme
- Customizable properties: border radius, colors, text styles, cursor and selection colors
- `checkColor` and `checkedFillColor` for checkbox appearance customization

### Changed

- Form fields now use explicit styles independent of app theme by default

### Documentation

- Added troubleshooting section for scroll issues with keyboard
- Documented `PdfFormStyle` usage and all available properties

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
