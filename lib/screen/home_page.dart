import 'package:facial/constant/dimentions.dart';
import 'package:facial/provider/blue_classic_provider.dart';
import 'package:facial/screen/sensor_data_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bleProvider = Provider.of<BleScanProviderTypeCLASSIC>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_information),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SensorDataPage()),
              );
            },
          ),
        ],
        title: Center(
          child: Text(
            'Facial Nerve Recognition',
            style: TextStyle(
              fontFamily: "Lemonada",
              color: Colors.white,
              fontSize: Dimentions.fontPercentage(context, 3),
              fontWeight: FontWeight.w100,
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<Map<String, dynamic>>(
            stream: bleProvider.dataStream,
            builder: (context, snapshot) {
              double value = 0;
              String status = "";
              String sessionTime = "0 min";

              if (snapshot.hasData) {
                final data = snapshot.data!;
                value = data['emg_value']?.toDouble() ?? 0;
                status = data['state'] ?? "";
                sessionTime = data['TimeOfSession'] ?? "0 min";

                // Add to chart history
                bleProvider.addEmgValue(value);
              }

              return Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'This is your result',
                      style: TextStyle(
                        fontFamily: "Lemonada",
                        color: Colors.grey,
                        fontSize: Dimentions.fontPercentage(context, 3),
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                  ),
                  SizedBox(height: Dimentions.hightPercentage(context, 2)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCard(
                        context,
                        title: "Value",
                        image: "assets/elec-signal.png",
                        text: "$value uv",
                      ),
                      _buildCard(
                        context,
                        title: "Status",
                        image: "assets/status.png",
                        text: status,
                      ),
                    ],
                  ),
                  SizedBox(height: Dimentions.hightPercentage(context, 2)),
                  _buildCard(
                    context,
                    title: "Session",
                    image: "assets/time.png",
                    text: sessionTime,
                    isRounded: true,
                    fontSize: 1.5,
                    imageHeight: 10,
                    imageWidth: 15,
                  ),
                  SizedBox(height: Dimentions.hightPercentage(context, 2)),
                  SizedBox(
                    height: Dimentions.hightPercentage(context, 30),
                    child: LineChart(
                      LineChartData(
                        minY: -10,
                        maxY: 6000,
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget:
                                  (value, _) => Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 20,
                              getTitlesWidget:
                                  (value, _) => Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.blueGrey,
                            width: 0.5,
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: bleProvider.emgHistory,
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: Dimentions.hightPercentage(context, 1)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String image,
    required String text,
    bool isRounded = false,
    double fontSize = 2.5,
    double imageHeight = 15,
    double imageWidth = 20,
  }) {
    return Card(
      elevation: 15,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          Dimentions.radiusPercentage(context, isRounded ? 30 : 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: Dimentions.hightPercentage(context, 1)),
          Text(
            title,
            style: TextStyle(
              fontSize: Dimentions.fontPercentage(context, fontSize),
              fontFamily: "Lemonada",
              fontStyle: FontStyle.italic,
              color: Colors.cyan,
            ),
          ),
          Image.asset(
            image,
            height: Dimentions.hightPercentage(context, imageHeight),
            width: Dimentions.hightPercentage(context, imageWidth),
          ),
          SizedBox(height: Dimentions.hightPercentage(context, 1)),
          Text(
            text,
            style: TextStyle(
              fontSize: Dimentions.fontPercentage(context, fontSize),
              fontFamily: "Lemonada",
              fontStyle: FontStyle.italic,
              color: Colors.green,
            ),
          ),
          SizedBox(height: Dimentions.hightPercentage(context, 1)),
        ],
      ),
    );
  }
}
