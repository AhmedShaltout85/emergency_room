// // // lib/screens/dashboard_screen.dart

// import 'package:flutter/material.dart';

// import '../scada/models/station_data.dart';
// import '../scada/services/api_service.dart';
// import '../scada/widgets/charts/level_chart.dart';
// import '../scada/widgets/charts/pressure_chart.dart';
// import '../scada/widgets/charts/pumps_chart.dart';

// class StationsDashboard extends StatefulWidget {
//   const StationsDashboard({super.key});

//   @override
//   State<StationsDashboard> createState() => _StationsDashboardState();
// }

// class _StationsDashboardState extends State<StationsDashboard> {
//   late Future<List<StationData>> _stationsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _stationsFuture = ApiService().fetchStationsData();
//   }

//   Future<void> _refreshData() async {
//     setState(() {
//       _stationsFuture = ApiService().fetchStationsData();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Scada Stations Dashboard',
//           style: TextStyle(color: Colors.indigo),
//         ),
//         actions: [
//           IconButton(
//             tooltip: "تحديث التقرير",
//             icon: const Icon(
//               Icons.refresh,
//               color: Colors.indigo,
//             ),
//             onPressed: _refreshData,
//           ),
//         ],
//         centerTitle: true,
//         elevation: 7,
//         // backgroundColor: Colors.white,
//         // iconTheme: const IconThemeData(
//         //   color: Colors.indigo,
//         //   size: 17,
//         // ),
//         // leading: IconButton(
//         //   icon: const Icon(Icons.arrow_back, color: Colors.indigo),
//         //   onPressed: () => Navigator.of(context).pop(),
//         // ),
//       ),
//       body: FutureBuilder<List<StationData>>(
//         future: _stationsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text('Error: ${snapshot.error}'),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _refreshData,
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No station data available'));
//           }

//           final stations = snapshot.data!;
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 _buildDataTable(stations),
//                 const SizedBox(height: 20),
//                 _buildChartCard(
//                   title: 'Pressure (bar)',
//                   child: SizedBox(
//                     height: 300,
//                     child: PressureChart(data: stations),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 _buildChartCard(
//                   title: 'Pumps Comparison',
//                   child: SizedBox(
//                     height: 300,
//                     child: PumpsChart(data: stations),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 _buildChartCard(
//                   title: 'Water Level',
//                   child: SizedBox(
//                     height: 300,
//                     child: LevelChart(data: stations),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDataTable(List<StationData> stations) {
//     return Card(
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: DataTable(
//           columns: const [
//             DataColumn(
//                 label: Text(
//               'Station',
//               style: TextStyle(color: Colors.indigo),
//             )),
//             DataColumn(
//                 label: Text(
//                   'Pressure',
//                   style: TextStyle(color: Colors.indigo),
//                 ),
//                 numeric: true),
//             DataColumn(
//                 label: Text(
//                   'Raw Pumps',
//                   style: TextStyle(color: Colors.indigo),
//                 ),
//                 numeric: true),
//             DataColumn(
//                 label: Text(
//                   'Treated Pumps',
//                   style: TextStyle(color: Colors.indigo),
//                 ),
//                 numeric: true),
//             DataColumn(
//                 label: Text(
//                   'Level',
//                   style: TextStyle(color: Colors.indigo),
//                 ),
//                 numeric: true),
//           ],
//           rows: stations.map((station) {
//             return DataRow(cells: [
//               DataCell(Text(
//                 station.name,
//                 style: const TextStyle(color: Colors.indigo),
//               )),
//               DataCell(Text(
//                 station.pressure?.toStringAsFixed(2) ?? '---',
//                 style: const TextStyle(color: Colors.indigo),
//               )),
//               DataCell(Text(
//                 station.rawPumps?.toString() ?? '---',
//                 style: const TextStyle(color: Colors.indigo),
//               )),
//               DataCell(Text(
//                 station.treatedPumps?.toString() ?? '---',
//                 style: const TextStyle(color: Colors.indigo),
//               )),
//               DataCell(Text(
//                 station.level?.toStringAsFixed(2) ?? '---',
//                 style: const TextStyle(color: Colors.indigo),
//               )),
//             ]);
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   Widget _buildChartCard({required String title, required Widget child}) {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               title,
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 16),
//             child,
//           ],
//         ),
//       ),
//     );
//   }
// }
// lib/screens/dashboard_screen.dart

import 'dart:developer';

import 'package:flutter/material.dart';
import '../custom_widget/no_internet_widget.dart';
import '../custom_widget/offline_banner.dart';
import '../scada/models/station_data.dart';
import '../scada/services/api_service.dart';
import '../scada/widgets/charts/level_chart.dart';
import '../scada/widgets/charts/pressure_chart.dart';
import '../scada/widgets/charts/pumps_chart.dart';
import '../services/connection_dialog_service.dart';
import '../services/connectivity_service.dart';

class StationsDashboard extends StatefulWidget {
  const StationsDashboard({super.key});

  @override
  State<StationsDashboard> createState() => _StationsDashboardState();
}

class _StationsDashboardState extends State<StationsDashboard> {
  late Future<List<StationData>> _stationsFuture;

  // --- Internet connection state ---
  bool _isLoading = true;
  bool _isOnline = true;
  bool _isOnlineChecked = false;
  bool _hasData = false;
  List<StationData> _cachedStations = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ==========================================================================
  // Unified data fetch — single connectivity check + single fetch pass,
  // matching AddressToCoordinates.fetchData() / ComplaintsReportsScreen.
  // Used for both the initial load and background/manual refreshes, so
  // there's only ever one place that decides whether to show the blocking
  // dialog.
  // ==========================================================================
  Future<void> _fetchData({bool showSuccessSnackbar = false}) async {
    if (!mounted) return;

    final online = await ConnectivityService.instance.hasConnection();
    if (!mounted) return;

    setState(() {
      _isOnline = online;
      _isOnlineChecked = true;
    });

    if (!online) {
      setState(() {
        _isLoading = false;
      });
      // Only interrupt with a blocking dialog when there's nothing useful
      // on screen yet. If we already have cached station data, the
      // OfflineBanner alone is enough.
      if (!_hasData) {
        await ConnectionDialogService.showNoInternetDialog(
          context,
          onRetry: _fetchData,
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _stationsFuture = ApiService().fetchStationsData();
    });

    try {
      final data = await _stationsFuture;
      if (!mounted) return;

      setState(() {
        _cachedStations = data;
        _hasData = data.isNotEmpty;
        _isLoading = false;
      });

      if (showSuccessSnackbar) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم تحديث البيانات بنجاح',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      log("Error fetching stations data: $e");
      if (!mounted) return;

      final onlineAgain = await ConnectivityService.instance.hasConnection();
      if (!mounted) return;

      setState(() {
        _isOnline = onlineAgain;
        _isLoading = false;
        // If we have cached data, keep it; otherwise mark as no data.
        if (_cachedStations.isEmpty) {
          _hasData = false;
        }
      });

      // Same rule as everywhere else: only block with a dialog if there's
      // no data to fall back on.
      if (!onlineAgain && !_hasData) {
        await ConnectionDialogService.showNoInternetDialog(
          context,
          onRetry: _fetchData,
        );
      } else if (showSuccessSnackbar) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء تحديث البيانات: $e',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Manual refresh (app bar button) is a direct user action, so it gets an
  // immediate, explicit notice if offline — same treatment as
  // AddressToCoordinates._getCoordinatesFromAddress and
  // LabsReportsDashboardScreen._onLabChanged — instead of a SnackBar.
  Future<void> _onRefreshPressed() async {
    final online = await ConnectivityService.instance.hasConnection();
    if (!mounted) return;

    if (!online) {
      setState(() {
        _isOnline = false;
        _isOnlineChecked = true;
      });
      ConnectionDialogService.showNoInternetDialog(context);
      return;
    }

    await _fetchData(showSuccessSnackbar: true);
  }

  @override
  Widget build(BuildContext context) {
    // Nothing useful is on screen only when we're offline AND we have no
    // cached station data to fall back on.
    final showNoInternet = !_isOnline && !_hasData && _isOnlineChecked;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scada Stations Dashboard',
          style: TextStyle(color: Colors.indigo),
        ),
        actions: [
          IconButton(
            tooltip: "تحديث التقرير",
            icon: const Icon(
              Icons.refresh,
              color: Colors.indigo,
            ),
            onPressed: _onRefreshPressed,
          ),
        ],
        centerTitle: true,
        elevation: 7,
      ),
      body: Column(
        children: [
          OfflineBanner(visible: !_isOnline && _isOnlineChecked),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : showNoInternet
                    ? NoInternetWidget(
                        onRetry: () {
                          setState(() {
                            _isLoading = true;
                            _hasData = false;
                          });
                          _fetchData();
                        },
                      )
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // If we have cached data, use it even if offline
    if (_cachedStations.isNotEmpty && !_isOnline) {
      return _buildDashboard(_cachedStations);
    }

    // If we're online but don't have data yet, use FutureBuilder
    return FutureBuilder<List<StationData>>(
      future: _stationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${snapshot.error}',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _onRefreshPressed,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No station data available',
              textDirection: TextDirection.rtl,
            ),
          );
        }

        // Cache the data when we get it
        final stations = snapshot.data!;
        if (_cachedStations.isEmpty && stations.isNotEmpty) {
          _cachedStations = stations;
          _hasData = true;
        }

        return _buildDashboard(stations);
      },
    );
  }

  Widget _buildDashboard(List<StationData> stations) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDataTable(stations),
          const SizedBox(height: 20),
          _buildChartCard(
            title: 'Pressure (bar)',
            child: SizedBox(
              height: 300,
              child: PressureChart(data: stations),
            ),
          ),
          const SizedBox(height: 20),
          _buildChartCard(
            title: 'Pumps Comparison',
            child: SizedBox(
              height: 300,
              child: PumpsChart(data: stations),
            ),
          ),
          const SizedBox(height: 20),
          _buildChartCard(
            title: 'Water Level',
            child: SizedBox(
              height: 300,
              child: LevelChart(data: stations),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<StationData> stations) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(
              label: Text(
                'Station',
                style: TextStyle(color: Colors.indigo),
              ),
            ),
            DataColumn(
              label: Text(
                'Pressure',
                style: TextStyle(color: Colors.indigo),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Raw Pumps',
                style: TextStyle(color: Colors.indigo),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Treated Pumps',
                style: TextStyle(color: Colors.indigo),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Level',
                style: TextStyle(color: Colors.indigo),
              ),
              numeric: true,
            ),
          ],
          rows: stations.map((station) {
            return DataRow(cells: [
              DataCell(Text(
                station.name,
                style: const TextStyle(color: Colors.indigo),
              )),
              DataCell(Text(
                station.pressure?.toStringAsFixed(2) ?? '---',
                style: const TextStyle(color: Colors.indigo),
              )),
              DataCell(Text(
                station.rawPumps?.toString() ?? '---',
                style: const TextStyle(color: Colors.indigo),
              )),
              DataCell(Text(
                station.treatedPumps?.toString() ?? '---',
                style: const TextStyle(color: Colors.indigo),
              )),
              DataCell(Text(
                station.level?.toStringAsFixed(2) ?? '---',
                style: const TextStyle(color: Colors.indigo),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChartCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
