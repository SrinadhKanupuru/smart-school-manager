class SchoolEvent {
  final String id;
  final String month;
  final String day;
  final String title;
  final String time;
  final String location;
  final String category;

  const SchoolEvent({
    required this.id,
    required this.month,
    required this.day,
    required this.title,
    required this.time,
    required this.location,
    this.category = 'General',
  });
}
