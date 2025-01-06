class SMS {
  final int? id;
  final String idx;
  final String type;
  String? originatingAddress;
  final String? destinationAddress;
  final String date;
  final String time;
  final String contents;
  final bool? isSimMemory;
  final bool? isSent;

  SMS({
    this.id,
    required this.idx,
    required this.type,
    this.originatingAddress,
    this.destinationAddress,
    required this.date,
    required this.time,
    required this.contents,
    this.isSimMemory,
    this.isSent,
  });

  // Factory constructor to map JSON keys to class fields
  factory SMS.fromJson(Map<String, dynamic> json) {
    return SMS(
      id: json['id'],
      idx: json['message_index'] ?? '',
      type: json['message_type'] ?? '',
      originatingAddress: json['message_originating_address'],
      destinationAddress: json['message_destination_address'],
      date: json['message_date'] ?? '',
      time: json['message_time'] ?? '',
      contents: json['message_contents'] ?? '',
      isSimMemory: json['in_sim_memory'],
      isSent: json['is_sent'],
    );
  }
}