enum CallCurrentStatus {
  incoming,
  outgoing,
  connecting,
  onHold,
  ended,
}

class CallLogEntry {
  final String id;
  final String number;
  final String? contactName;
  final DateTime? date;
  final Duration? duration;
  final bool isOutgoing;

  CallLogEntry({
    required this.id,
    required this.number,
    this.contactName,
    this.date,
    this.duration,
    required this.isOutgoing,
  });

  factory CallLogEntry.fromJson(Map map) {
    return CallLogEntry(
      id: map['id'],
      number: map['number'],
      contactName: map['contactName'],
      date: DateTime.tryParse(map['date']),
      duration: Duration(seconds: map['duration'] ?? 0),
      isOutgoing: map['isOutgoing'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'contactName': contactName,
      'date': date?.millisecondsSinceEpoch,
      'duration': duration?.inSeconds,
      'isOutgoing': isOutgoing,
    };
  }
}
