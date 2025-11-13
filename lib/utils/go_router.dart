import 'package:emergency_room/labs/view/dashboard_charts_list.dart';
import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

import 'package:go_router/go_router.dart';
import 'package:emergency_room/common_services/webrtc_config/video_call_screen.dart';
// import 'package:emergency_room/custom_widget/custom_web_view_iframe.dart';
import 'package:emergency_room/screens/caller_mobile_screen.dart';
import 'package:emergency_room/screens/caller_screen.dart';
import 'package:emergency_room/screens/dashboard_screen.dart';
import 'package:emergency_room/screens/gis_map.dart';
import 'package:emergency_room/screens/handasah_screen.dart';
import 'package:emergency_room/screens/integration_with_stores_get_all_qty.dart';
import 'package:emergency_room/screens/landing_screen.dart';
import 'package:emergency_room/screens/login_screen.dart';
import 'package:emergency_room/screens/mobile_emergency_room_screen.dart';
import 'package:emergency_room/screens/receiver_mobile_screen.dart';
import 'package:emergency_room/screens/receiver_screen.dart';
import 'package:emergency_room/screens/report_screen.dart';
import 'package:emergency_room/screens/request_tool_for_address_screen.dart';
import 'package:emergency_room/screens/system_admin_screen.dart';
import 'package:emergency_room/screens/tracking.dart';
import 'package:emergency_room/screens/user_request_tools.dart';
import 'package:emergency_room/screens/user_screen.dart';

import '../screens/address_to_coordinates_web.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/emergency',
      builder: (context, state) => const AddressToCoordinates(),
    ),
    GoRoute(
      path: '/handasah',
      builder: (context, state) => const HandasahScreen(),
    ),
    GoRoute(
      path: '/technician',
      builder: (context, state) => const UserScreen(),
    ),
    GoRoute(
      path: '/system-admin',
      builder: (context, state) => const SystemAdminScreen(),
    ),
    GoRoute(
      path: '/mobile-emergency-room',
      builder: (context, state) => const MobileEmergencyRoomScreen(),
    ),
    GoRoute(
      path: '/gis-map',
      builder: (context, state) => const GisMap(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const StationsDashboard(),
    ),
    GoRoute(
      path: '/report',
      builder: (context, state) => const ReportScreen(),
    ),
    GoRoute(
      path: '/caller',
      builder: (context, state) => const CallerScreen(),
    ),
    GoRoute(
      path: '/receiver',
      builder: (context, state) => const ReceiverScreen(),
    ),
    GoRoute(
      path: '/mobile-caller/:addressTitle',
      builder: (context, state) {
        final addressTitle = state.pathParameters['addressTitle']!;
        return CallerMobileScreen(addressTitle: addressTitle);
      },
    ),
    GoRoute(
      path: '/mobile-receiver/:addressTitle',
      pageBuilder: (context, state) {
        final addressTitle = state.pathParameters['addressTitle']!;
        return MaterialPage(
          key: state.pageKey,
          child: ReceiverMobileScreen(
            addressTitle: addressTitle,
          ),
        );
      },
    ),
    GoRoute(
      path: '/webrtc-mob/:roomId',
      pageBuilder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        return MaterialPage(
          key: state.pageKey,
          child: VideoCallScreen(roomId: roomId),
        );
      },
    ),
    GoRoute(
      path: '/tracking/:address/:latitude/:longitude/:technicianName',
      builder: (context, state) {
        final address = state.pathParameters['address']!;
        final latitude = state.pathParameters['latitude']!;
        final longitude = state.pathParameters['longitude']!;
        final technicianName = state.pathParameters['technicianName']!;
        return Tracking(
          address: address,
          latitude: latitude,
          longitude: longitude,
          technicianName: technicianName,
        );
      },
    ),
    GoRoute(
      path: '/user-request-tool/:handasahName/:address/:technicianName',
      builder: (context, state) {
        final handasahName = state.pathParameters['handasahName']!;
        final address = state.pathParameters['address']!;
        final technicianName = state.pathParameters['technicianName']!;
        return UserRequestTools(
          handasahName: handasahName,
          address: address,
          technicianName: technicianName,
        );
      },
    ),
    GoRoute(
      path: '/request-tool-address/:address/:handasahName',
      pageBuilder: (context, state) {
        final address = state.pathParameters['address']!;
        final handasahName = state.pathParameters['handasahName']!;
        return MaterialPage(
          key: state
              .pageKey, //this way to preserve the state of the page to be updated
          child: RequestToolForAddressScreen(
              address: address, handasahName: handasahName),
        );
      },
    ),

    GoRoute(
      path: '/integrate-with-stores/:storeName',
      pageBuilder: (context, state) {
        final storeName = state.pathParameters['storeName']!;
        return MaterialPage(
          key: state.pageKey,
          child: IntegrationWithStoresGetAllQty(
            storeName: storeName,
          ),
        );
      },
    ),
    GoRoute(
      path: '/integration-with-labs',
      builder: (context, state) => const DashboardChartsList(),
    )

    // GoRoute(
    //   path: '/web-view-iframe/:url',
    //   builder: (context, state) {
    //     final url = state.pathParameters['url']!;
    //     return IframeScreen(
    //       url: url,
    //     );
    //   },
    // ),
    // GoRoute(
    //   path: '/agora',
    //   builder: (context, state) => const AgoraVideoCall(),
    // ),
  ],
);

//named arguments
// GoRoute(
//   path: '/product/:category/:productId',
//   builder: (context, state) {
//     final category = state.pathParameters['category']!;
//     final productId = state.pathParameters['productId']!;
//     return ProductPage(category: category, productId: productId);
//   },
// ),

// // In MaterialApp:
// MaterialApp.router(
//   routerConfig: router,
// );

// // To navigate:
// context.go('/myPage'); // or context.push('/myPage')

// final GoRouter _router = GoRouter(
//   routes: <RouteBase>[
//     GoRoute(
//       path: '/',
//       builder: (BuildContext context, GoRouterState state) {
//         return const HomeScreen();
//       },
//       routes: <RouteBase>[
//         GoRoute(
//           path: 'details',
//           builder: (BuildContext context, GoRouterState state) {
//             return const DetailsScreen();
//           },
//         ),
//       ],
//     ),
//   ],
// );
