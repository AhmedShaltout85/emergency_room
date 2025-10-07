import 'dart:developer';

import 'package:emergency_room/screens/address_details.dart';
import 'package:flutter/material.dart';

// import 'package:pick_location/screens/agora_video_call.dart';
// import 'package:pick_location/screens/tracking.dart';

import '../custom_widget/custom_browser_redirect.dart';
import '../custom_widget/custom_draggable_scrollable_sheet.dart';
import '../network/remote/dio_network_repos.dart';

class DraggableScrollableSheetScreen extends StatefulWidget {
  final Future getLocs;

  const DraggableScrollableSheetScreen({super.key, required this.getLocs});

  @override
  State<DraggableScrollableSheetScreen> createState() =>
      _DraggableScrollableSheetScreenState();
}

class _DraggableScrollableSheetScreenState
    extends State<DraggableScrollableSheetScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomDraggableScrollableSheet(
      minExtent: 0.4,
      maxExtent: 0.6,
      builder: (context, extent) {
        return Column(
          children: [
            Container(
              height: 30,
              alignment: Alignment.center,
              child: const Icon(Icons.drag_handle),
            ),
            Expanded(
              child: FutureBuilder(
                  future: widget.getLocs,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            child: Card(
                              child: Column(
                                children: [
                                  ListTile(
                                    title:
                                        Text(snapshot.data![index]['address']),
                                    subtitle: snapshot.data![index]
                                                    ['handasah_name'] !=
                                                "free" ||
                                            snapshot.data![index]
                                                    ['technical_name'] !=
                                                "free"
                                        ? Text(
                                            '${snapshot.data![index]['handasah_name']}, (${snapshot.data![index]['technical_name']})')
                                        : const SizedBox.shrink(),
                                  ),
                                  // ListTile(
                                  //         title: Text(
                                  //     "(${snapshot.data![index]['latitude']},${snapshot.data![index]['longitude']})"),
                                  //       ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          log("Start Gis Map ${snapshot.data![index]['gis_url']}");
                                          //open in iframe webview in web app
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (context) =>
                                          //         IframeScreen(
                                          //             url: snapshot
                                          //                     .data![index]
                                          //                 ['gis_url']),
                                          //   ),
                                          // );

                                          //open in browser
                                          CustomBrowserRedirect.openInBrowser(
                                            snapshot.data![index]['gis_url'],
                                          );
                                          //open in webview
                                          //   Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //       builder: (context) =>
                                          //           CustomWebView(
                                          //         title: 'GIS Map webview',
                                          //         url: snapshot.data![index]
                                          //             ['gis_url'],
                                          //       ),
                                          //     ),
                                          //   );
                                        },
                                        icon: const Icon(
                                          Icons.open_in_browser,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          log("Start Video Call ${snapshot.data![index]['id']}");
                                          //open video call
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (context) =>
                                          //         AgoraVideoCall(
                                          //       title:
                                          //           '${snapshot.data![index]['address']}',
                                          //     ),
                                          //   ),
                                          // );
                                        },
                                        icon: const Icon(
                                          Icons.video_call,
                                          color: Colors.green,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          log("Start Traking ${snapshot.data![index]['id']}");
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (context) =>
                                          //         const Tracking(),
                                          //   ),
                                          // );
                                        },
                                        icon: const Icon(
                                          Icons.location_on,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            //update is_finished(close broken locations)
                                            DioNetworkRepos()
                                                .updateLocAddIsFinished(
                                                    snapshot.data![index]
                                                        ['address'],
                                                    1);
                                          });
                                          // log(
                                          //     "Start Traking ${snapshot.data![index]['id']}");
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (context) =>
                                          //         const Tracking(),
                                          //   ),
                                          // );
                                        },
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              log("${snapshot.data[index]['id']}");
                              // open address details
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddressDetails(),
                                ),
                              );
                            },
                          );
                        },
                        // physics: const NeverScrollableScrollPhysics(),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
            ),
          ],
        );
      },
    );
  }
}
