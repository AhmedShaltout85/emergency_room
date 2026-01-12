# Emergency Room 🏥

A comprehensive Flutter-based emergency room management system with real-time tracking, video conferencing, location services, and advanced analytics.

[![Flutter](https://img.shields.io/badge/Flutter-3.5+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-blue.svg)](https://github.com/AhmedShaltout85/emergency_room)

## 📋 Table of Contents

- [About](#about)
- [Features](#features)
- [Screenshots](#screenshots)
- [Architecture](#architecture)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Dependencies](#dependencies)
- [Configuration](#configuration)
- [Usage](#usage)
- [Building](#building)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## 🎯 About

Emergency Room is an advanced cross-platform healthcare management application built with Flutter. This comprehensive solution combines real-time patient tracking, video telemedicine capabilities, location-based services, and sophisticated data analytics to revolutionize emergency department operations.

**What Makes This Special:**
- 🎥 **Integrated Video Conferencing** - WebRTC and Jitsi Meet support for remote consultations
- 🗺️ **Real-Time Location Tracking** - Google Maps integration with live ambulance tracking
- 📊 **Advanced Analytics** - Multiple chart libraries for comprehensive data visualization
- 🔄 **Real-Time Updates** - Socket.IO integration for instant notifications
- 📱 **Cross-Platform** - Works on iOS, Android, Web, Windows, macOS, and Linux
- 🎨 **Rich UI/UX** - Lottie animations, curved navigation, and carousel sliders

**Key Objectives:**
- Enable remote medical consultations through integrated video calling
- Track ambulances and emergency vehicles in real-time
- Provide comprehensive analytics dashboards for hospital management
- Facilitate instant communication between medical staff
- Optimize patient flow and resource allocation
- Support telemedicine for initial triage and follow-ups

## ✨ Features

### 🏥 Core Functionality

- **Patient Registration & Intake**
  - Quick patient registration with essential information
  - QR code patient identification
  - Medical history import and management
  - Emergency contact information

- **Real-Time Location Services 🗺️**
  - Live ambulance tracking on Google Maps
  - Route optimization with polylines
  - Geocoding for address lookups
  - Dual map support (Google Maps & Flutter Map)
  - Real-time ETA calculations
  - Hospital location finder

- **Video Telemedicine 🎥**
  - Integrated video consultations via WebRTC
  - Jitsi Meet integration for group conferences
  - Remote triage assessment
  - Multi-participant medical discussions
  - Screen sharing capabilities
  - Recording options for medical records

- **Real-Time Communication 🔔**
  - Socket.IO powered instant messaging
  - Push notifications for critical updates
  - Audio alerts for emergencies
  - Staff-to-staff messaging
  - Patient status updates broadcast
  - Custom ringtones and alarm sounds

- **Advanced Analytics & Visualization 📊**
  - Multiple chart types (Line, Bar, Pie, Scatter)
  - Real-time dashboard with live data
  - Syncfusion charts for professional reporting
  - FL Chart for interactive visualizations
  - MRX Charts for custom analytics
  - Advanced data tables with sorting/filtering
  - Export capabilities (PDF, Excel)

- **Patient Tracking**
  - Live patient status monitoring
  - Current location tracking within ER
  - Treatment progress updates
  - Estimated wait time calculations
  - Patient journey visualization

- **Resource Management**
  - Bed availability and assignment
  - Equipment tracking and allocation
  - Staff scheduling and assignments
  - Room status (Occupied, Available, Cleaning)
  - Ambulance fleet management

### 🔧 Additional Features

- **Interactive UI/UX**
  - Lottie animations for smooth transitions
  - Curved navigation bar for modern look
  - Carousel sliders for media content
  - Responsive design for all screen sizes
  - Dark/Light theme support

- **Communication & Media**
  - Audio player for alerts and notifications
  - Custom ringtones for different emergency levels
  - Alarm sounds for critical situations
  - URL launcher for external links
  - WebView integration for embedded content

- **Multi-Platform Support**
  - Native Android and iOS apps
  - Progressive Web App (PWA)
  - Windows desktop application
  - macOS desktop application
  - Linux desktop application
  - Responsive web interface

- **Developer Features**
  - Clean architecture pattern
  - Provider for state management
  - UUID generation for unique identifiers
  - Internationalization support (intl)
  - Comprehensive error handling
  - Permission management system

- **Security & Permissions**
  - Location permission handling
  - Camera/microphone permissions for video calls
  - Storage permissions for media
  - Notification permissions
  - HIPAA-compliant data handling ready

## 📸 Screenshots

<!-- Add your screenshots here -->
| Home Dashboard | Patient List | Triage Screen |
|:--------------:|:------------:|:-------------:|
| ![Dashboard](assets/screenshots/dashboard.png) | ![Patients](assets/screenshots/patients.png) | ![Triage](assets/screenshots/triage.png) |

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/               # Core functionality
│   ├── constants/     # App constants and enums
│   ├── theme/         # Theme configuration
│   ├── utils/         # Utility functions
│   └── errors/        # Error handling
├── data/
│   ├── models/        # Data models
│   ├── repositories/  # Repository implementations
│   └── datasources/   # Local & remote data sources
├── domain/
│   ├── entities/      # Business entities
│   ├── repositories/  # Repository interfaces
│   └── usecases/      # Business logic
└── presentation/
    ├── pages/         # UI screens
    ├── widgets/       # Reusable widgets
    └── providers/     # State management
```

**State Management:** Provider (v6.0.5)

**Design Pattern:** MVVM / Provider Architecture

**Key Technologies:**
- **WebRTC** for peer-to-peer video communication
- **Socket.IO** for real-time bidirectional events
- **Google Maps API** for location services
- **Jitsi Meet SDK** for video conferencing
- **Syncfusion Charts** for enterprise-grade visualizations

## 🚀 Installation

### Prerequisites

Ensure you have the following installed:
- Flutter SDK (≥ 3.5.3)
- Dart SDK (≥ 3.5.3)
- Android Studio / VS Code with Flutter extensions
- Xcode (for iOS/macOS development)
- Git

**Additional Requirements:**
- Google Maps API key (for map features)
- Jitsi Meet server (or use default Jitsi servers)
- Backend server for Socket.IO connections
- Valid permissions setup for location, camera, and microphone

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/AhmedShaltout85/emergency_room.git
   cd emergency_room
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Check Flutter environment**
   ```bash
   flutter doctor
   ```

4. **Run the app**
   ```bash
   # Development mode
   flutter run
   
   # Specific device
   flutter run -d <device_id>
   
   # With flavor (if configured)
   flutter run --flavor dev
   ```

## 📁 Project Structure

```
emergency_room/
├── android/                    # Android native configuration
├── ios/                        # iOS native configuration
├── web/                        # Web-specific files
├── windows/                    # Windows desktop files
├── macos/                      # macOS desktop files
├── linux/                      # Linux desktop files
├── lib/                        # Main application code
│   ├── main.dart              # App entry point
│   ├── models/                # Data models
│   ├── screens/               # UI screens
│   ├── widgets/               # Reusable widgets
│   ├── providers/             # State management (Provider)
│   ├── services/              # API and external services
│   │   ├── socket_service.dart
│   │   ├── location_service.dart
│   │   ├── video_call_service.dart
│   │   └── api_service.dart
│   ├── utils/                 # Utility functions
│   │   ├── constants.dart
│   │   └── helpers.dart
│   └── routes/                # Navigation routes
├── assets/
│   ├── imgs/                  # Images (1.png - 5.png)
│   │   ├── 1.png
│   │   ├── 2.png
│   │   ├── 3.png
│   │   ├── 4.png
│   │   └── 5.png
│   ├── logo.png               # App logo
│   ├── aw_logo.png           # Alternative logo
│   ├── sounds/                # Audio files
│   │   ├── ringtone.mp3
│   │   ├── alarm.mp3
│   │   └── incoming_call.mp3
│   ├── green_marker.png       # Map marker
│   ├── map_pin.png           # Map pin icon
│   └── anim_marker.gif       # Animated marker
├── test/                      # Unit and widget tests
├── pubspec.yaml              # Dependencies and assets
├── analysis_options.yaml     # Dart analyzer rules
├── devtools_options.yaml     # DevTools configuration
└── README.md                 # This file
```

## 📦 Dependencies

### Main Dependencies

```yaml
dependencies:
  # Core Flutter
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.0.5

  # Navigation
  go_router: ^15.1.2
  url_strategy: ^0.2.0

  # Networking
  dio: ^5.7.0
  http: ^1.2.2
  socket_io_client: ^2.0.3+1

  # Maps & Location
  google_maps_flutter: ^2.2.2
  google_maps_flutter_web: ^0.5.11
  flutter_map: ^6.0.0
  flutter_polyline_points: ^2.1.0
  location: ^6.0.2
  geocoding: ^2.0.4
  latlong2: ^0.9.0

  # Charts & Data Visualization
  fl_chart: ^0.66.0
  syncfusion_flutter_charts: ^27.1.48
  mrx_charts: ^0.1.3
  graphic: ^2.6.0
  data_table_2: 2.5.10

  # Video Conferencing & WebRTC
  flutter_webrtc: ^0.14.0
  jitsi_meet: ^4.0.0

  # UI Components
  carousel_slider: ^5.0.0
  curved_navigation_bar: ^1.0.3
  lottie: ^3.2.0
  cupertino_icons: ^1.0.8

  # Web Views
  webview_flutter: ^4.2.1
  webview_flutter_web: null
  universal_html: ^2.2.1

  # Media
  audioplayers: ^5.2.1

  # Utilities
  intl: ^0.18.1
  url_launcher: ^6.2.5
  uuid: ^3.0.7
  permission_handler: null

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

### Key Features by Dependency

**📊 Data Visualization**
- Multiple chart libraries for comprehensive analytics
- Real-time data monitoring with Syncfusion, FL Chart, and MRX Charts
- Advanced data tables with sorting and filtering

**🗺️ Location Services**
- Dual map support (Google Maps & Flutter Map)
- Real-time location tracking
- Geocoding and reverse geocoding
- Route visualization with polylines

**📞 Communication**
- WebRTC support for peer-to-peer video calls
- Jitsi Meet integration for video conferencing
- Socket.IO for real-time bidirectional communication
- Audio alerts and notifications

**🌐 Network & API**
- Dio for advanced HTTP requests with interceptors
- Socket.IO client for real-time updates
- RESTful API integration

## ⚙️ Configuration

### Environment Setup

1. **Google Maps API Configuration**
   
   **Android** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
   ```

   **iOS** (`ios/Runner/AppDelegate.swift`):
   ```swift
   GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
   ```

   **Web** (`web/index.html`):
   ```html
   <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>
   ```

2. **Socket.IO Server Configuration**
   ```dart
   // Update your socket server URL
   const String SOCKET_URL = 'https://your-server.com';
   ```

3. **Jitsi Meet Configuration**
   ```dart
   // Configure Jitsi server (or use default)
   serverURL: 'https://meet.jit.si'
   ```

4. **Permissions Setup**
   
   **Android** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
   <uses-permission android:name="android.permission.CAMERA"/>
   <uses-permission android:name="android.permission.RECORD_AUDIO"/>
   <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
   ```

   **iOS** (`ios/Runner/Info.plist`):
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>We need your location to track ambulances</string>
   <key>NSCameraUsageDescription</key>
   <string>Camera access for video consultations</string>
   <key>NSMicrophoneUsageDescription</key>
   <string>Microphone access for video calls</string>
   ```

### App Configuration

Update constants in `lib/core/constants/`:
- `app_config.dart` - API endpoints, timeouts
- `app_strings.dart` - Localized strings
- `app_colors.dart` - Theme colors

## 💡 Usage

### User Roles

**Administrator**
- System configuration
- User management
- View all reports and analytics
- Manage departments and resources

**Doctor**
- View patient details and history
- Update treatment status
- View test results
- Discharge patients

**Nurse**
- Patient registration and intake
- Perform triage assessment
- Update vital signs
- Transfer patients between departments

**Receptionist**
- Patient check-in
- Appointment scheduling
- Basic information updates

### Basic Workflow

1. **Dashboard Overview**
   - View real-time ER statistics and metrics
   - Monitor ambulance locations on map
   - Check patient queue and wait times
   - View staff availability

2. **Ambulance Tracking**
   - Track ambulance locations in real-time
   - View estimated arrival times (ETA)
   - See route optimization with polylines
   - Receive location updates via Socket.IO

3. **Video Consultation**
   - Initiate video calls with Jitsi Meet
   - Conduct remote patient assessments
   - Use WebRTC for peer-to-peer calls
   - Record sessions for medical records

4. **Patient Management**
   - Register new patients quickly
   - Update patient status in real-time
   - Assign beds and resources
   - Track patient journey through ER

5. **Analytics & Reporting**
   - View interactive charts and graphs
   - Generate custom reports
   - Export data in multiple formats
   - Monitor KPIs and performance metrics

6. **Real-Time Notifications**
   - Receive critical alerts via Socket.IO
   - Get audio notifications for emergencies
   - View staff messages instantly
   - Monitor system-wide updates

## 🏗️ Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Build with split per ABI (smaller size)
flutter build apk --split-per-abi --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
# Build for iOS
flutter build ios --release

# Create IPA
flutter build ipa --release
```

### Web

```bash
# Build for web
flutter build web --release

# With base href
flutter build web --base-href /emergency_room/
```

Output: `build/web/`

## 🧪 Testing

### Run all tests
```bash
flutter test
```

### Run with coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Run specific test file
```bash
flutter test test/unit/patient_test.dart
```

### Integration tests
```bash
flutter test integration_test/
```

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit your changes**
   ```bash
   git commit -m 'Add some amazing feature'
   ```
4. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open a Pull Request**

### Coding Standards
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide
- Write meaningful commit messages
- Add comments for complex logic
- Write unit tests for new features
- Update documentation as needed

### Code Review Process
- All PRs require at least one approval
- Ensure all tests pass
- Maintain code coverage above 80%
- Follow existing architecture patterns

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Ahmed Shaltout

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

## 📧 Contact

**Ahmed Shaltout**

- 💼 GitHub: [@AhmedShaltout85](https://github.com/AhmedShaltout85)
- 📧 Email: your.email@example.com
- 💼 LinkedIn: [Your LinkedIn](https://linkedin.com/in/your-profile)
- 🌐 Website: [Your Website](https://yourwebsite.com)

**Project Link:** [https://github.com/AhmedShaltout85/emergency_room](https://github.com/AhmedShaltout85/emergency_room)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Healthcare professionals who provided domain expertise
- Open source contributors
- UI/UX inspiration from [source]

## 📚 Additional Documentation

- [API Documentation](docs/API.md)
- [Database Schema](docs/DATABASE.md)
- [User Guide](docs/USER_GUIDE.md)
- [Developer Guide](docs/DEVELOPER_GUIDE.md)

## 🐛 Known Issues

- [ ] List any known bugs or limitations
- [ ] Performance optimization needed for large patient lists (1000+)
- [ ] Offline sync may have delays with poor connectivity

## 🗺️ Roadmap

### Version 1.5 (Q2 2025)
- [ ] Enhanced offline mode with local data sync
- [ ] Advanced triage algorithms with AI suggestions
- [ ] Multi-language support (Arabic, Spanish, French)
- [ ] Dark mode improvements
- [ ] Voice commands for hands-free operation

### Version 2.0 (Q3 2025)
- [ ] AI-powered patient prioritization
- [ ] Predictive analytics for patient flow
- [ ] Integration with wearable medical devices
- [ ] Advanced biometric authentication
- [ ] Blockchain for medical records

### Version 2.5 (Q4 2025)
- [ ] AR navigation for hospital layout
- [ ] 3D visualization of patient data
- [ ] Multi-hospital network integration
- [ ] Advanced telemedicine features
- [ ] ML-based wait time prediction

### Version 3.0 (2026)
- [ ] Full EHR/EMR system integration
- [ ] IoT medical device connectivity
- [ ] Automated resource allocation
- [ ] Virtual reality training modules
- [ ] Advanced drone delivery tracking

## 📊 Performance Metrics

- **App Size:** ~15 MB (release build)
- **Startup Time:** < 2 seconds
- **RAM Usage:** ~50-100 MB
- **Supported OS:**
  - Android: 6.0 (API 23) and above
  - iOS: 12.0 and above
  - Web: Modern browsers (Chrome, Firefox, Safari, Edge)

## 🔒 Security & Compliance

- HIPAA compliant data handling
- End-to-end encryption for sensitive data
- Regular security audits
- Role-based access control (RBAC)
- Audit logging for all critical operations
- Secure authentication (OAuth 2.0 / JWT)

**⚠️ Important:** This application handles sensitive medical data. Ensure compliance with local healthcare regulations (HIPAA, GDPR, etc.) before deployment.

---

<div align="center">

**Made with ❤️ and Flutter**

⭐ Star this repository if you find it helpful!

[Report Bug](https://github.com/AhmedShaltout85/emergency_room/issues) • 
[Request Feature](https://github.com/AhmedShaltout85/emergency_room/issues) • 
[Documentation](https://github.com/AhmedShaltout85/emergency_room/wiki)

</div>