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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
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

