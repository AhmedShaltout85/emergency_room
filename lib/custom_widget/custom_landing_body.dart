// // ignore_for_file: use_super_parameters

// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart' hide CarouselController;
// import 'package:go_router/go_router.dart';
// import 'package:emergency_room/model/carousel_list_items.dart';
// // import 'package:emergency_room/screens/login_screen.dart';
// // import 'package:emergency_room/utils/go_router.dart';

// import '../themes/themes.dart';

// class CustomLandingBody extends StatelessWidget {
//   const CustomLandingBody({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return kIsWeb
//         ? Row(
//             children: [
//               Expanded(
//                 flex: 1,
//                 child: Container(),
//               ),
//               Expanded(
//                 flex: 1,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(50.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             const Expanded(
//                               flex: 5,
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     "شركة مياه الشرب بالاسكندرية ",
//                                     softWrap: false,
//                                     style: TextStyle(
//                                       color: AppTheme.primTextColor,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                                   Text(
//                                     "قطاع التكنولوجيا والخدمات الرقمية",
//                                     softWrap: false,
//                                     style: TextStyle(
//                                       color: AppTheme.primTextColor,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                                   Text(
//                                     "إدراة البرمجيات",
//                                     softWrap: false,
//                                     style: TextStyle(
//                                       color: AppTheme.primTextColor,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Expanded(
//                               flex: 1,
//                               child: Image.asset('assets/aw_logo.png'),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 30,
//                       ),
//                       CarouselSlider(
//                         options: CarouselOptions(
//                           aspectRatio: 2,
//                           autoPlay: true,
//                           enlargeCenterPage: true,
//                         ),
//                         items: CarouselListItems.carouselItemsList
//                             .map(
//                               (item) => SizedBox(
//                                 child: Center(
//                                   child: Image.asset(
//                                     item.img,
//                                     fit: BoxFit.cover,
//                                     height: 1000,
//                                   ),
//                                 ),
//                               ),
//                             )
//                             .toList(),
//                       ),
//                       const SizedBox(
//                         height: 30,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(18.0),
//                         child: SizedBox(
//                           width: 250,
//                           height: 50,
//                           child: ElevatedButton(
//                             style: const ButtonStyle(
//                               backgroundColor:
//                                   WidgetStatePropertyAll(AppTheme.primColor),
//                             ),
//                             onPressed: () {
//                               // Navigator.push(
//                               //     context,
//                               //     MaterialPageRoute(
//                               //         builder: (_) => const LoginScreen()));
//                               context.go('/login');
//                             },
//                             child: const Text(
//                               'Login Screen',
//                               style: TextStyle(color: AppTheme.txtColor),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Expanded(
//                 flex: 1,
//                 child: Container(),
//               )
//             ],
//           )
//         : SingleChildScrollView(
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(50.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       const Expanded(
//                         flex: 5,
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Text(
//                               "شركة مياه الشرب بالاسكندرية ",
//                               style: TextStyle(
//                                 color: AppTheme.primTextColor,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 13,
//                               ),
//                             ),
//                             Text(
//                               "قطاع التكنولوجيا والخدمات الرقمية",
//                               style: TextStyle(
//                                 color: AppTheme.primTextColor,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 13,
//                               ),
//                             ),
//                             Text(
//                               "إدراة البرمجيات",
//                               style: TextStyle(
//                                 color: AppTheme.primTextColor,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         flex: 1,
//                         child: Image.asset('assets/aw_logo.png'),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 30,
//                 ),
//                 CarouselSlider(
//                   options: CarouselOptions(
//                     aspectRatio: 2,
//                     autoPlay: true,
//                     enlargeCenterPage: true,
//                   ),
//                   items: CarouselListItems.carouselItemsList
//                       .map(
//                         (item) => SizedBox(
//                           child: Center(
//                             child: Image.asset(
//                               item.img,
//                               fit: BoxFit.cover,
//                               height: 1000,
//                             ),
//                           ),
//                         ),
//                       )
//                       .toList(),
//                 ),
//                 const SizedBox(
//                   height: 30,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(18.0),
//                   child: SizedBox(
//                     width: 250,
//                     height: 50,
//                     child: ElevatedButton(
//                       style: const ButtonStyle(
//                         backgroundColor:
//                             WidgetStatePropertyAll(AppTheme.primColor),
//                       ),
//                       onPressed: () {
//                         // Navigator.push(
//                         //     context,
//                         //     MaterialPageRoute(
//                         //         builder: (_) => const LoginScreen()));
//                         context.go('/login');
//                       },
//                       child: const Text(
//                         'Login Screen',
//                         style: TextStyle(color: AppTheme.txtColor),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//   }
// }
// // }
// ignore_for_file: use_super_parameters

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:go_router/go_router.dart';
import 'package:emergency_room/model/carousel_list_items.dart';
import 'package:emergency_room/services/connectivity_service.dart';
// import 'package:emergency_room/screens/login_screen.dart';
// import 'package:emergency_room/utils/go_router.dart';

import '../themes/themes.dart';

class CustomLandingBody extends StatelessWidget {
  const CustomLandingBody({
    Key? key,
  }) : super(key: key);

  // Helper method to handle login navigation with internet check
  Future<void> _handleLoginNavigation(BuildContext context) async {
    // Optional: Check internet before navigating to login
    final hasConnection = await ConnectivityService.instance.hasConnection();

    if (!hasConnection) {
      // Show a snackbar or dialog if no internet
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لا يوجد إتصال بالإنترنت. يرجى التحقق من الإتصال والمحاولة مرة أخرى.',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Navigate to login if internet is available
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              flex: 5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "شركة مياه الشرب بالاسكندرية ",
                                    softWrap: false,
                                    style: TextStyle(
                                      color: AppTheme.primTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    "قطاع التكنولوجيا والخدمات الرقمية",
                                    softWrap: false,
                                    style: TextStyle(
                                      color: AppTheme.primTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    "إدراة البرمجيات",
                                    softWrap: false,
                                    style: TextStyle(
                                      color: AppTheme.primTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Image.asset('assets/aw_logo.png'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      CarouselSlider(
                        options: CarouselOptions(
                          aspectRatio: 2,
                          autoPlay: true,
                          enlargeCenterPage: true,
                        ),
                        items: CarouselListItems.carouselItemsList
                            .map(
                              (item) => SizedBox(
                                child: Center(
                                  child: Image.asset(
                                    item.img,
                                    fit: BoxFit.cover,
                                    height: 1000,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: SizedBox(
                          width: 250,
                          height: 50,
                          child: ElevatedButton(
                            style: const ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(AppTheme.primColor),
                            ),
                            onPressed: () => _handleLoginNavigation(context),
                            child: const Text(
                              'متابعة لتسجيل الدخول',
                              style: TextStyle(color: AppTheme.txtColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              )
            ],
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "شركة مياه الشرب بالاسكندرية ",
                              style: TextStyle(
                                color: AppTheme.primTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              "قطاع التكنولوجيا والخدمات الرقمية",
                              style: TextStyle(
                                color: AppTheme.primTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              "إدراة البرمجيات",
                              style: TextStyle(
                                color: AppTheme.primTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Image.asset('assets/aw_logo.png'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                CarouselSlider(
                  options: CarouselOptions(
                    aspectRatio: 2,
                    autoPlay: true,
                    enlargeCenterPage: true,
                  ),
                  items: CarouselListItems.carouselItemsList
                      .map(
                        (item) => SizedBox(
                          child: Center(
                            child: Image.asset(
                              item.img,
                              fit: BoxFit.cover,
                              height: 1000,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SizedBox(
                    width: 250,
                    height: 50,
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(AppTheme.primColor),
                      ),
                      onPressed: () => _handleLoginNavigation(context),
                      child: const Text(
                        'متابعة لتسجيل الدخول',
                        style: TextStyle(color: AppTheme.txtColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
