import 'package:flutter/material.dart';

import '../model/grid_view_items.dart';

class ChartGridViewItem extends StatelessWidget {
  final GridItem gridItem;

  const ChartGridViewItem({Key? key, required this.gridItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gridItem.title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon(
            //   gridItem.icon,
            //   size: 80,
            //   color: Theme.of(context).primaryColor,
            // ),
            const SizedBox(height: 20),
            Text(
              gridItem.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
