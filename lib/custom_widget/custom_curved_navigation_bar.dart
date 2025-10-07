import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class CustomCurvedNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final List<Widget> items;
  final ValueChanged<int> onTap;
  final Color backgroundColor;
  final Color buttonBackgroundColor;
  final Color color;
  final double height;

  const CustomCurvedNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.buttonBackgroundColor = Colors.blue,
    this.color = Colors.blueAccent,
    this.height = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: selectedIndex,
      items: items,
      onTap: onTap,
      backgroundColor: backgroundColor,
      buttonBackgroundColor: buttonBackgroundColor,
      color: color,
      height: height,
    );
  }
}



// import 'package:flutter/material.dart';
// import 'custom_curved_navigation_bar.dart'; // Replace with the actual file path

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: HomeScreen(),
//     );
//   }
// }

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;

//   final List<Widget> _pages = [
//     const Center(child: Text('Home')),
//     const Center(child: Text('Search')),
//     const Center(child: Text('Profile')),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: CustomCurvedNavigationBar(
//         selectedIndex: _selectedIndex,
//         items: const [
//           Icon(Icons.home, size: 30),
//           Icon(Icons.search, size: 30),
//           Icon(Icons.person, size: 30),
//         ],
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         backgroundColor: Colors.white,
//         buttonBackgroundColor: Colors.orange,
//         color: Colors.blueAccent,
//         height: 70.0,
//       ),
//     );
//   }
// }


//pub.dev custom_curved_navigation_bar

// import 'package:flutter/material.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';

// void main() => runApp(const MaterialApp(home: BottomNavBar()));

// class BottomNavBar extends StatefulWidget {
//   const BottomNavBar({super.key});

//   @override
//   _BottomNavBarState createState() => _BottomNavBarState();
// }

// class _BottomNavBarState extends State<BottomNavBar> {
//   int _page = 0;
//   final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         bottomNavigationBar: CurvedNavigationBar(
//           key: _bottomNavigationKey,
//           index: 0,
//           items: const <Widget>[
//             Icon(Icons.add, size: 30),
//             Icon(Icons.list, size: 30),
//             Icon(Icons.compare_arrows, size: 30),
//             Icon(Icons.call_split, size: 30),
//             Icon(Icons.perm_identity, size: 30),
//           ],
//           color: Colors.white,
//           buttonBackgroundColor: Colors.white,
//           backgroundColor: Colors.blueAccent,
//           animationCurve: Curves.easeInOut,
//           animationDuration: const Duration(milliseconds: 600),
//           onTap: (index) {
//             setState(() {
//               _page = index;
//             });
//           },
//           letIndexChange: (index) => true,
//         ),
//         body: Container(
//           color: Colors.blueAccent,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Text(_page.toString(), style: const TextStyle(fontSize: 160)),
//                 ElevatedButton(
//                   child: const Text('Go To Page of index 1'),
//                   onPressed: () {
//                     final CurvedNavigationBarState? navBarState =
//                         _bottomNavigationKey.currentState;
//                     navBarState?.setPage(1);
//                   },
//                 )
//               ],
//             ),
//           ),
//         ));
//   }
// }