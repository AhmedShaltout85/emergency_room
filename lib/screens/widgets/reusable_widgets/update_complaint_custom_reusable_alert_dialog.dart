

import 'package:flutter/material.dart';

/// A reusable dialog for updating any complaint value with full Arabic & RTL support
class UpdateComplaintCustomReusableAlertDialog extends StatefulWidget {
  final String id;
  final String currentValue;
  final String valueLabel;
  final String dialogTitle;
  final String complaintNote;
  final Function(String newValue) onUpdate;

  const UpdateComplaintCustomReusableAlertDialog({
    super.key,
    required this.id,
    required this.currentValue,
    required this.valueLabel,
    required this.dialogTitle,
    this.complaintNote = '',
    required this.onUpdate,
  });

  @override
  State<UpdateComplaintCustomReusableAlertDialog> createState() =>
      _UpdateComplaintCustomReusableAlertDialogState();
}

class _UpdateComplaintCustomReusableAlertDialogState
    extends State<UpdateComplaintCustomReusableAlertDialog> {
  final TextEditingController _valueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _valueController.text = widget.currentValue;
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text(
          widget.dialogTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display current value
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'القيمة الحالية لـ ${widget.valueLabel} :',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    widget.currentValue,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Display ID if provided
            if (widget.id.isNotEmpty) ...[
              Row(
                children: [
                  const Text(
                    'الرقم التعريفي:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.id,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],

            // Display note if available
            if (widget.complaintNote.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ملاحظة:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.complaintNote,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            const Divider(),
            const SizedBox(height: 8),

            // New value input field
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _valueController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'القيمة الجديدة لـ ${widget.valueLabel}',
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: 'أدخل القيمة الجديدة',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.edit_note),
                  prefixIconColor: Colors.blue,
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال القيمة الجديدة';
                  }
                  if (value == widget.currentValue) {
                    return 'القيمة الجديدة يجب أن تكون غير القيمة الحالية';
                  }if(double.parse(value) < double.parse(widget.currentValue)){
                    return 'القيمة الجديدة يجب ان تكون أكبر من القيمة الحالية';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Update button
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newValue = _valueController.text.trim();
                widget.onUpdate(newValue);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'تحديث',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// Extension method to show the dialog easily
extension UpdateComplaintDialogExtension on BuildContext {
  Future<void> showUpdateComplaintDialog({
    required String id,
    required String currentValue,
    required String valueLabel,
    required String dialogTitle,
    String complaintNote = '',
    required Function(String newValue) onUpdate,
  }) {
    return showDialog(
      context: this,
      builder: (context) => UpdateComplaintCustomReusableAlertDialog(
        id: id,
        currentValue: currentValue,
        valueLabel: valueLabel,
        dialogTitle: dialogTitle,
        complaintNote: complaintNote,
        onUpdate: onUpdate,
      ),
    );
  }
}

