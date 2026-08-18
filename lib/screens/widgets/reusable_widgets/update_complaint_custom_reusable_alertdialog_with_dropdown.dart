import 'package:flutter/material.dart';

/// A reusable dialog for updating any complaint value with full Arabic & RTL support
/// This version uses a dropdown list for value selection
class UpdateComplaintCustomReusableAlertDialogWithDropDown
    extends StatefulWidget {
  final String id;
  final String currentValue;
  final String valueLabel;
  final String dialogTitle;
  final String complaintNote;
  final List<String> options; // List of available options for dropdown
  final Function(String newValue) onUpdate;

  const UpdateComplaintCustomReusableAlertDialogWithDropDown({
    super.key,
    required this.id,
    required this.currentValue,
    required this.valueLabel,
    required this.dialogTitle,
    this.complaintNote = '',
    required this.options,
    required this.onUpdate,
  });

  @override
  State<UpdateComplaintCustomReusableAlertDialogWithDropDown> createState() =>
      _UpdateComplaintCustomReusableAlertDialogWithDropDownState();
}

class _UpdateComplaintCustomReusableAlertDialogWithDropDownState
    extends State<UpdateComplaintCustomReusableAlertDialogWithDropDown> {
  String? _selectedValue;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.currentValue;
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

            // New value dropdown
            Form(
              key: _formKey,
              child: DropdownButtonFormField<String>(
                value: _selectedValue,
                decoration: InputDecoration(
                  labelText: 'القيمة الجديدة لـ ${widget.valueLabel}',
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: 'اختر القيمة الجديدة',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.arrow_drop_down_circle),
                  prefixIconColor: Colors.blue,
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: widget.options.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      option,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedValue = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء اختيار القيمة الجديدة';
                  }
                  if (value == widget.currentValue) {
                    return 'القيمة الجديدة يجب أن تكون غير القيمة الحالية';
                  }
                  return null;
                },
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 30,
                elevation: 4,
                dropdownColor: Colors.white,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  color: Colors.black87,
                ),
                alignment: AlignmentDirectional.centerEnd,
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
                final newValue = _selectedValue!.trim();
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
  Future<void> showUpdateComplaintDialogWithDropDown({
    required String id,
    required String currentValue,
    required String valueLabel,
    required String dialogTitle,
    String complaintNote = '',
    required List<String> options,
    required Function(String newValue) onUpdate,
  }) {
    return showDialog(
      context: this,
      builder: (context) =>
          UpdateComplaintCustomReusableAlertDialogWithDropDown(
        id: id,
        currentValue: currentValue,
        valueLabel: valueLabel,
        dialogTitle: dialogTitle,
        complaintNote: complaintNote,
        options: options,
        onUpdate: onUpdate,
      ),
    );
  }
}
