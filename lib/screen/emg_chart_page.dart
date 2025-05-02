import 'dart:async';
import 'package:facial/provider/blue_classic_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmgChartPage extends StatefulWidget {
  @override
  State<EmgChartPage> createState() => _EmgChartPageState();
}

class _EmgChartPageState extends State<EmgChartPage> {
  List<FlSpot> emgData = [];
  int xIndex = 0;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();

    // Listen to EMG data from the BLE provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BleScanProviderTypeCLASSIC>(
        context,
        listen: false,
      );
      _subscription = provider.dataStream.listen((data) {
        final value = data['value']; // Replace with actual field if different
        if (value is int || value is double) {
          setState(() {
            emgData.add(FlSpot(xIndex.toDouble(), value.toDouble()));
            if (emgData.length > 100)
              emgData.removeAt(0); // Keep max 100 points
            xIndex++;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double minY = -100;
    double maxY = 900;

    if (emgData.isNotEmpty) {
      final minVal = emgData.map((e) => e.y).reduce((a, b) => a < b ? a : b);
      final maxVal = emgData.map((e) => e.y).reduce((a, b) => a > b ? a : b);
      minY = minVal < -100 ? minVal : -100;
      maxY = maxVal > 900 ? maxVal : 900;
    }

    return Scaffold(
      appBar: AppBar(title: Text("EMG Signal Chart")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget:
                      (value, _) => Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: 12),
                      ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget:
                      (value, _) => Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: 12),
                      ),
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.blue, width: 2),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: emgData.isEmpty ? [FlSpot(0, 0)] : emgData,
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
