import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'notification_service.dart';

class GeofenceService extends ChangeNotifier {
  final _notif = NotificationService();

  // ── Set your patient's home coordinates here ──────────────────
  static const double _homeLat      = 31.6340;   // e.g. Amritsar
  static const double _homeLng      = 74.8723;
  static const double _radiusMeters = 200;
  // ──────────────────────────────────────────────────────────────

  bool   isInsideFence  = true;
  double distanceFromHome = 0;
  bool   _wasInside     = true;

  Future<void> startMonitoring() async {
    await _checkPermissions();
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
      ),
    ).listen(_onPosition);
  }

  Future<void> _checkPermissions() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
  }

  // Called by BleService when GPS arrives from the necklace
  void updatePosition(double lat, double lng) {
    _onPosition(Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    ));
  }

  void _onPosition(Position pos) {
    distanceFromHome = Geolocator.distanceBetween(
      pos.latitude, pos.longitude, _homeLat, _homeLng,
    );
    isInsideFence = distanceFromHome <= _radiusMeters;

    if (_wasInside && !isInsideFence) {
      _notif.showHighPriority(
        title: 'Safety Alert',
        body: 'Patient has left the safe zone. '
            '${distanceFromHome.toStringAsFixed(0)} m from home.',
      );
      _notif.showPatientReminder(
        'You are leaving home. Did you turn off the gas? Do you have your keys?',
      );
    }

    if (!_wasInside && isInsideFence) {
      _notif.showInfo('Patient has returned home safely.');
    }

    _wasInside = isInsideFence;
    notifyListeners();
  }
}