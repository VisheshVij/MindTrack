class PersonProfile {
  final String uid;         // NFC tag UID e.g. "A1:B2:C3:D4"
  final String name;
  final String relationship;
  final String image;       // asset path e.g. "assets/images/priya.jpg"
  final String audio;       // asset path e.g. "assets/audio/priya.mp3"

  const PersonProfile({
    required this.uid,
    required this.name,
    required this.relationship,
    required this.image,
    required this.audio,
  });

  factory PersonProfile.fromJson(Map<String, dynamic> j) => PersonProfile(
        uid:          j['uid']          as String? ?? '',
        name:         j['name']         as String? ?? 'Unknown',
        relationship: j['relationship'] as String? ?? '',
        image:        j['image']        as String? ?? '',
        audio:        j['audio']        as String? ?? '',
      );
}