import 'dart:developer';

import 'package:flutter/material.dart';

// import '../model/store_item_model.dart';
import '../network/remote/dio_network_repos.dart';

class IntegrationWithStoresGetAllQty extends StatefulWidget {
  final String storeName;
  const IntegrationWithStoresGetAllQty({
    super.key,
    required this.storeName,
  });

  @override
  State<IntegrationWithStoresGetAllQty> createState() =>
      _IntegrationWithStoresGetAllQtyState();
}

class _IntegrationWithStoresGetAllQtyState
    extends State<IntegrationWithStoresGetAllQty> {
  late Future getAllStoreItemsQty; //get all store items qty
  String itemNumber = '';
  String itemQty = '';
  String lastDateSended = '';
  String itemName = '';
  // List<StoreItemModel> items = []; // You'll get this from the API call

  @override
  void initState() {
    super.initState();
    setState(() {
      //execute tempStoreQty to get all store items
      // DioNetworkRepos().excuteTempStoreQty(widget.storeName);
      //get all store items qty
      getAllStoreItemsQty =
          DioNetworkRepos().getStoreAllItemsQtyFromStoreServer();
      getAllStoreItemsQty.then(
        (value) {
          value.forEach((element) {
            log("PRINTED STORE ALL DATA FROM UI single element: $element");
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "جرد : ${widget.storeName}",
          style: const TextStyle(
            color: Colors.indigo,
          ),
        ),
        centerTitle: true,
        elevation: 7,
        backgroundColor: Colors.white,
        // iconTheme: const IconThemeData(
        //   color: Colors.indigo,
        //   size: 17,
        // ),
      ),
      body: Row(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              width: 200,
              height: double.infinity,
            ),
          ),
          Expanded(
            flex: 2,
            child: SizedBox(
              child: FutureBuilder(
                  future: getAllStoreItemsQty,
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ListTile(
                                          title: Text(
                                            textAlign: TextAlign.right,
                                            snapshot.data![index]['itemName'],
                                            style: const TextStyle(
                                                color: Colors.indigo,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        child: ListTile(
                                          title: Text(
                                            textAlign: TextAlign.right,
                                            ": إسم الصنف",
                                            style: TextStyle(
                                                color: Colors.indigo,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ListTile(
                                          title: Text(
                                            textAlign: TextAlign.right,
                                            snapshot.data![index]['itemNumber']
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.indigo,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        child: ListTile(
                                          title: Text(
                                            textAlign: TextAlign.right,
                                            ": رقم العنصر",
                                            style: TextStyle(
                                                color: Colors.indigo,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ListTile(
                                          title: Text(
                                            textAlign: TextAlign.right,
                                            snapshot.data![index]['sbal']
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.indigo,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        child: ListTile(
                                          title: Text(
                                            textAlign: TextAlign.right,
                                            ": إجمالى الرصيد الحالى",
                                            style: TextStyle(
                                                color: Colors.indigo,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ListTile(
                                          title: Text(
                                            textAlign: TextAlign.right,
                                            snapshot.data![index]['lastDate']
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.indigo,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        child: ListTile(
                                          title: Text(
                                            textAlign: TextAlign.right,
                                            ": تاريخ أخر إرسال",
                                            style: TextStyle(
                                                color: Colors.indigo,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              //
                            },
                          );
                        },
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
            ),
          ),
          const Expanded(
            flex: 1,
            child: SizedBox(
              width: 200,
              height: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}
