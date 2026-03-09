# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2026-03-09

### Fixed

- Font size now scales correctly with zoom level instead of being fixed
- Multiline text fields compute font size per line for better readability
- `PdfFormStyle.textStyle` and `readOnlyTextStyle` font size is now properly applied to all field widgets (text, checkbox, dropdown)

### Changed

- Font size clamp range widened from `(6.0, 16.0)` to `(1.0, 320.0)` to support extreme zoom levels

### Documentation

- Installation instructions now use pub.dev (`pdf_acroform: ^0.4.0`) instead of git dependency
- Added `backgroundColor` and `pageDropShadow` parameters to the API reference table

## [0.3.0] - 2026-01-26

### Added

- Auto-scroll to focused text field when tapped
- `PdfFormStyle` class for comprehensive form field styling customization
- `PdfFormStyle.fromTheme()` factory to match form fields with your app's theme
- Customizable properties: border radius, colors, text styles, cursor and selection colors
- `checkColor` and `checkedFillColor` for checkbox appearance customization
- `backgroundColor` parameter on `PdfFormViewer` to customize viewer background
- `pageDropShadow` parameter on `PdfFormViewer` to customize page shadow

### Changed

- Form fields now use explicit styles independent of app theme by default

### Known Limitations

- Auto-scroll may not fully account for keyboard height when field is at the bottom of the page

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
