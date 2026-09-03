import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateReusableComplaint extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const CreateReusableComplaint({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<CreateReusableComplaint> createState() =>
      _CreateReusableComplaintState();
}

class _CreateReusableComplaintState extends State<CreateReusableComplaint> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _complaintAddressController =
      TextEditingController();
  final TextEditingController _recipientNameController =
      TextEditingController();
  final TextEditingController _recipientDestinationController =
      TextEditingController();
  final TextEditingController _complaintSourceController =
      TextEditingController();
  final TextEditingController _reporterNameController = TextEditingController();
  final TextEditingController _reporterPhoneController =
      TextEditingController();
  final TextEditingController _pumpDiameterController = TextEditingController();
  final TextEditingController _recipientUserController =
      TextEditingController();
  final TextEditingController _reportNumberController = TextEditingController();
  final TextEditingController _complaintNoteController =
      TextEditingController();

  // Dropdown selections
  String? _selectedApprovalAuthority;
  String? _selectedNeighborhood;
  String? _selectedComplaintRepairStatus;
  String? _selectedSeriousStatus;
  String? _selectedComplaintStatus;
  String? _selectedComplaintType;
  String? _selectedSectorName;

  // Dropdown options
  final List<String> _approvalAuthorities = [
    'نائب المحافظة',
    'السكرتير العام',
    'السكرتير العام المساعد',
    'رئيس الحي',
    'لم يدرج'
  ];

  final List<String> _neighborhoods = [
    'العجمي',
    'شرق',
    'عامرية أول',
    'عامرية ثان',
    'غرب',
    'مركز ومدينة برج العرب',
    'منتزه أول',
    'منتزه ثان',
    'وسط'
    // 'أبها'
  ];

  final List<String> _complaintRepairStatuses = [
    'جاري الإصلاح',
    'لا يخص الشركة',
    'يخص الشركة',
    'يخص المالك',
    'يلزم استخراج تصريح'
  ];

  final List<String> _seriousStatuses = ['مستقر', 'متوسط', 'عالى'];

  final List<String> _complaintStatuses = [
    'عادى',
    'متوسط الأهمية',
    'عالى الأهمية'
  ];

  final List<String> _complaintTypes = [
    'ارسال معدة',
    'انقطاع/ضعف مياه',
    'سدد صرف صحي',
    'نهضة مصر',
    'انقطاع التيار الكهربائي',
    'بدون غطاء',
    'تانك مياه',
    'كسر',
    'كول أمني',
    'معامل',
    'مندوب إتصالات',
    'مندوب صرف',
    'مندوب غاز',
    'مندوب كهرباء',
    'مندوب مرور',
    'مندوب مياه',
    'هبوط',
    'وصلة خلسة',
  ];

  final List<String> _sectorNames = [
    'قطاع التكنولوجيا',
    'قطاع المشروعات',
    'لم يحدد'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _populateFields(widget.initialData!);
    }
  }

  void _populateFields(Map<String, dynamic> data) {
    _complaintAddressController.text = data['complaintAddress'] ?? '';
    _recipientNameController.text = data['recipientName'] ?? '';
    _recipientDestinationController.text =
        data['recipientDestination'] ?? 'لم يدرج';
    _selectedApprovalAuthority = data['approvalAuthority'] ?? 'لم يدرج';
    _selectedNeighborhood = data['neighborhood'];
    _complaintSourceController.text = data['complaintSource'] ?? '';
    _reporterNameController.text = data['reporterName'] ?? '';
    _reporterPhoneController.text = data['reporterPhone'] ?? '';
    _selectedComplaintRepairStatus = data['complaintRepairStatus'];
    _pumpDiameterController.text = data['pumpDiameter'] ?? '';
    _selectedSeriousStatus = data['seriousStatus'];
    _selectedComplaintStatus = data['complaintStatus'];
    _recipientUserController.text = data['recipientUser'] ?? '';
    _selectedComplaintType = data['complaintType'];
    _selectedSectorName = data['sectorName'];
    _reportNumberController.text = data['reportNumber'] ?? '';
    _complaintNoteController.text = data['complaintNote'] ?? '';
  }

  @override
  void dispose() {
    _complaintAddressController.dispose();
    _recipientNameController.dispose();
    _recipientDestinationController.dispose();
    _complaintSourceController.dispose();
    _reporterNameController.dispose();
    _reporterPhoneController.dispose();
    _pumpDiameterController.dispose();
    _recipientUserController.dispose();
    _reportNumberController.dispose();
    _complaintNoteController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final formData = {
        'complaintAddress': _complaintAddressController.text,
        'recipientName': _recipientNameController.text,
        'recipientDestination': _recipientDestinationController.text.isNotEmpty
            ? _recipientDestinationController.text
            : 'لم يدرج',
        'approvalAuthority': _selectedApprovalAuthority ?? 'لم يدرج',
        'neighborhood': _selectedNeighborhood!,
        'complaintSource': _complaintSourceController.text,
        'reporterName': _reporterNameController.text,
        'reporterPhone': _reporterPhoneController.text,
        'complaintRepairStatus': _selectedComplaintRepairStatus!,
        'pumpDiameter': _pumpDiameterController.text,
        'seriousStatus': _selectedSeriousStatus!,
        'complaintStatus': _selectedComplaintStatus!,
        'recipientUser': _recipientUserController.text,
        'complaintType': _selectedComplaintType!,
        'sectorName': _selectedSectorName,
        'reportNumber': _reportNumberController.text,
        'complaintNote': _complaintNoteController.text
      };

      widget.onSave(formData);
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool required = true,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w500,
          ),
          hintText: hintText ?? 'أدخل $label',
          hintStyle: const TextStyle(
            fontFamily: 'Cairo',
            color: Colors.grey,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: suffixIcon,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          alignLabelWithHint: true,
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
    bool required = true,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'يرجى اختيار $label';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w500,
          ),
          hintText: hintText ?? 'اختر $label',
          hintStyle: const TextStyle(
            fontFamily: 'Cairo',
            color: Colors.grey,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down),
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Cairo',
        ),
        dropdownColor: Colors.white,
        elevation: 8,
        menuMaxHeight: 300,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.indigo.shade700,
                              Colors.indigo.shade400
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'إنشاء بلاغ جديد',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 40,
                              ),
                              child: Text(
                                'يرجى ملء جميع الحقول المطلوبة',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Basic Information Section
                      _buildSectionTitle('المعلومات الأساسية'),

                      _buildTextField(
                        label: 'عنوان البلاغ',
                        controller: _complaintAddressController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال عنوان البلاغ';
                          }
                          return null;
                        },
                        maxLines: 2,
                        suffixIcon:
                            const Icon(Icons.location_on, color: Colors.grey),
                      ),

                      // _buildTextField(
                      //   label: 'مستلم الهندسة',
                      //   controller: _recipientUserController,
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'يرجى إدخال اسم المستلم';
                      //     }
                      //     return null;
                      //   },
                      //   suffixIcon:
                      //       const Icon(Icons.person, color: Colors.grey),
                      // ),

                      // _buildTextField(
                      //   label: 'جهة الاستلام',
                      //   controller: _recipientDestinationController,
                      //   required: false,
                      //   hintText: 'لم يدرج',
                      //   validator: null,
                      //   suffixIcon:
                      //       const Icon(Icons.business, color: Colors.grey),
                      // ),

                      _buildDropdownField(
                        label: 'جهة الموافقة',
                        items: _approvalAuthorities,
                        selectedValue: _selectedApprovalAuthority,
                        required: false,
                        onChanged: (value) {
                          setState(() {
                            _selectedApprovalAuthority = value;
                          });
                        },
                      ),

                      _buildDropdownField(
                        label: 'الحي',
                        items: _neighborhoods,
                        selectedValue: _selectedNeighborhood,
                        required: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedNeighborhood = value;
                          });
                        },
                      ),

                      const Divider(height: 32),

                      // Reporter Information Section
                      _buildSectionTitle('معلومات المبلغ'),

                      _buildTextField(
                        label: 'مصدر البلاغ',
                        controller: _complaintSourceController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال مصدر البلاغ';
                          }
                          return null;
                        },
                        suffixIcon:
                            const Icon(Icons.source, color: Colors.grey),
                      ),

                      _buildTextField(
                        label: 'اسم المبلغ',
                        controller: _reporterNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال اسم المبلغ';
                          }
                          return null;
                        },
                        suffixIcon: const Icon(Icons.person_outline,
                            color: Colors.grey),
                      ),

                      _buildTextField(
                        label: 'رقم هاتف المبلغ',
                        controller: _reporterPhoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال رقم الهاتف';
                          }
                          if (value.length != 11) {
                            return 'يجب أن يتكون رقم الهاتف من 11 رقمًا';
                          }
                          return null;
                        },
                        suffixIcon: const Icon(Icons.phone, color: Colors.grey),
                      ),
                      _buildTextField(
                        label: 'رقم الإشارة',
                        controller: _reportNumberController,
                        required: true,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال رقم الإشارة';
                          }
                          return null;
                        },
                        suffixIcon:
                            const Icon(Icons.numbers, color: Colors.grey),
                      ),
                      _buildTextField(
                        label: 'ملاحظات',
                        controller: _complaintNoteController ..text = 'ملاحظات البلاغ',
                        required: false,
                        suffixIcon: const Icon(Icons.note, color: Colors.grey),
                      ),

                      const Divider(height: 32),

                      // Complaint Details Section
                      _buildSectionTitle('تفاصيل البلاغ'),

                      _buildDropdownField(
                        label: 'حالة الإصلاح',
                        items: _complaintRepairStatuses,
                        selectedValue: _selectedComplaintRepairStatus,
                        required: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedComplaintRepairStatus = value;
                          });
                        },
                      ),

                      _buildTextField(
                        label: 'قطر الماسورة',
                        controller: _pumpDiameterController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال قطر الماسورة';
                          }
                          return null;
                        },
                        suffixIcon: const Icon(Icons.speed, color: Colors.grey),
                      ),

                      _buildDropdownField(
                        label: 'حالة الخطورة',
                        items: _seriousStatuses,
                        selectedValue: _selectedSeriousStatus,
                        required: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedSeriousStatus = value;
                          });
                        },
                      ),

                      _buildDropdownField(
                        label: 'حالة البلاغ',
                        items: _complaintStatuses,
                        selectedValue: _selectedComplaintStatus,
                        required: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedComplaintStatus = value;
                          });
                        },
                      ),

                      _buildTextField(
                        label: 'اسم المستلم البلاغ',
                        controller: _recipientNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال اسم المستلم';
                          }
                          return null;
                        },
                        suffixIcon: const Icon(Icons.account_circle,
                            color: Colors.grey),
                      ),

                      _buildDropdownField(
                        label: 'نوع البلاغ',
                        items: _complaintTypes,
                        selectedValue: _selectedComplaintType,
                        required: true,
                        onChanged: (value) {
                          setState(() {
                            _selectedComplaintType = value;
                          });
                        },
                      ),

                      _buildDropdownField(
                        label: 'اسم القطاع',
                        items: _sectorNames,
                        selectedValue: _selectedSectorName,
                        required: false,
                        onChanged: (value) {
                          setState(() {
                            _selectedSectorName = value;
                          });
                        },
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.indigo.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save),
                                  SizedBox(width: 8),
                                  Text(
                                    'حفظ البلاغ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _formKey.currentState?.reset();
                                setState(() {
                                  _complaintAddressController.clear();
                                  _recipientNameController.clear();
                                  _recipientDestinationController.clear();
                                  _complaintSourceController.clear();
                                  _reporterNameController.clear();
                                  _reporterPhoneController.clear();
                                  _pumpDiameterController.clear();
                                  _recipientUserController.clear();
                                  _selectedApprovalAuthority = null;
                                  _selectedNeighborhood = null;
                                  _selectedComplaintRepairStatus = null;
                                  _selectedSeriousStatus = null;
                                  _selectedComplaintStatus = null;
                                  _selectedComplaintType = null;
                                  _selectedSectorName = null;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey.shade400),
                              ),
                              child: const Text(
                                'إعادة تعيين',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 50, 50, 50),
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}
