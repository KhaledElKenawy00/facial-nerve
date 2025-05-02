import 'package:facial/provider/blue_classic_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SensorDataPage extends StatefulWidget {
  const SensorDataPage({Key? key}) : super(key: key);

  @override
  _SensorDataPageState createState() => _SensorDataPageState();
}

class _SensorDataPageState extends State<SensorDataPage> {
  @override
  void initState() {
    super.initState();
    // Load initial data when the page is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BleScanProviderTypeCLASSIC>(
        context,
        listen: false,
      );
      provider.fetchSensorData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Data History'),
        centerTitle: true,
      ),
      body: Consumer<BleScanProviderTypeCLASSIC>(
        builder: (context, provider, child) {
          if (provider.sensorData.isEmpty) {
            return const Center(child: Text('No sensor data available'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: provider.sensorData.length,
                  itemBuilder: (context, index) {
                    final data = provider.sensorData[index];
                    return _buildDataCard(data);
                  },
                ),
              ),
              _buildPaginationControls(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDataCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${data['date']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Time: ${data['time']}'),
            const SizedBox(height: 8),
            Text('EMG Value: ${data['value']}'),
            const SizedBox(height: 8),
            Text('State: ${data['state']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls(BleScanProviderTypeCLASSIC provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed:
                provider.currentPage > 1
                    ? () {
                      provider.previousPage();
                    }
                    : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Page ${provider.currentPage}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed:
                provider.sensorData.length == provider.pageSize
                    ? () {
                      provider.nextPage();
                    }
                    : null,
          ),
        ],
      ),
    );
  }
}
