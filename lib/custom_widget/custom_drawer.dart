import 'package:flutter/material.dart';
// import '../utils/dio_http_constants.dart';

class CustomDrawer extends StatelessWidget {
  final Future getLocs;
  final String title;
  final Function(Map<String, dynamic>) onTap; // Changed to accept item data

  const CustomDrawer({
    super.key,
    required this.getLocs,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        backgroundColor: Colors.black45,
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
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            FutureBuilder(
              future: getLocs,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];
                      final address = item['mainStreet'] == null ||
                              item['mainStreet'] == ""
                          ? '${item['street']} الاسكندرية'
                          : '${item['street']} ${item['mainStreet']} الاسكندرية';

                      return InkWell(
                        onTap: () {
                          // Pass all the relevant data through the callback
                          onTap({
                            'id': item['id'],
                            'address': address,
                            'x': item['x'],
                            'y': item['y'],
                            'caseReportDateTime': item['caseReportDateTime'],
                            'finalClosed': item['finalClosed'],
                            'reporterName': item['reporterName'],
                            'mainStreet': item['mainStreet'],
                            'street': item['street'],
                            'caseType': item['caseType'],
                          });
                        },
                        child: Card(
                          child: ListTile(
                            title: item['mainStreet'] == null ||
                                    item['mainStreet'] == ""
                                ? Text(
                                    item['street'],
                                    style: const TextStyle(
                                        color: Colors.indigo,
                                        fontWeight: FontWeight.bold),
                                  )
                                : Text(
                                    '${item['street']} ${item['mainStreet']}',
                                    style: const TextStyle(
                                        color: Colors.indigo,
                                        fontWeight: FontWeight.bold),
                                  ),
                            subtitle: Text(
                              '${item['id']}',
                              style: const TextStyle(color: Colors.indigo),
                            ),
                          ),
                        ),
                      );
                    },
                    physics: const NeverScrollableScrollPhysics(),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';

// import '../utils/dio_http_constants.dart';
// // import 'package:flutter/services.dart';
// // import 'package:pick_location/network/remote/dio_network_repos.dart';

// class CustomDrawer extends StatelessWidget {
//   final Future getLocs;
//   final String title;
//   final VoidCallback onTap; // Add the onTap callback property to get location
//   //constructor
//   const CustomDrawer({
//     super.key,
//     required this.getLocs,
//     required this.title,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Drawer(
//         backgroundColor: Colors.black45,
//         child: ListView(
//           shrinkWrap: true,
//           children: [
//             SizedBox(
//               height: 50,
//               child: DrawerHeader(
//                 decoration: const BoxDecoration(
//                   color: Colors.indigo,
//                 ),
//                 child: Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 13,
//                   ),
//                 ),
//               ),
//             ),
//             FutureBuilder(
//                 future: getLocs,
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     return ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: snapshot.data!.length,
//                       itemBuilder: (context, index) {
//                         //pass hotline address to get location
//                         snapshot.data![index]['mainStreet'] == null ||
//                                 snapshot.data![index]['mainStreet'] == ""
//                             ? DataStatic.hotlineAddress =
//                                 '${snapshot.data![index]['street']} الاسكندرية'
//                             : DataStatic.hotlineAddress =
//                                 '${snapshot.data![index]['street']} ${snapshot.data![index]['mainStreet']} الاسكندرية';
//                         DataStatic.hotlineId = snapshot.data![index]['id'];
//                         DataStatic.hotlineX = snapshot.data![index]['x'];
//                         DataStatic.hotlineY =
//                             snapshot.data![index]['y'];
//                         DataStatic.hotlinecaseReportDateTime =
//                             snapshot.data![index]['caseReportDateTime'];
//                         DataStatic.hotlinefinalClosed =
//                             snapshot.data![index]['finalClosed'];
//                         DataStatic.hotlinereporterName =
//                             snapshot.data![index]['reporterName'];
//                         DataStatic.hotlinemainStreet =
//                             snapshot.data![index]['mainStreet'];
//                         DataStatic.hotlineStreet = snapshot.data![index]['street'];
//                         DataStatic.hotlinecaseType = snapshot.data![index]['caseType'];
//                             //
//                         return InkWell(
//                           onTap: onTap,
//                           child: Card(
//                             child: ListTile(
//                               title: snapshot.data![index]['mainStreet'] ==
//                                           null ||
//                                       snapshot.data![index]['mainStreet'] == ""
//                                   ? Text(
//                                       snapshot.data![index]['street'],
//                                       style: const TextStyle(
//                                           color: Colors.indigo,
//                                           fontWeight: FontWeight.bold),
//                                     )
//                                   : Text(
//                                       '${snapshot.data![index]['street']} ${snapshot.data![index]['mainStreet']}',
//                                       style: const TextStyle(
//                                           color: Colors.indigo,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                               subtitle: Text(
//                                 '${snapshot.data[index]['id']}',
//                                 style: const TextStyle(color: Colors.indigo),
//                               ),
//                             ),
//                           ),
//                           // () {
//                           //   String address;
//                           //   snapshot.data![index]['mainStreet'] == null ||
//                           //           snapshot.data![index]['mainStreet'] == ""
//                           //       ? address =
//                           //           '${snapshot.data![index]['street']} الاسكندرية'
//                           //       : address =
//                           //           '${snapshot.data[index]['street']} ${snapshot.data[index]['mainStreet']} الاسكندرية';
//                           //   //post hotline data to local db
//                           //   try {
//                           //     DioNetworkRepos().postHotLineDataList(
//                           //       id: snapshot.data[index]['id'],
//                           //       caseReportDateTime: snapshot.data[index]
//                           //           ['caseReportDateTime'],
//                           //       caseType: snapshot.data[index]['caseType'],
//                           //       finalClosed: snapshot.data![index]
//                           //           ['finalClosed'],
//                           //       mainStreet: snapshot.data![index]['mainStreet'],
//                           //       reporterName: snapshot.data![index]
//                           //           ['reporterName'],
//                           //       street: snapshot.data![index]['street'],
//                           //       x: snapshot.data![index]['x'],
//                           //       y: snapshot.data![index]['y'],
//                           //       address: address,
//                           //     );
//                           //   } catch (e) {
//                           //     log(e.toString());
//                           //   }
//                           //   //CALL API TO UPDATE LOCATION
//                           //   //copy to clipboard
//                           //   Clipboard.setData(
//                           //     ClipboardData(
//                           //       // text: widget.data[index]['address']));
//                           //       text: snapshot.data![index]['mainStreet'] ==
//                           //                   null ||
//                           //               snapshot.data![index]['mainStreet'] ==
//                           //                   ""
//                           //           ? '${snapshot.data![index]['street']} الاسكندرية'
//                           //           : '${snapshot.data[index]['street']} ${snapshot.data[index]['mainStreet']} الاسكندرية',
//                           //     ),
//                           //   );
//                           //   // Show a SnackBar to notify the user that the text is copied
//                           //   ScaffoldMessenger.of(context).showSnackBar(
//                           //     const SnackBar(
//                           //       backgroundColor: Colors.black26,
//                           //       content: Center(
//                           //         child: Text(
//                           //           'تم نسخ العنوان بنجاح',
//                           //           style: TextStyle(color: Colors.white),
//                           //         ),
//                           //       ),
//                           //     ),
//                           //   );
//                           //   Navigator.of(context)
//                           //       .pop(); // This closes the drawer
//                           // },
//                         );
//                       },
//                       physics: const NeverScrollableScrollPhysics(),
//                     );
//                   }
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }),
//           ],
//         ),
//       ),
//     );
//   }
// }