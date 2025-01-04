class SMS {
  final String idx;
  final String type;
  final String? originatingAddress;
  final String? destinationAddress;
  final String date;
  final String time;
  final String contents;

  const SMS({
    required this.idx,
    required this.type,
    this.originatingAddress,
    this.destinationAddress,
    required this.date,
    required this.time,
    required this.contents,
  });

  // Factory constructor to map JSON keys to class fields
  factory SMS.fromJson(Map<String, dynamic> json) {
    return SMS(
      idx: json['message_index'] ?? '',
      type: json['message_type'] ?? '',
      originatingAddress: json['message_originating_address'],
      destinationAddress: json['message_destination_address'],
      date: json['message_date'] ?? '',
      time: json['message_time'] ?? '',
      contents: json['message_contents'] ?? '',
    );
  }
}
