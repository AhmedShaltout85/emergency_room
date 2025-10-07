import 'package:flutter/material.dart';

import '../model/grid_view_items.dart';
import '../view/chart_grid_view_item.dart';

class CustomGridView extends StatelessWidget {
  final List<GridItem> items;
  final int crossAxisCount;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final Function(GridItem)? onItemTap;

  const CustomGridView({
    Key? key,
    required this.items,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.mainAxisSpacing = 10.0,
    this.crossAxisSpacing = 10.0,
    this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildGridItem(context, item);
      },
    );
  }

  Widget _buildGridItem(BuildContext context, GridItem item) {
    return GestureDetector(
      onTap: () {
        if (onItemTap != null) {
          onItemTap!(item);
        } else {
          _navigateToDetailsPage(context, item);
        }
      },
      child: Card(
        elevation: 7,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon(
              //   item.icon,
              //   size: 40,
              //   color: Theme.of(context).primaryColor,
              // ),
              // const SizedBox(width: 8),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.indigo,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetailsPage(BuildContext context, GridItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChartGridViewItem(gridItem: item),
      ),
    );
  }
}
