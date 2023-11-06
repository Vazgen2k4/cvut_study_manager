import 'package:hive/hive.dart';
part 'lesson.g.dart';

@HiveType(typeId: 1)
class Lesson {
  @HiveField(0)
  final Links lessonLink;

  @HiveField(2)
  final List<Links> links;

  const Lesson({
    required this.links,
    required this.lessonLink,
  });
}

@HiveType(typeId: 2)
class Links {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String link;

  const Links({
    required this.link,
    required this.name,
  });
}
