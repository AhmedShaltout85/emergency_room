
// // lib/screens/dashboard_screen.dart

import 'package:emergency_room/custom_widget/no_internet_widget.dart';
import 'package:emergency_room/custom_widget/offline_banner.dart';
import 'package:emergency_room/scada/models/station_data.dart';
import 'package:emergency_room/scada/services/api_service.dart';
import 'package:emergency_room/scada/widgets/charts/level_chart.dart';
import 'package:emergency_room/scada/widgets/charts/pressure_chart.dart';
import 'package:emergency_room/scada/widgets/charts/pumps_chart.dart';
import 'package:emergency_room/services/connection_dialog_service.dart';
import 'package:emergency_room/services/connectivity_service.dart';
import 'package:flutter/material.dart';

class ScadaDashboardScreen extends StatefulWidget {
  const ScadaDashboardScreen({super.key});

  @override
  State<ScadaDashboardScreen> createState() => _ScadaDashboardScreenState();
}

class _ScadaDashboardScreenState extends State<ScadaDashboardScreen> {
  late Future<List<StationData>> _stationsFuture;
  bool _isOnline = true;
  bool _isOnlineChecked = false;

  // Tracks whether we've ever successfully loaded station data. Used to
  // decide whether a connectivity problem should be a blocking dialog
  // (nothing on screen yet) or just the OfflineBanner (data is already
  // visible, no need to interrupt the user on top of it).
  bool _hasLoadedData = false;

  @override
  void initState() {
    super.initState();
    _stationsFuture = _loadStations();
    _checkConnectivity();
  }

  /// Wraps the API call so we can track whether data has ever loaded
  /// successfully, independent of whether a later refresh fails.
  Future<List<StationData>> _loadStations() async {
    final data = await ApiService().fetchStationsData();
    if (mounted) {
      setState(() {
        _hasLoadedData = true;
      });
    }
    return data;
  }

  Future<void> _checkConnectivity() async {
    final online = await ConnectivityService.instance.hasConnection();
    if (!mounted) return;
    setState(() {
      _isOnline = online;
      _isOnlineChecked = true;
    });
  }

  Future<void> _refreshData() async {
    final online = await ConnectivityService.instance.hasConnection();
    if (!mounted) return;
    setState(() {
      _isOnline = online;
      _isOnlineChecked = true;
    });
    if (!online) {
      // Only block with a dialog if there's nothing on screen yet.
      // If we already have data loaded, _stationsFuture is left
      // untouched below (unchanged), so the existing table/charts
      // stay visible — the OfflineBanner alone is enough to signal
      // the refresh didn't happen, no need for a dialog on top of it.
      if (!_hasLoadedData) {
        await ConnectionDialogService.showNoInternetDialog(
          context,
          onRetry: _refreshData,
        );
      }
      return;
    }
    setState(() {
      _stationsFuture = _loadStations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OfflineBanner(visible: !_isOnline && _isOnlineChecked),
        Expanded(
          child: Container(
            color: Colors.indigo.shade50,
            child: FutureBuilder<List<StationData>>(
              future: _stationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  if (!_isOnline) {
                    // Guarded by ConnectionDialogService — safe to call
                    // on every rebuild of this branch, it will only
                    // actually show once app-wide.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ConnectionDialogService.showNoInternetDialog(
                        context,
                        onRetry: _refreshData,
                      );
                    });
                    return NoInternetWidget(onRetry: _refreshData);
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _refreshData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No station data available'));
                }

                final stations = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton.icon(
                          onPressed: _refreshData,
                          icon: const Icon(Icons.refresh, color: Colors.indigo),
                          label: const Text(
                            'تحديث التقرير',
                            style: TextStyle(color: Colors.indigo),
                          ),
                        ),
                      ),
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
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable(List<StationData> stations) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(
                label: Text('Station', style: TextStyle(color: Colors.indigo))),
            DataColumn(
                label: Text('Min Pressure', style: TextStyle(color: Colors.indigo)),
                numeric: true),
            DataColumn(
                label: Text('Pressure', style: TextStyle(color: Colors.indigo)),
                numeric: true),
            DataColumn(
                label: Text('Max Pressure', style: TextStyle(color: Colors.indigo)),
                numeric: true),
            DataColumn(
                label:
                    Text('Raw Pumps', style: TextStyle(color: Colors.indigo)),
                numeric: true),
            DataColumn(
                label: Text('Treated Pumps',
                    style: TextStyle(color: Colors.indigo)),
                numeric: true),
            DataColumn(
                label: Text('Level', style: TextStyle(color: Colors.indigo)),
                numeric: true),
            DataColumn(
                label: Text('Design Capacity',
                    style: TextStyle(color: Colors.indigo)),
                numeric: true),
            DataColumn(
                label: Text('Actual Capacity',
                    style: TextStyle(color: Colors.indigo)),
                numeric: true),
            DataColumn(
                label:
                    Text('Location', style: TextStyle(color: Colors.indigo))),
            DataColumn(
                label: Text('العكارة', style: TextStyle(color: Colors.indigo)),
                numeric: true),
            DataColumn(
                label: Text('الكلور المتبقى',
                    style: TextStyle(color: Colors.indigo)),
                numeric: true),
          ],
          rows: stations.map((station) {
            return DataRow(cells: [
              DataCell(Text(station.name,
                  style: const TextStyle(color: Colors.indigo))),
              DataCell(Text(station.minPressure?.toStringAsFixed(2) ?? '---',
                  style: const TextStyle(color: Colors.indigo))),
              DataCell(Text(station.pressure?.toStringAsFixed(2) ?? '---',
                  style: const TextStyle(color: Colors.indigo))),
              DataCell(Text(station.maxPressure?.toStringAsFixed(2) ?? '---',
                  style: const TextStyle(color: Colors.indigo))),
              DataCell(Text(station.rawPumps?.toString() ?? '---',
                  style: const TextStyle(color: Colors.indigo))),
              DataCell(Text(station.treatedPumps?.toString() ?? '---',
                  style: const TextStyle(color: Colors.indigo))),
              DataCell(Text(station.level?.toStringAsFixed(2) ?? '---',
                  style: const TextStyle(color: Colors.indigo))),
              DataCell(Text(station.desginCapacity?.toStringAsFixed(3) ?? '---',
                  style: const TextStyle(color: Colors.indigo))),
              DataCell(Text(station.actualCapacity?.toStringAsFixed(3) ?? '---',
                  style: const TextStyle(color: Colors.indigo))),
              DataCell(Text(station.location ?? '---',
                  style: const TextStyle(color: Colors.indigo))),
              DataCell(Text(station.turbidity?.toStringAsFixed(2) ?? '---',
                  style: const TextStyle(color: Colors.indigo))),
              DataCell(Text(
                  station.residualChlorine?.toStringAsFixed(2) ?? '---',
                  style: const TextStyle(color: Colors.indigo))),
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
