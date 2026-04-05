import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import '../services/notification_service.dart';

class FindHomeScreen extends StatefulWidget {
  const FindHomeScreen({super.key});

  @override
  State<FindHomeScreen> createState() => _FindHomeScreenState();
}

class _FindHomeScreenState extends State<FindHomeScreen> {
  double? _distanceMetres;
  bool _loadingDistance = false;
  bool _navigating      = false;
  String _statusMessage = 'Press the button below to find your way home.';

  @override
  void initState() {
    super.initState();
    _refreshDistance();
  }

  // ── Helpers ────────────────────────────────────────────────────

  bool get _isHome =>
      _distanceMetres != null && _distanceMetres! < 50;

  String _formatDistance(double metres) {
    if (metres < 1000) {
      return '${metres.toStringAsFixed(0)} metres';
    }
    return '${(metres / 1000).toStringAsFixed(1)} km';
  }

  // ── Actions ───────────────────────────────────────────────────

  Future<void> _refreshDistance() async {
    setState(() => _loadingDistance = true);

    final dist = await NavigationService.distanceFromHome();

    if (!mounted) return;
    setState(() {
      _distanceMetres  = dist;
      _loadingDistance = false;

      if (dist == null) {
        _statusMessage =
            'Could not get your location.\nPlease try again.';
      } else if (dist < 50) {
        _statusMessage = 'You are already home!';
      } else {
        _statusMessage =
            'You are ${_formatDistance(dist)} away from home.';
      }
    });
  }

  Future<void> _startNavigation() async {
    setState(() => _navigating = true);

    final result = await NavigationService.takeMeHome();

    if (!mounted) return;
    setState(() => _navigating = false);

    switch (result) {
      case NavigationResult.success:
        break; // Maps opened — nothing else to do

      case NavigationResult.locationServiceDisabled:
        _showError(
          'Location is turned off',
          'Please go to Settings → Privacy → Location Services '
          'and turn it on, then try again.',
        );
        break;

      case NavigationResult.permissionDenied:
        _showError(
          'Location permission needed',
          'Please go to Settings → Privacy → Location Services → '
          'Aura App and choose "While Using the App".',
        );
        break;

      case NavigationResult.locationUnavailable:
        _showError(
          'Could not find your location',
          'Please go outside where there is a clear sky '
          'and try again.',
        );
        break;

      case NavigationResult.mapsNotAvailable:
        _showError(
          'Maps app not found',
          'Please make sure Apple Maps or Google Maps '
          'is installed on your phone.',
        );
        break;
    }
  }

  void _callCaregiver() {
    NotificationService().showHighPriority(
      title: 'Help needed',
      body: 'Patient pressed "Call my caregiver" on the Find Home screen.',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Caregiver notified',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Your caregiver has been notified and will '
          'come to help you soon.\n\nDo not worry — you are safe.',
          style: TextStyle(fontSize: 20, height: 1.5),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('OK',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold)),
        content: Text(message,
            style: const TextStyle(fontSize: 18, height: 1.5)),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('OK',
                  style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        toolbarHeight: 70,
        title: const Text(
          'Find My Way Home',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ── Distance card ───────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: _isHome
                    ? Colors.green.shade600
                    : Colors.indigo.shade700,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Icon(
                    _isHome ? Icons.home : Icons.location_on,
                    color: Colors.white,
                    size: 72,
                  ),
                  const SizedBox(height: 16),
                  if (_loadingDistance)
                    const CircularProgressIndicator(
                        color: Colors.white)
                  else
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  if (!_isHome &&
                      _distanceMetres != null &&
                      !_loadingDistance) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Follow the map to get home safely.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 17,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Take me home button ─────────────────────────────
            if (!_isHome)
              _BigButton(
                label: _navigating ? 'Opening Maps...' : 'Take me home',
                icon: _navigating ? Icons.hourglass_top : Icons.home,
                color: _navigating
                    ? Colors.grey.shade500
                    : Colors.green.shade700,
                onTap: _navigating ? null : _startNavigation,
                height: 120,
                fontSize: 28,
                iconSize: 52,
              )
            else
              _BigButton(
                label: 'You are home!',
                icon: Icons.check_circle,
                color: Colors.green.shade700,
                onTap: null,
                height: 120,
                fontSize: 28,
                iconSize: 52,
              ),

            const SizedBox(height: 16),

            // ── Refresh location button ─────────────────────────
            _BigButton(
              label: 'Refresh my location',
              icon: Icons.refresh,
              color: Colors.orange.shade700,
              onTap: _loadingDistance ? null : _refreshDistance,
              height: 80,
              fontSize: 20,
              iconSize: 34,
            ),

            const SizedBox(height: 16),

            // ── Call caregiver button ───────────────────────────
            _BigButton(
              label: 'Call my caregiver',
              icon: Icons.phone,
              color: Colors.red.shade700,
              onTap: _callCaregiver,
              height: 80,
              fontSize: 20,
              iconSize: 34,
            ),

            const Spacer(),

            // ── Reassurance message ─────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.blue.shade700, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Do not worry — you are safe.\n'
                      'Press "Take me home" and follow '
                      'the blue arrow on the map.',
                      style: TextStyle(fontSize: 17, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable big button widget ────────────────────────────────────

class _BigButton extends StatelessWidget {
  final String      label;
  final IconData    icon;
  final Color       color;
  final VoidCallback? onTap;
  final double      height;
  final double      fontSize;
  final double      iconSize;

  const _BigButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.height,
    required this.fontSize,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.shade400 : color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: iconSize),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}