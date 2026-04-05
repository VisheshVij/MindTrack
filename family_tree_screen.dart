import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/people_store.dart';
import '../services/recognition_service.dart';

class FamilyTreeScreen extends StatelessWidget {
  const FamilyTreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final people = PeopleStore().all;
    final rec    = context.watch<RecognitionService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Family',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        toolbarHeight: 70,
      ),
      body: Column(
        children: [
          // Detail panel for whoever is currently selected
          if (rec.lastRecognized != null)
            Container(
              width: double.infinity,
              color: Colors.teal.shade50,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        rec.lastRecognized!.image.isNotEmpty
                            ? AssetImage(rec.lastRecognized!.image)
                            : null,
                    child: rec.lastRecognized!.image.isEmpty
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rec.lastRecognized!.name,
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold)),
                        Text(
                            'Your ${rec.lastRecognized!.relationship}',
                            style: const TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                  if (rec.isPlaying)
                    GestureDetector(
                      onTap: () =>
                          context.read<RecognitionService>().stopAudio(),
                      child: const Icon(Icons.stop_circle,
                          color: Colors.teal, size: 38),
                    ),
                ],
              ),
            ),

          // Family member list
          Expanded(
            child: people.isEmpty
                ? const Center(
                    child: Text(
                      'No family members yet.\n'
                      'Add them to assets/data/people.json.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: people.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final p = people[i];
                      final isActive =
                          rec.lastRecognized?.uid == p.uid;
                      final isThisPlaying =
                          rec.isPlaying && isActive;

                      return GestureDetector(
                        onTap: () {
                          if (isThisPlaying) {
                            context
                                .read<RecognitionService>()
                                .stopAudio();
                          } else {
                            context
                                .read<RecognitionService>()
                                .playProfileDirectly(p);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.teal.shade100
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isThisPlaying
                                  ? Colors.teal.shade700
                                  : Colors.teal.shade300,
                              width: isThisPlaying ? 3 : 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundImage: p.image.isNotEmpty
                                    ? AssetImage(p.image)
                                    : null,
                                child: p.image.isEmpty
                                    ? const Icon(Icons.person,
                                        size: 36)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name,
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight:
                                                FontWeight.bold)),
                                    Text(
                                        'Your ${p.relationship}',
                                        style: const TextStyle(
                                            fontSize: 18)),
                                  ],
                                ),
                              ),
                              Icon(
                                isThisPlaying
                                    ? Icons.stop_circle
                                    : Icons.volume_up,
                                color: Colors.teal.shade700,
                                size: 32,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}