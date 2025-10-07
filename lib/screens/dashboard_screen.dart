// // lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';

import '../scada/models/station_data.dart';
import '../scada/services/api_service.dart';
import '../scada/widgets/charts/level_chart.dart';
import '../scada/widgets/charts/pressure_chart.dart';
import '../scada/widgets/charts/pumps_chart.dart';

class StationsDashboard extends StatefulWidget {
  const StationsDashboard({super.key});

  @override
  State<StationsDashboard> createState() => _StationsDashboardState();
}

class _StationsDashboardState extends State<StationsDashboard> {
  late Future<List<StationData>> _stationsFuture;

  @override
  void initState() {
    super.initState();
    _stationsFuture = ApiService().fetchStationsData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _stationsFuture = ApiService().fetchStationsData();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: _refreshData,
          ),
        ],
        centerTitle: true,
        elevation: 7,
        // backgroundColor: Colors.white,
        // iconTheme: const IconThemeData(
        //   color: Colors.indigo,
        //   size: 17,
        // ),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.indigo),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
      ),
      body: FutureBuilder<List<StationData>>(
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
            )),
            DataColumn(
                label: Text(
                  'Pressure',
                  style: TextStyle(color: Colors.indigo),
                ),
                numeric: true),
            DataColumn(
                label: Text(
                  'Raw Pumps',
                  style: TextStyle(color: Colors.indigo),
                ),
                numeric: true),
            DataColumn(
                label: Text(
                  'Treated Pumps',
                  style: TextStyle(color: Colors.indigo),
                ),
                numeric: true),
            DataColumn(
                label: Text(
                  'Level',
                  style: TextStyle(color: Colors.indigo),
                ),
                numeric: true),
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
