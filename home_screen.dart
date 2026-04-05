import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ble_service.dart';
import '../services/recognition_service.dart';
import '../widgets/orientation_bar.dart';
import '../widgets/large_button.dart';
import 'memory_box_screen.dart';
import 'task_guide_screen.dart';
import 'family_tree_screen.dart';
import 'caregiver_screen.dart';
import 'find_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleService>();
    final rec = context.watch<RecognitionService>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Always-visible day/time bar
            const OrientationBar(),

            // BLE connection status strip
            Container(
              width: double.infinity,
              color: ble.connected
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
              padding: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    ble.connected
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth_searching,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ble.connected
                        ? 'Necklace connected'
                        : ble.status,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),

            // Recognition banner — shows when NFC tag is scanned
            if (rec.lastRecognized != null)
              Container(
                width: double.infinity,
                color: Colors.indigo.shade50,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage:
                          rec.lastRecognized!.image.isNotEmpty
                              ? AssetImage(rec.lastRecognized!.image)
                              : null,
                      child: rec.lastRecognized!.image.isEmpty
                          ? const Icon(Icons.person, size: 32)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec.lastRecognized!.name,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Your ${rec.lastRecognized!.relationship}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    if (rec.isPlaying)
                      GestureDetector(
                        onTap: () =>
                            context.read<RecognitionService>().stopAudio(),
                        child: const Icon(Icons.stop_circle,
                            color: Colors.indigo, size: 36),
                      )
                    else
                      GestureDetector(
                        onTap: () => context
                            .read<RecognitionService>()
                            .playProfileDirectly(rec.lastRecognized!),
                        child: const Icon(Icons.play_circle_fill,
                            color: Colors.indigo, size: 36),
                      ),
                  ],
                ),
              ),

            // Main menu buttons
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    LargeButton(
                      label: 'My Family',
                      icon: Icons.people,
                      color: Colors.indigo,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FamilyTreeScreen()),
                      ),
                    ),

                    LargeButton(
                      label: 'My Photos',
                      icon: Icons.photo_album,
                      color: Colors.teal.shade700,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MemoryBoxScreen()),
                      ),
                    ),

                    LargeButton(
                      label: 'What to do now',
                      icon: Icons.checklist,
                      color: Colors.orange.shade700,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TaskGuideScreen()),
                      ),
                    ),

                    // ── Navigate home button ──────────────────────
                    LargeButton(
                      label: 'Take me home',
                      icon: Icons.home,
                      color: Colors.green.shade700,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FindHomeScreen()),
                      ),
                    ),
                    // ─────────────────────────────────────────────

                    LargeButton(
                      label: 'Caregiver',
                      icon: Icons.favorite,
                      color: Colors.pink.shade600,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CaregiverScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}