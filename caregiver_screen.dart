import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/geofence_service.dart';
import '../services/notification_service.dart';

class CaregiverScreen extends StatelessWidget {
  const CaregiverScreen({super.key});

  // ── Edit your patient's medication list here ──────────────────
  static const _medications = [
    _Med(name: 'Aricept',   times: ['8:00 AM', '8:00 PM']),
    _Med(name: 'Vitamin D', times: ['9:00 AM']),
  ];
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final geo = context.watch<GeofenceService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Panel',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        toolbarHeight: 70,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Location card
          _Card(
            color: geo.isInsideFence
                ? Colors.green.shade700
                : Colors.red.shade700,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  geo.isInsideFence
                      ? 'Patient is safely at home'
                      : 'Patient has left the safe zone!',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                Text(
                  '${geo.distanceFromHome.toStringAsFixed(0)} m from home',
                  style: const TextStyle(
                      fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Medication card
          _Card(
            color: Colors.indigo,
            child: Column(
              children: _medications
                  .map((m) => _MedRow(med: m))
                  .toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Info tip
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: const Text(
              'Tip: Edit geofence_service.dart to set the home '
              'coordinates, and caregiver_screen.dart to update medications.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Color color;
  final Widget child;
  const _Card({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(16)),
      child: child,
    );
  }
}

class _Med {
  final String name;
  final List<String> times;
  const _Med({required this.name, required this.times});
}

class _MedRow extends StatelessWidget {
  final _Med med;
  const _MedRow({required this.med});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.medication, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(med.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
          Text(med.times.join(', '),
              style:
                  const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () =>
                NotificationService().showMedicationReminder(med.name),
            child: const Text('Remind', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}