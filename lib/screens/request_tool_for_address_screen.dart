// ignore_for_file: unnecessary_type_check

import 'dart:developer';

import 'package:flutter/material.dart';
import '../custom_widget/custom_text_field.dart';
import '../network/remote/dio_network_repos.dart';

class RequestToolForAddressScreen extends StatefulWidget {
  final String address;
  final String handasahName;

  const RequestToolForAddressScreen({
    super.key,
    required this.address,
    required this.handasahName,
  });

  @override
  State<RequestToolForAddressScreen> createState() =>
      _RequestToolForAddressState();
}

class _RequestToolForAddressState extends State<RequestToolForAddressScreen> {
  final TextEditingController qtyController = TextEditingController();

  late Future<List<dynamic>> getToolsForAddressInHandasah;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserRequestForAddress();
  }

  @override
  void dispose() {
    qtyController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserRequestForAddress() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Ensure the network call returns a Future<List<dynamic>>
      final response = await DioNetworkRepos()
          .getHandasahToolsByAddressAndHandasahAndRequestStatus(
              widget.address, widget.handasahName, 1);

      // Convert the response to List if it's not already
      final List<dynamic> toolsList = response is List ? response : [response];

      setState(() {
        getToolsForAddressInHandasah = Future.value(toolsList);
        _isLoading = false;
      });

      log("Fetched tools: ${toolsList.length} items");
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      log("Error fetching tools: $e");
    }
  }

  Future<void> _updateToolQty(Map<String, dynamic> item) async {
    try {
      if (qtyController.text.isEmpty) {
        setState(() {
          qtyController.text = item['toolQty'].toString();
        });
        return;
      }

      // Update tool qty and approval status
      await DioNetworkRepos().updateUserRequestToolsByAddress(
        item['address'].toString(),
        int.parse(qtyController.text),
        item['isApproved'],
      );

      // Refresh the data after update
      await _fetchUserRequestForAddress();

      log('User request updated successfully');
    } catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating quantity: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "طلب المهمات لعنوان: ${widget.address}",
          style: const TextStyle(
            color: Colors.indigo,
          ),
        ),
        centerTitle: true,
        elevation: 7,
        // backgroundColor: Colors.white,
        // iconTheme: const IconThemeData(
        //   color: Colors.indigo,
        //   size: 17,
        // ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return const Center(
          child: Text(
        "لم يتم طلب مهات حتى الان",
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
      ));
      // return Center(child: Text("Error: $_errorMessage"));
    }

    return Row(
      children: [
        const Expanded(flex: 1, child: SizedBox()),
        Expanded(
          flex: 2,
          child: FutureBuilder<List<dynamic>>(
            future: getToolsForAddressInHandasah,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text("لم يتم طلب مهات حتى الان"));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("لم يتم طلب مهمات حتى الان"));
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data![index] as Map<String, dynamic>;
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  widget.handasahName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  'اسم الهندسة : ',
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  item['toolName']?.toString() ??
                                      'Default Tool',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  'اسم المهمة: ',
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  item['techName']?.toString() ??
                                      'Default user',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  'أسم الفنى :',
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  ' ${item['toolQty']?.toString() ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  'العدد: ',
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Expanded(
                                child: SizedBox.shrink(),
                              ),
                              Expanded(
                                child: TextButton(
                                  style: const ButtonStyle(
                                    shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(3),
                                        ),
                                      ),
                                    ),
                                    backgroundColor:
                                        WidgetStatePropertyAll<Color>(
                                            Colors.indigo),
                                  ),
                                  onPressed: () => _updateToolQty(item),
                                  child: const Text(
                                    'حفظ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: CustomTextField(
                                  controller: qtyController,
                                  keyboardType: TextInputType.number,
                                  lableText: 'العدد',
                                  hintText: 'فضلا أدخل الكمية',
                                  prefixIcon: const SizedBox.shrink(),
                                  suffixIcon: const SizedBox.shrink(),
                                  obscureText: false,
                                  textInputAction: TextInputAction.done,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const Expanded(flex: 1, child: SizedBox()),
      ],
    );
  }
}
