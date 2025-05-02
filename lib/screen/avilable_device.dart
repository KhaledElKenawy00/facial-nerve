import 'package:facial/constant/dimentions.dart';
import 'package:facial/provider/blue_classic_provider.dart';
import 'package:facial/screen/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AvailableDevicesScreen extends StatefulWidget {
  const AvailableDevicesScreen({Key? key}) : super(key: key);

  @override
  State<AvailableDevicesScreen> createState() => _AvailableDevicesScreenState();
}

class _AvailableDevicesScreenState extends State<AvailableDevicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BleScanProviderTypeCLASSIC>().fetchPairedDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BleScanProviderTypeCLASSIC>();
    final pairedDevices = provider.pairedDevices;
    final isLoading = pairedDevices.isEmpty && !provider.isConnected;

    return Scaffold(
      appBar: AppBar(title: const Text('Available Devices')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: pairedDevices.length,
                itemBuilder: (context, index) {
                  final device = pairedDevices[index];
                  return InkWell(
                    onTap: () {
                      provider.selectDevice(device);
                      provider.connectToDevice().then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('connected to device successfully✅ '),
                          ),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      });
                    },
                    child: Container(
                      height: Dimentions.hightPercentage(context, 10),
                      width: Dimentions.widthPercentage(context, 100),
                      margin: EdgeInsets.symmetric(
                        vertical: Dimentions.hightPercentage(context, 3),
                        horizontal: Dimentions.widthPercentage(context, 5),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.yellowAccent.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.yellowAccent.withOpacity(0.5),
                          width: Dimentions.hightPercentage(context, 0.2),
                        ),
                        borderRadius: BorderRadius.circular(
                          Dimentions.radiusPercentage(context, 2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                device.name ?? 'Unknown Device',
                                style: TextStyle(
                                  fontFamily: "lemonada",
                                  color: Colors.black,
                                  fontSize: Dimentions.fontPercentage(
                                    context,
                                    3,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: Dimentions.hightPercentage(
                                  context,
                                  0.5,
                                ),
                              ),
                              Text(
                                device.address,
                                style: TextStyle(
                                  fontWeight: FontWeight.w100,
                                  fontFamily: "lemonada",
                                  color: Colors.blueGrey,
                                  fontSize: Dimentions.fontPercentage(
                                    context,
                                    3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Image.asset("assets/bluetooth.png"),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
