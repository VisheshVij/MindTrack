import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/people_store.dart';
import '../models/person_profile.dart';
import '../services/recognition_service.dart';

class MemoryBoxScreen extends StatelessWidget {
  const MemoryBoxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final people = PeopleStore().all;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Photos & Family',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        toolbarHeight: 70,
      ),
      body: people.isEmpty
          ? const Center(
              child: Text(
                'No photos yet.\nAdd people to assets/data/people.json.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: people.length,
              itemBuilder: (context, i) =>
                  _ProfileCard(profile: people[i]),
            ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final PersonProfile profile;
  const _ProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    // Watch so the playing indicator updates in real time
    final rec = context.watch<RecognitionService>();
    final isThisPlaying =
        rec.isPlaying && rec.lastRecognized?.uid == profile.uid;

    return GestureDetector(
      onTap: () {
        // Stop if already playing this person, otherwise play
        if (isThisPlaying) {
          context.read<RecognitionService>().stopAudio();
        } else {
          context.read<RecognitionService>().playProfileDirectly(profile);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isThisPlaying
              ? Colors.indigo.shade100
              : Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isThisPlaying
                ? Colors.indigo.shade600
                : Colors.indigo.shade200,
            width: isThisPlaying ? 3 : 2,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14)),
                child: profile.image.isNotEmpty
                    ? Image.asset(
                        profile.image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.indigo.shade100,
                          child: const Icon(Icons.person,
                              size: 80, color: Colors.indigo),
                        ),
                      )
                    : Container(
                        color: Colors.indigo.shade100,
                        child: const Icon(Icons.person,
                            size: 80, color: Colors.indigo),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    profile.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    profile.relationship,
                    style: const TextStyle(
                        fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    isThisPlaying
                        ? Icons.stop_circle
                        : Icons.play_circle_fill,
                    color: Colors.indigo,
                    size: 32,
                  ),
                  if (isThisPlaying)
                    const Text(
                      'Playing...',
                      style: TextStyle(
                          fontSize: 13, color: Colors.indigo),
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