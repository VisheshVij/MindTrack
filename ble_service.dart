import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService extends ChangeNotifier {
  // Subscriptions
  StreamSubscription? _scanSub;
  StreamSubscription? _connSub;
  StreamSubscription? _nfcSub;
  StreamSubscription? _gpsSub;

  // UUIDs — must match exactly what is in your ESP32 firmware
  static const _serviceUuid  = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  static const _nfcCharUuid  = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';
  static const _gpsCharUuid  = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';

  BluetoothDevice? _device;
  bool   _connected = false;
  String _status    = 'Scanning for necklace...';

  bool   get connected => _connected;
  String get status    => _status;

  // Callbacks wired from main.dart
  void Function(String uid)?             onNfcTag;
  void Function(double lat, double lng)? onGpsUpdate;

  // ── Public entry point ────────────────────────────────────────
  void startScan() {
    _setStatus('Scanning for necklace...');

    // Make sure BT is on before scanning
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        _beginScan();
      } else {
        _setStatus('Please turn on Bluetooth');
      }
    });
  }

  void _beginScan() {
    _scanSub?.cancel();

    FlutterBluePlus.startScan(
      withServices: [Guid(_serviceUuid)],
      timeout: const Duration(seconds: 15),
    );

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        if (r.device.platformName == 'DementiaNecklace' ||
            r.advertisementData.serviceUuids
                .any((u) => u.str128.toLowerCase() == _serviceUuid)) {
          FlutterBluePlus.stopScan();
          _scanSub?.cancel();
          _connect(r.device);
          return;
        }
      }
    });

    // Restart scan when it times out and we are still disconnected
    FlutterBluePlus.isScanning.listen((scanning) {
      if (!scanning && !_connected) {
        Future.delayed(const Duration(seconds: 3), _beginScan);
      }
    });
  }

  Future<void> _connect(BluetoothDevice device) async {
    _device = device;
    _setStatus('Connecting...');

    try {
      await device.connect(autoConnect: false);
    } catch (e) {
      debugPrint('Connect error: $e');
      _setStatus('Connection failed — retrying...');
      Future.delayed(const Duration(seconds: 3), startScan);
      return;
    }

    // Listen for disconnection
    _connSub = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _connected = false;
        _nfcSub?.cancel();
        _gpsSub?.cancel();
        _setStatus('Disconnected — reconnecting...');
        Future.delayed(const Duration(seconds: 3), startScan);
      }
    });

    _connected = true;
    _setStatus('Necklace connected');
    notifyListeners();

    await _discoverAndSubscribe(device);
  }

  Future<void> _discoverAndSubscribe(BluetoothDevice device) async {
    List<BluetoothService> services;
    try {
      services = await device.discoverServices();
    } catch (e) {
      debugPrint('discoverServices error: $e');
      return;
    }

    for (final svc in services) {
      if (svc.uuid.str128.toLowerCase() != _serviceUuid) continue;

      for (final char in svc.characteristics) {
        final uuid = char.uuid.str128.toLowerCase();

        if (uuid == _nfcCharUuid) {
          await char.setNotifyValue(true);
          _nfcSub = char.onValueReceived.listen((bytes) {
            final uid = utf8.decode(bytes).trim();
            if (uid.isNotEmpty) {
              debugPrint('NFC tag received: $uid');
              onNfcTag?.call(uid);
            }
          });
          debugPrint('Subscribed to NFC characteristic');
        }

        if (uuid == _gpsCharUuid) {
          await char.setNotifyValue(true);
          _gpsSub = char.onValueReceived.listen((bytes) {
            final raw   = utf8.decode(bytes).trim();
            final parts = raw.split(',');
            if (parts.length == 2) {
              final lat = double.tryParse(parts[0]);
              final lng = double.tryParse(parts[1]);
              if (lat != null && lng != null) {
                onGpsUpdate?.call(lat, lng);
              }
            }
          });
          debugPrint('Subscribed to GPS characteristic');
        }
      }
    }
  }

  void _setStatus(String s) {
    _status = s;
    notifyListeners();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _connSub?.cancel();
    _nfcSub?.cancel();
    _gpsSub?.cancel();
    _device?.disconnect();
    super.dispose();
  }
}