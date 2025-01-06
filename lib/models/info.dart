class Info {
  final String hostname;
  final String uname;
  final String date;
  final String arch;

  const Info({
    required this.hostname,
    required this.uname,
    required this.date,
    required this.arch,
  });

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(
      hostname: json['hostname'] ?? '',
      uname: json['uname'] ?? '',
      date: json['date'] ?? '',
      arch: json['arch'] ?? '',
    );
  }
}
