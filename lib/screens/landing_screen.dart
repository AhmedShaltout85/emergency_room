import 'package:flutter/material.dart';

import '../custom_widget/custom_landing_body.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: CustomLandingBody(),
    );
  }
}
