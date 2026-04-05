import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationService {
  // Change these to your patient's actual home coordinates
  static const double homeLat   = 31.6340;
  static const double homeLng   = 74.8723;
  static const String homeLabel = 'Home';

  static Future<NavigationResult> takeMeHome() async {
    // Step 1: check location service
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return NavigationResult.locationServiceDisabled;
    }

    // Step 2: check permission
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return NavigationResult.permissionDenied;
    }

    // Step 3: get current position
    Position current;
    try {
      current = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      debugPrint(
          'Current position: ${current.latitude}, ${current.longitude}');
    } catch (e) {
      debugPrint('Position error: $e');
      return NavigationResult.locationUnavailable;
    }

    // Step 4: build map URLs
    // Apple Maps — always available on iOS, supports walking directions
    final appleMapsUrl = Uri.parse(
      'http://maps.apple.com/'
      '?saddr=${current.latitude},${current.longitude}'
      '&daddr=$homeLat,$homeLng'
      '&dirflg=w',        // w = walking
    );

    // Google Maps native app
    final googleMapsApp = Uri.parse(
      'comgooglemaps://'
      '?saddr=${current.latitude},${current.longitude}'
      '&daddr=$homeLat,$homeLng'
      '&directionsmode=walking',
    );

    // Google Maps browser fallback
    final googleMapsBrowser = Uri.parse(
      'https://www.google.com/maps/dir/'
      '?api=1'
      '&origin=${current.latitude},${current.longitude}'
      '&destination=$homeLat,$homeLng'
      '&travelmode=walking'
      '&dir_action=navigate',
    );

    if (Platform.isIOS) {
      // Try Apple Maps first — always installed on iPhone
      if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(
          appleMapsUrl,
          mode: LaunchMode.externalApplication,
        );
        return NavigationResult.success;
      }

      // Try Google Maps app
      if (await canLaunchUrl(googleMapsApp)) {
        await launchUrl(
          googleMapsApp,
          mode: LaunchMode.externalApplication,
        );
        return NavigationResult.success;
      }

      // Browser fallback
      if (await canLaunchUrl(googleMapsBrowser)) {
        await launchUrl(
          googleMapsBrowser,
          mode: LaunchMode.externalApplication,
        );
        return NavigationResult.success;
      }
    } else {
      // Android — try Google Maps app first
      if (await canLaunchUrl(googleMapsApp)) {
        await launchUrl(
          googleMapsApp,
          mode: LaunchMode.externalApplication,
        );
        return NavigationResult.success;
      }

      if (await canLaunchUrl(googleMapsBrowser)) {
        await launchUrl(
          googleMapsBrowser,
          mode: LaunchMode.externalApplication,
        );
        return NavigationResult.success;
      }

      // Apple Maps on iPad
      if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(
          appleMapsUrl,
          mode: LaunchMode.externalApplication,
        );
        return NavigationResult.success;
      }
    }

    return NavigationResult.mapsNotAvailable;
  }

  static Future<double?> distanceFromHome() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return null;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
      return Geolocator.distanceBetween(
        pos.latitude, pos.longitude, homeLat, homeLng,
      );
    } catch (e) {
      debugPrint('distanceFromHome error: $e');
      return null;
    }
  }
}

enum NavigationResult {
  success,
  locationServiceDisabled,
  permissionDenied,
  locationUnavailable,
  mapsNotAvailable,
}