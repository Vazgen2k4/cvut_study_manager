import 'package:cvut_study_manager/logic/hive/adapters/lesson.dart';
import 'package:cvut_study_manager/logic/hive/adapters_keys.dart';
import 'package:cvut_study_manager/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(AppIcons.logo),
        ),
        title: const Text('ČVUT Manager'),
      ),
      body: const HomePageContent(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          showDialog(
            context: context,
            builder: (_) => AlertWidget(
              onSucsess: (name, link) {
                final Lesson lesson = Lesson(
                  lessonLink: Links(link: link, name: name),
                  links: [],
                );

                Hive.box<Lesson>(AdaptersKeys.lessons).add(lesson);
              },
            ),
          );
        },
      ),
    );
  }
}

class AlertWidget extends StatelessWidget {
  const AlertWidget({
    super.key,
    this.onSucsess,
  });

  final void Function(String name, String link)? onSucsess;

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final linkController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: const Text('Добавьте Предмет'),
      content: SizedBox(
        width: 250,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Название",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Это поле обязательно';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: linkController,
                decoration: const InputDecoration(
                  labelText: "Ссылка",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Это поле обязательно';
                  }
                  final linkExp = RegExp(r'^https://|mailto:|tel:\++');

                  if (!linkExp.hasMatch(value)) {
                    return "Неверный формат ссылки";
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            final allIsValide = formKey.currentState?.validate() ?? false;

            if (!allIsValide) {
              return;
            }
            Navigator.of(context).pop();
            final link = linkController.value.text;
            final name = nameController.value.text;

            onSucsess != null ? onSucsess!(name, link) : 0;
          },
          child: const Text('Подтвердить'),
        ),
      ],
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          ToKosButton(),
          SizedBox(height: 12),
          Expanded(child: LessonsWidgetList()),
        ],
      ),
    );
  }
}

class ToKosButton extends StatelessWidget {
  const ToKosButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(
          color: Colors.white,
        ),
        ListTile(
          title: const Text.rich(
            TextSpan(
              text: 'Сcылка на расписание',
              children: [
                TextSpan(
                  text: "\tKOS",
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w700,
                  ),
                )
              ],
            ),
            style: TextStyle(fontSize: 20),
          ),
          onTap: () async {
            final url = Uri.parse('https://kos.cvut.cz/schedule');
            await launchUrl(url);
          },
        ),
        const Divider(
          color: Colors.white,
        ),
      ],
    );
  }
}

class LessonsWidgetList extends StatelessWidget {
  const LessonsWidgetList({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Lesson>>(
      valueListenable: Hive.box<Lesson>(AdaptersKeys.lessons).listenable(),
      builder: (context, box, child) {
        if (box.isEmpty) {
          return const Center(
            child: Text(
              'К сожалению (или к счастью), но записей у вас нет',
            ),
          );
        }

        List<Lesson> lessonsList = box.values.toList();
        const fabHeight = 68;

        final padding = MediaQuery.of(context).padding;

        final paddingBottom = padding.bottom + fabHeight;
        return ListView.separated(
          padding: EdgeInsets.only(bottom: paddingBottom),
          controller: ScrollController(),
          shrinkWrap: true,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: lessonsList.length,
          itemBuilder: (context, index) {
            final lesson = lessonsList[index];

            return LessonItemWidget(
              lesson: lesson,
              index: index,
            );
          },
        );
      },
    );
  }
}

class LessonItemWidget extends StatefulWidget {
  const LessonItemWidget({
    super.key,
    required this.lesson,
    required this.index,
  });

  final Lesson lesson;
  final int index;

  @override
  State<LessonItemWidget> createState() => _LessonItemWidgetState();
}

class _LessonItemWidgetState extends State<LessonItemWidget> {
  final double minHeight = 70;
  final double maxHeight = 150;
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    final height = isOpen ? maxHeight : minHeight;

    return GestureDetector(
      onTap: () {
        setState(() {
          isOpen = !isOpen;
        });
      },
      child: AnimatedContainer(
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(8),
        height: height,
        duration: const Duration(
          milliseconds: 100,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(37, 104, 58, 183),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color.fromARGB(255, 104, 58, 183),
            width: 3,
          ),
        ),
        child: Stack(
          children: [
            LInksListWidget(
              lesson: widget.lesson,
              lessonIndex: widget.index,
            ),
          ],
        ),
      ),
    );
  }
}

class LInksListWidget extends StatelessWidget {
  const LInksListWidget({
    super.key,
    required this.lesson,
    required this.lessonIndex,
  });

  final Lesson lesson;
  final int lessonIndex;

  @override
  Widget build(BuildContext context) {
    final links = lesson.links;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            TextButton(
              onPressed: () async {
                final url = Uri.parse(lesson.lessonLink.link);
                await launchUrl(url);
              },
              child: Text(
                lesson.lessonLink.name,
              ),
            ),
            const Spacer(),
            IconButton.filled(
              onPressed: () async {
                final isApprovement = await AppDialogs.getApprovement(context);

                if (isApprovement == null || !isApprovement) {
                  return;
                }

                await Hive.box<Lesson>(AdaptersKeys.lessons)
                    .deleteAt(lessonIndex);
              },
              icon: const Icon(Icons.delete_sweep_rounded),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) {
                    return AlertWidget(
                      onSucsess: (name, link) async {
                        final newLink = Links(link: link, name: name);
                        lesson.links.add(newLink);
                        await Hive.box<Lesson>(AdaptersKeys.lessons).putAt(
                          lessonIndex,
                          lesson,
                        );
                      },
                    );
                  },
                );
              },
              icon: const Icon(Icons.add_box_outlined),
            ),
          ],
        ),
        Expanded(
          child: ListView.separated(
            controller: ScrollController(),
            shrinkWrap: true,
            itemCount: links.length,
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) {
              final link = links[index];

              return Align(
                alignment: Alignment.bottomCenter,
                child: Material(
                  clipBehavior: Clip.hardEdge,
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xff594391),
                  child: InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Text(link.name),
                    ),
                    onLongPress: () async {
                      final isApprovement = await AppDialogs.getApprovement(
                        context,
                      );

                      if (isApprovement == null || !isApprovement) {
                        return;
                      }

                      links.removeAt(index);

                      await Hive.box<Lesson>(AdaptersKeys.lessons).putAt(
                        lessonIndex,
                        lesson,
                      );
                    },
                    onTap: () async {
                      final url = Uri.parse(link.link);
                      await launchUrl(url);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

abstract final class AppDialogs {
  static Future<bool?> getApprovement(BuildContext context) async {
    return await showDialog<bool?>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Удаление'),
          content: const Text(
            'Вы уверены, что хотите удалить эту ссылку?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Подтвердить'),
            ),
          ],
        );
      },
    );
  }
}
