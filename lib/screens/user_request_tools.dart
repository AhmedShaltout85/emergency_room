import 'package:flutter/material.dart';
import 'package:emergency_room/custom_widget/custom_drop_down_menu_tools.dart';
import '../network/remote/remote_network_repos.dart';

class UserRequestTools extends StatefulWidget {
  final String handasahName;
  final String address;
  final String technicianName;

  const UserRequestTools({
    super.key,
    required this.handasahName,
    required this.address,
    required this.technicianName,
  });

  @override
  State<UserRequestTools> createState() => _UserRequestToolsState();
}

class _UserRequestToolsState extends State<UserRequestTools> {
  List<String> toolsItemsDropdownMenu = [];
  String? selectedTool;
  bool isLoading = false;
  bool isSubmitting = false;
  bool isRefreshing = false;
  String? errorMessage;
  int toolQty = 1;
  List<Map<String, dynamic>> requestedItems = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      fetchHandasatItems(),
      fetchRequestedTools(),
    ]);
  }

  Future<void> fetchHandasatItems() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final items = await DioNetworkRepos().fetchHandasatToolsItemsDropdownMenu(
        widget.handasahName,
      );

      if (!mounted) return;
      setState(() {
        toolsItemsDropdownMenu = items;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'لا يوجد مهمات لهذه الشكوى حتى الان';
      });
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchRequestedTools() async {
    if (!mounted) return;
    setState(() {
      isRefreshing = true;
      errorMessage = null;
    });

    try {
      final requests = await DioNetworkRepos()
          .getHandasahToolsByAddressAndHandasahAndRequestStatus(
              widget.address, widget.handasahName, 1);

      if (!mounted) return;
      setState(() {
        requestedItems = requests.map((request) {
          return {
            'toolName': request['toolName'],
            'quantity': request['toolQty'],
            'date': DateTime.parse(request['date']),
            'status':
                request['isApproved'] == 1 ? 'تم الموافقة' : 'قيد الموافقة',
            'id': request['id'],
          };
        }).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = '!لم يتم تخصيص مهمات لهذه الشكوى حتى الان';
      });
    } finally {
      if (!mounted) return;
      setState(() => isRefreshing = false);
    }
  }

  Future<void> _submitRequest() async {
    if (selectedTool == null || selectedTool!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a tool first')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await DioNetworkRepos().createNewRequestTools(
        handasahName: widget.handasahName,
        toolName: selectedTool!,
        address: widget.address,
        techName: widget.technicianName,
        requestStatus: 1,
        toolQty: toolQty,
        isApproved: 0,
        date: DateTime.now().toIso8601String(),
      );

      // Refresh the list after successful submission
      await fetchRequestedTools();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم طلب $selectedTool بنجاح',
            textAlign: TextAlign.center,
          ),
        ),
      );

      setState(() => selectedTool = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request: ${e.toString()}')),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  // Future<void> _deleteRequest(int index) async {
  //   final itemToDelete = requestedItems[index];
  //   final originalItems = List<Map<String, dynamic>>.from(requestedItems);

  //   setState(() {
  //     requestedItems.removeAt(index);
  //   });

  //   try {
  //     await DioNetworkRepos().deleteToolRequest(itemToDelete['id']);
  //     await fetchRequestedTools(); // Refresh the list after deletion

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('تم حذف الطلب بنجاح',
  //           textAlign: TextAlign.center,
  //         ),

  //       ),
  //     );
  //   } catch (e) {
  //     setState(() {
  //       requestedItems = originalItems;
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to delete request: ${e.toString()}'),
  //       ),
  //     );
  //   }
  // }

  Future<void> _handleRefresh() async {
    // Show refresh indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'جاري تحديث البيانات...',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        duration: Duration(seconds: 1),
      ),
    );

    await fetchRequestedTools();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'طلب المهمات',
          style: TextStyle(color: Colors.indigo),
        ),
        centerTitle: true,
        elevation: 7,
        // backgroundColor: Colors.white,
        // iconTheme: const IconThemeData(
        //   color: Colors.indigo,
        //   size: 17,
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (isLoading || isRefreshing)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.indigo, width: 1.0),
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                            child: DropdownButton<int>(
                              value: toolQty,
                              items: List.generate(10, (i) => i + 1)
                                  .map((qty) => DropdownMenuItem(
                                        value: qty,
                                        child: Text(
                                          '$qty',
                                          style: const TextStyle(
                                              color: Colors.indigo),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => toolQty = value);
                                }
                              },
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 3,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.indigo, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: toolsItemsDropdownMenu.isEmpty
                                ? const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16.0),
                                    child: Text('No tools available'),
                                  )
                                : CustomDropDownMenuTools(
                                    isExpanded: false,
                                    items: toolsItemsDropdownMenu,
                                    hintText: 'اسم المهمة',
                                    value: selectedTool,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedTool = value;
                                      });
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                      ),
                      onPressed: isSubmitting ? null : _submitRequest,
                      child: isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'تأكيد الطلب',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                    const SizedBox(height: 20),
                    // Card(
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(30.0),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.end,
                    //       children: [
                    //         Text(
                    //           'الهندسة: ${widget.handasahName}',
                    //           textAlign: TextAlign.right,
                    //           textDirection: TextDirection.rtl,
                    //           style: const TextStyle(color: Colors.indigo),
                    //         ),
                    //         Text(
                    //           'العنوان: ${widget.address}',
                    //           textAlign: TextAlign.right,
                    //           textDirection: TextDirection.rtl,
                    //           style: const TextStyle(color: Colors.indigo),
                    //         ),
                    //         Text(
                    //           'الفني: ${widget.technicianName}',
                    //           textAlign: TextAlign.right,
                    //           textDirection: TextDirection.rtl,
                    //           style: const TextStyle(color: Colors.indigo),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 20),
                    if (requestedItems.isNotEmpty) ...[
                      Text(
                        'الطلبات المضافة: ${widget.address}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              for (int i = 0; i < requestedItems.length; i++)
                                ListTile(
                                  title: Text(
                                    requestedItems[i]['toolName'],
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: Colors.indigo,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'الكمية: ${requestedItems[i]['quantity']} \n الحالة: ${requestedItems[i]['status']}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  // trailing: IconButton(
                                  //   icon: const Icon(Icons.delete,
                                  //       color: Colors.red),
                                  //   onPressed: () => _deleteRequest(i),
                                  // ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
