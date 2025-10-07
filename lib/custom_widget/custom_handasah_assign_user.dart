import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:emergency_room/custom_widget/custom_dropdown_menu.dart';
import '../network/remote/remote_network_repos.dart';

class CustomHandasahAssignUser extends StatefulWidget {
  // Properties
  final String title;
  final Future getLocs; // Added generic type
  final List<String> stringListItems;
  final VoidCallback onPressed;
  final String hintText;

  // Constructor
  const CustomHandasahAssignUser({
    super.key,
    required this.getLocs,
    required this.stringListItems,
    required this.onPressed,
    required this.hintText,
    required this.title,
  });

  @override
  State<CustomHandasahAssignUser> createState() =>
      _CustomHandasahAssignUserState();
}

class _CustomHandasahAssignUserState extends State<CustomHandasahAssignUser> {
  @override
  Widget build(BuildContext context) {
    String? selectedValue;

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(
            height: 50,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.indigo,
              ),
              child: Text(
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          FutureBuilder(
            future: widget.getLocs,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data!.isEmpty) {
                return const Center(child: Text("لا يوجد شكاوى جديدة"));
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final data = snapshot.data![index]; // Store in a variable
                  return Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            data['address'] ?? 'Unknown Address',
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // subtitle: Text(
                          //   "(${data['latitude'] ?? 'N/A'}, ${data['longitude'] ?? 'N/A'})",
                          // ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(10.0),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 7.0),
                                // decoration: BoxDecoration(
                                //   border: Border.all(
                                //       color: Colors.indigo, width: 1.0),
                                //   borderRadius: BorderRadius.circular(10.0),
                                // ),
                                child: CustomDropdown(
                                  isExpanded: true,
                                  hintText: widget.hintText,
                                  items: widget.stringListItems,
                                  value: selectedValue,
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      log('Selected item: $newValue');
                                      setState(() {
                                        selectedValue = newValue;
                                      });
                                      //updateLocAddHandasah
                                      DioNetworkRepos().updateLocAddTechnician(
                                        data['address'] ?? '',
                                        newValue,
                                      );
                                      log('updated item: $newValue');
                                      //
                                    }
                                  },
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'توجيهه',
                              onPressed: widget.onPressed,
                              icon: const Icon(
                                Icons.navigate_next_outlined,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:emergency_room/custom_widget/custom_dropdown_menu.dart';
// import '../network/remote/dio_network_repos.dart';

// class CustomHandasahAssignUser extends StatelessWidget {
//   // Properties
//   final String title;
//   final Future<List<dynamic>> getLocs; // Added proper generic type
//   final List<String> stringListItems;
//   final Function(String) onTechnicianSelected; // Changed to accept String parameter
//   final VoidCallback? onAssignPressed; // Made optional since it's not always needed
//   final String hintText;

//   // Constructor
//   const CustomHandasahAssignUser({
//     super.key,
//     required this.getLocs,
//     required this.stringListItems,
//     required this.onTechnicianSelected,
//     this.onAssignPressed,
//     required this.hintText,
//     required this.title,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: ListView(
//         shrinkWrap: true,
//         children: [
//           SizedBox(
//             height: 50,
//             child: DrawerHeader(
//               decoration: const BoxDecoration(
//                 color: Colors.indigo,
//               ),
//               child: Text(
//                 textDirection: TextDirection.rtl,
//                 textAlign: TextAlign.center,
//                 title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 13,
//                 ),
//               ),
//             ),
//           ),
//           FutureBuilder<List<dynamic>>(
//             future: getLocs,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (!snapshot.hasData ||
//                   snapshot.data == null ||
//                   snapshot.data!.isEmpty) {
//                 return const Center(child: Text("لا يوجد شكاوى جديدة"));
//               }

//               return ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: snapshot.data!.length,
//                 itemBuilder: (context, index) {
//                   final data = snapshot.data![index];
//                   return Card(
//                     child: Column(
//                       children: [
//                         ListTile(
//                           title: Text(
//                             data['address'] ?? 'Unknown Address',
//                             style: const TextStyle(
//                               color: Colors.indigo,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             if (onAssignPressed != null)
//                               IconButton(
//                                 onPressed: onAssignPressed,
//                                 icon: const Icon(
//                                   Icons.call_missed_rounded,
//                                   color: Colors.indigo,
//                                 ),
//                               ),
//                             Expanded(
//                               child: Container(
//                                 margin: const EdgeInsets.all(10.0),
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 7.0),
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                       color: Colors.indigo, width: 1.0),
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 child: CustomDropdown(
//                                   isExpanded: true,
//                                   hintText: hintText,
//                                   items: stringListItems,
//                                   onChanged: (value) {
//                                     if (value != null) {
//                                       onTechnicianSelected(value);
//                                       DioNetworkRepos().updateLocAddTechnician(
//                                         data['address'] ?? '',
//                                         value,
//                                       );
//                                     }
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }