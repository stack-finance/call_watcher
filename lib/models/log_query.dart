class LogQuery {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int? durationFrom;
  final int? durationTo;
  final String? name;
  final String? number;
  final bool? isOutgoing;

  const LogQuery(
      {required this.dateFrom,
      required this.dateTo,
      required this.durationFrom,
      required this.durationTo,
      required this.name,
      required this.number,
      required this.isOutgoing});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LogQuery &&
        other.dateFrom == dateFrom &&
        other.dateTo == dateTo &&
        other.durationFrom == durationFrom &&
        other.durationTo == durationTo &&
        other.name == name &&
        other.number == number &&
        other.isOutgoing == isOutgoing;
  }

  @override
  int get hashCode {
    return dateFrom.hashCode ^
        dateTo.hashCode ^
        durationFrom.hashCode ^
        durationTo.hashCode ^
        name.hashCode ^
        number.hashCode ^
        isOutgoing.hashCode;
  }

  LogQuery copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? durationFrom,
    int? durationTo,
    String? name,
    String? number,
    bool? isOutgoing,
  }) {
    return LogQuery(
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      durationFrom: durationFrom ?? this.durationFrom,
      durationTo: durationTo ?? this.durationTo,
      name: name ?? this.name,
      number: number ?? this.number,
      isOutgoing: isOutgoing ?? this.isOutgoing,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateFrom': dateFrom?.millisecondsSinceEpoch,
      'dateTo': dateTo?.millisecondsSinceEpoch,
      'durationFrom': durationFrom,
      'durationTo': durationTo,
      'name': name,
      'number': number,
      'isOutgoing': isOutgoing,
    };
  }
}
