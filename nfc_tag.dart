class NfcTag {
  final String uid;
  final String type;         // 'person' or 'appliance'
  final String name;
  final String warningMessage; // used when type == 'appliance'

  const NfcTag({
    required this.uid,
    required this.type,
    this.name = '',
    this.warningMessage = '',
  });

  factory NfcTag.fromMap(Map<String, dynamic> map) {
    return NfcTag(
      uid:            map['uid']            as String? ?? '',
      type:           map['type']           as String? ?? 'person',
      name:           map['name']           as String? ?? '',
      warningMessage: map['warningMessage'] as String? ?? '',
    );
  }
}