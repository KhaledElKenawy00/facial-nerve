import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:facial/service/database_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

class BleScanProviderTypeCLASSIC extends ChangeNotifier {
  // Bluetooth instance and stream controller
  final BluetoothClassic _bluetooth = BluetoothClassic();
  final StreamController<Map<String, dynamic>> _dataStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Device management
  List<Device> _pairedDevices = [];
  Device? _device;
  bool _isConnected = false;
  String buffer = "";

  // Sensor data and visualization
  List<FlSpot> emgHistory = [];
  int _xCounter = 0;

  // Database pagination
  int _currentPage = 1;
  final int _pageSize = 10;
  List<Map<String, dynamic>> _sensorData = [];
  int _totalRecords = 0;
  bool _isLoading = false;

  // Timer management
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _isTimerRunning = false;

  // Getters
  List<Device> get pairedDevices => _pairedDevices;
  Device? get device => _device;
  bool get isConnected => _isConnected;
  bool get isTimerRunning => _isTimerRunning;
  int get elapsedSeconds => _elapsedSeconds;
  List<Map<String, dynamic>> get sensorData => _sensorData;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalRecords => _totalRecords;
  bool get isLoading => _isLoading;
  Stream<Map<String, dynamic>> get dataStream => _dataStreamController.stream;

  String get formattedElapsedTime {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  BleScanProviderTypeCLASSIC() {
    fetchPairedDevices();
  }

  // Timer control methods
  void _startTimer() {
    if (_isTimerRunning) return;

    _isTimerRunning = true;
    _elapsedSeconds = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });
    notifyListeners();
  }

  void _stopTimer() {
    _isTimerRunning = false;
    _timer?.cancel();
    _elapsedSeconds = 0;
    notifyListeners();
  }

  // void _resetTimer() {
  //   _elapsedSeconds = 0;
  //   notifyListeners();
  // }

  // Device management methods
  Future<void> fetchPairedDevices() async {
    try {
      await _bluetooth.initPermissions();
      _pairedDevices = await _bluetooth.getPairedDevices();
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error fetching devices: $e");
    }
  }

  void selectDevice(Device selectedDevice) {
    _device = selectedDevice;
    notifyListeners();
  }

  // Connection management
  Future<void> connectToDevice() async {
    if (_device == null) {
      debugPrint('⚠️ No device selected to connect');
      return;
    }

    try {
      await _bluetooth.connect(
        _device!.address,
        "00001101-0000-1000-8000-00805f9b34fb",
      );
      _isConnected = true;
      _startTimer();
      notifyListeners();
      debugPrint('✅ Connected to ${_device!.address}');

      _setupDataListeners();
    } catch (e) {
      debugPrint('❌ Connection Failed: $e');
    }
  }

  void _setupDataListeners() {
    _bluetooth.onDeviceDataReceived().listen((Uint8List data) async {
      String receivedData = utf8.decode(data);
      buffer += receivedData;

      while (buffer.contains("}")) {
        int lastIndex = buffer.lastIndexOf("}");
        String completeMessage = buffer.substring(0, lastIndex + 1);
        buffer = buffer.substring(lastIndex + 1);

        try {
          Map<String, dynamic> jsonData = json.decode(completeMessage);
          jsonData['TimeOfSession'] = formattedElapsedTime;
          _dataStreamController.add(jsonData);
          await _storeSensorData(jsonData);

          // Update EMG visualization
          if (jsonData['emg_value'] != null) {
            addEmgValue(jsonData['emg_value'].toDouble());
          }
        } catch (e) {
          debugPrint('❌ JSON Parsing Error: $e');
        }
      }
    });

    _bluetooth.onDeviceStatusChanged().listen((int status) {
      if (status == 0) {
        debugPrint('🔌 Disconnected');
        _isConnected = false;
        _stopTimer();
        notifyListeners();
      }
    });
  }

  // EMG data handling
  void addEmgValue(double value) {
    emgHistory.add(FlSpot(_xCounter.toDouble(), value));
    if (emgHistory.length > 50) {
      emgHistory.removeAt(0);
    }
    _xCounter++;
  }

  // Database operations
  Future<void> _storeSensorData(Map<String, dynamic> data) async {
    try {
      final now = DateTime.now();
      final dataToInsert = {
        'value': data['emg_value'] ?? -1,
        'state': data['state'] ?? -1,
        'date': now.toIso8601String().split('T')[0],
        'time': now.toIso8601String().split('T')[1].split('.')[0],
      };
      await DatabaseHelper.instance.insertSensorData(dataToInsert);
    } catch (e) {
      debugPrint("❌ Error storing data: $e");
    }
  }

  Future<void> fetchSensorData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _sensorData = await DatabaseHelper.instance.getSensorDataPaged(
        _currentPage,
        _pageSize,
      );
      _totalRecords = await DatabaseHelper.instance.getTotalRecords();
    } catch (e) {
      debugPrint("❌ Error fetching data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Pagination control
  void nextPage() {
    if (_currentPage * _pageSize < _totalRecords) {
      _currentPage++;
      fetchSensorData();
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      fetchSensorData();
    }
  }

  void goToPage(int page) {
    if (page > 0 && page <= (_totalRecords / _pageSize).ceil()) {
      _currentPage = page;
      fetchSensorData();
    }
  }

  // Disconnection
  Future<void> disconnect() async {
    try {
      await _bluetooth.disconnect();
      _isConnected = false;
      _stopTimer();
      notifyListeners();
      debugPrint('🔌 Disconnected');
    } catch (e) {
      debugPrint('❌ Disconnection Error: $e');
    }
  }

  @override
  void dispose() {
    _dataStreamController.close();
    _stopTimer();
    super.dispose();
  }
}
