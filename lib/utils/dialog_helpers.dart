import 'package:flutter/material.dart';

class ManualStudentData {
  final String name;
  final String matricule;
  final String? email;

  ManualStudentData({
    required this.name,
    required this.matricule,
    this.email,
  });
}

class DialogHelpers {
  /// Opens a persistent multi-add dialog.
  /// [onAdd] is called each time the lecturer taps Add — returns an error
  /// string on failure or null on success.
  /// The dialog stays open until the lecturer taps Done.
  static Future<void> showAddManualStudentDialog(
    BuildContext context, {
    required Future<String?> Function(ManualStudentData) onAdd,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MultiAddDialog(onAdd: onAdd),
    );
  }

  static Future<ManualStudentData?> showAddManualStudentDialogLegacy(BuildContext context) async => null;

  static Future<bool?> showConfirmRemoveStudentDialog(BuildContext context, String studentName, String matricule) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Student?'),
        content: Text('Are you sure you want to remove $studentName ($matricule) from this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showEndSessionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
        title: const Text(
          'End Session?',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Are you sure you want to end this session?\n\n'
          'All attendance records, recognized faces, and session data will be permanently deleted.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
}

// ── Persistent multi-add dialog widget ───────────────────────────────────────

class _MultiAddDialog extends StatefulWidget {
  const _MultiAddDialog({required this.onAdd});
  final Future<String?> Function(ManualStudentData) onAdd;

  @override
  State<_MultiAddDialog> createState() => _MultiAddDialogState();
}

class _MultiAddDialogState extends State<_MultiAddDialog> {
  final _nameCtrl       = TextEditingController();
  final _matriculeCtrl  = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _formKey        = GlobalKey<FormState>();

  int     _addedCount  = 0;
  bool    _loading     = false;
  String? _lastAdded;
  String? _errorMsg;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _matriculeCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _errorMsg = null; _lastAdded = null; });

    final data = ManualStudentData(
      name:      _nameCtrl.text.trim(),
      matricule: _matriculeCtrl.text.trim(),
      email:     _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
    );

    final error = await widget.onAdd(data);

    if (!mounted) return;
    if (error == null) {
      setState(() {
        _addedCount++;
        _lastAdded = data.name;
        _loading   = false;
        _nameCtrl.clear();
        _matriculeCtrl.clear();
        _emailCtrl.clear();
      });
    } else {
      setState(() { _loading = false; _errorMsg = error; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.person_add),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _addedCount == 0
                  ? 'Add Students Manually'
                  : 'Add Students  ($_addedCount added)',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success banner
              if (_lastAdded != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '✓ $_lastAdded added successfully',
                          style: TextStyle(color: Colors.green.shade800, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // Error banner
              if (_errorMsg != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMsg!,
                    style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                  ),
                ),

              const Text(
                'For students with no Wi-Fi access. They will appear in the report as manual entries.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Student Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _matriculeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Matricule *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text(_addedCount == 0 ? 'Cancel' : 'Done ($_addedCount added)'),
        ),
        FilledButton.icon(
          onPressed: _loading ? null : _handleAdd,
          icon: _loading
              ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.add, size: 18),
          label: const Text('Add'),
          style: FilledButton.styleFrom(backgroundColor: cs.primary),
        ),
      ],
    );
  }
}