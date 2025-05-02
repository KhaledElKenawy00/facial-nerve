import 'package:facial/constant/dimentions.dart';
import 'package:facial/screen/avilable_device.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // 🔐 Hardcoded username & password (hashed)
  final String correctUsername = "admin";
  final String correctPasswordHash = "admin"; // Hash of "password"

  void _login() {
    String enteredUsername = _usernameController.text;
    String enteredPasswordHash = _passwordController.text;

    if (enteredUsername == correctUsername &&
        enteredPasswordHash == correctPasswordHash) {
      _showMessage("✅ تسجيل دخول ناجح!", Colors.green);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => AvailableDevicesScreen(),
        ),
      );
    } else {
      _showMessage("❌ اسم المستخدم أو كلمة المرور غير صحيحة!", Colors.red);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _requestBluetoothPermissions() async {
    if (await Permission.bluetooth.isDenied) {
      await Permission.bluetooth.request();
    }
    if (await Permission.bluetoothScan.isDenied) {
      await Permission.bluetoothScan.request();
    }
    if (await Permission.bluetoothConnect.isDenied) {
      await Permission.bluetoothConnect.request();
    }
    if (await Permission.bluetoothAdvertise.isDenied) {
      await Permission.bluetoothAdvertise.request();
    }
    if (await Permission.nearbyWifiDevices.isDenied) {
      await Permission.nearbyWifiDevices.request();
    }

    // Open App Settings if permissions are permanently denied
    if (await Permission.bluetooth.isPermanentlyDenied ||
        await Permission.bluetoothConnect.isPermanentlyDenied ||
        await Permission.bluetoothScan.isPermanentlyDenied ||
        await Permission.nearbyWifiDevices.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  void initState() {
    _requestBluetoothPermissions();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Padding(
        padding: EdgeInsets.all(Dimentions.hightPercentage(context, 3)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: Dimentions.hightPercentage(context, 8)),
              Image.asset("assets/nerve.png"),
              SizedBox(height: Dimentions.hightPercentage(context, 1)),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontFamily: "Lemonada",
                    fontSize: Dimentions.fontPercentage(context, 5),
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Please sign in to continue",
                  style: TextStyle(
                    fontFamily: "Lemonada",
                    fontSize: Dimentions.fontPercentage(context, 2.5),
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              SizedBox(height: Dimentions.hightPercentage(context, 3)),

              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.white),
                  labelStyle: TextStyle(color: Colors.white),

                  labelText: "UserName",

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Dimentions.radiusPercentage(context, 3),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Dimentions.hightPercentage(context, 3)),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.password, color: Colors.white),
                  labelStyle: TextStyle(color: Colors.white),
                  labelText: "Password",

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Dimentions.radiusPercentage(context, 3),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Dimentions.hightPercentage(context, 3)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Dimentions.radiusPercentage(context, 3),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: Dimentions.hightPercentage(context, 2),
                    horizontal: Dimentions.hightPercentage(context, 10),
                  ),
                ),
                onPressed: _login,
                child: const Text(
                  "Logain",
                  style: TextStyle(
                    fontFamily: "Lemonada",
                    fontSize: 20,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
