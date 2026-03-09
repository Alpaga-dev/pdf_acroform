import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf_acroform/pdf_acroform.dart';
import 'package:pdf_acroform/pdf_acroform_viewer.dart';

void main() {
  runApp(const PdfFormApp());
}

class PdfFormApp extends StatelessWidget {
  const PdfFormApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF AcroForm Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PdfFormHomePage(),
    );
  }
}

class PdfFormHomePage extends StatefulWidget {
  const PdfFormHomePage({super.key});

  @override
  State<PdfFormHomePage> createState() => _PdfFormHomePageState();
}

class _PdfFormHomePageState extends State<PdfFormHomePage> {
  String? _pdfPath;
  List<PdfFormField>? _fields;
  bool _isLoadingPdf = false;
  String? _pdfError;

  final _jsonController = TextEditingController();
  Map<String, dynamic> _formData = {};
  String? _jsonError;

  final Set<String> _readOnlyFields = {};

  bool _showJsonPanel = true;

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.isEmpty) return;

      final path = result.files.single.path;
      if (path == null) return;

      setState(() {
        _isLoadingPdf = true;
        _pdfError = null;
      });

      final parser = await AcroFormParser.fromFile(path);
      final fields = await parser.extractFields();

      setState(() {
        _pdfPath = path;
        _fields = fields;
        _isLoadingPdf = false;
      });

      if (fields.isEmpty) {
        _showSnackBar('No form fields found in this PDF');
      } else {
        if (_jsonController.text.trim().isEmpty) {
          _prefillFromPdf();
        } else {
          _parseJson();
        }
        _showSnackBar('Found ${fields.length} form fields');
      }
    } on Exception catch (e) {
      setState(() {
        _pdfError = e.toString();
        _isLoadingPdf = false;
      });
      _showSnackBar('Error loading PDF: $e');
    }
  }

  void _parseJson() {
    final text = _jsonController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _formData = {};
        _jsonError = null;
      });
      return;
    }

    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('JSON must be an object');
      }
      setState(() {
        _formData = decoded;
        _jsonError = null;
      });
      _showSnackBar('JSON loaded: ${_formData.length} fields');
    } on Exception catch (e) {
      setState(() {
        _jsonError = e.toString();
      });
    }
  }

  void _prefillFromPdf() {
    if (_fields == null || _fields!.isEmpty) return;

    final extractedData = _fields!.extractFormData();
    if (extractedData.isEmpty) {
      _showSnackBar('No pre-filled values found in PDF');
      return;
    }

    setState(() {
      _formData = extractedData;
      _jsonController.text = const JsonEncoder.withIndent('  ').convert(_formData);
      _jsonError = null;
    });
    _showSnackBar('Pre-filled ${extractedData.length} fields from PDF');
  }

  void _updateField(String fieldName, dynamic value) {
    setState(() {
      _formData[fieldName] = value;
      _jsonController.text = const JsonEncoder.withIndent('  ').convert(_formData);
    });
  }

  void _exportJson() {
    final json = const JsonEncoder.withIndent('  ').convert(_formData);
    _showSnackBar('JSON exported to console');
    debugPrint('=== EXPORTED JSON ===');
    debugPrint(json);
    debugPrint('====================');

    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Export JSON'),
          content: SingleChildScrollView(
            child: SelectableText(
              json,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('PDF AcroForm Example'),
        actions: [
          IconButton(
            icon: Icon(_showJsonPanel ? Icons.code_off : Icons.code),
            tooltip: _showJsonPanel ? 'Hide JSON' : 'Show JSON',
            onPressed: () => setState(() => _showJsonPanel = !_showJsonPanel),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export JSON',
            onPressed: _formData.isNotEmpty ? _exportJson : null,
          ),
        ],
      ),
      body: Row(
        children: [
          if (_showJsonPanel)
            SizedBox(
              width: 350,
              child: _buildJsonPanel(),
            ),
          if (_showJsonPanel) const VerticalDivider(width: 1),
          Expanded(
            child: _buildPdfPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonPanel() {
    return ColoredBox(
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: Colors.grey.shade200,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'JSON Data',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _jsonController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                decoration: InputDecoration(
                  hintText: '{\n  "fieldName": "value",\n  "checkbox": true\n}',
                  border: const OutlineInputBorder(),
                  errorText: _jsonError,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _parseJson,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Apply JSON'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _fields != null && _fields!.isNotEmpty ? _prefillFromPdf : null,
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Pre-fill'),
                  ),
                ),
              ],
            ),
          ),
          if (_fields != null && _fields!.isNotEmpty)
            SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fields (${_fields!.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _fields!.length,
                        itemBuilder: (ctx, i) {
                          final field = _fields![i];
                          final hasValue = _formData.containsKey(field.name);
                          final isReadOnly = _readOnlyFields.contains(field.name);
                          return ListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            leading: Icon(
                              field.type == PdfFieldType.button ? Icons.check_box_outlined : Icons.text_fields,
                              size: 16,
                              color: hasValue ? Colors.green : Colors.grey,
                            ),
                            title: Text(
                              field.name,
                              style: TextStyle(
                                fontSize: 11,
                                color: isReadOnly ? Colors.grey : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isReadOnly ? Icons.lock : Icons.lock_open,
                                size: 16,
                                color: isReadOnly ? Colors.orange : Colors.grey,
                              ),
                              tooltip: isReadOnly ? 'Make editable' : 'Make read-only',
                              onPressed: () {
                                setState(() {
                                  if (isReadOnly) {
                                    _readOnlyFields.remove(field.name);
                                  } else {
                                    _readOnlyFields.add(field.name);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPdfPanel() {
    if (_isLoadingPdf) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pdfPath == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No PDF loaded'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickPdf,
              icon: const Icon(Icons.folder_open),
              label: const Text('Open PDF'),
            ),
          ],
        ),
      );
    }

    if (_pdfError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_pdfError'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickPdf,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        PdfFormViewer(
          pdfPath: _pdfPath!,
          fields: _fields ?? [],
          formData: _formData,
          readOnlyFields: _readOnlyFields,
          onFieldChanged: _updateField,
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _pickPdf,
            child: const Icon(Icons.folder_open),
          ),
        ),
      ],
    );
  }
}
