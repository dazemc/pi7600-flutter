class SMS {
  final String idx;
  final String type;
  final String? originatingAddress;
  final String? destinationAddress;
  final String date;
  final String time;
  final String contents;

  const SMS(
    {
      required this.idx,
      required this.type,
      this.originatingAddress,
      this.destinationAddress,
      required this.date,
      required this.time,
      required this.contents,
    }
  );

  factory SMS.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'idx': String idx,
        'type': String type,
        'originatingAddress': String? originatingAddress,
        'destinationAddress': String? destinationAddress,
        'date': String date,
        'time': String time,
        'contents': String contents, 
      } =>
      SMS(
        idx: idx,
        type: type,
        originatingAddress: originatingAddress,
        destinationAddress: destinationAddress,
        date: date,
        time: time,
        contents: contents,
      ),
      _ => throw const FormatException('Failed to load SMS.')
    };
  }
}