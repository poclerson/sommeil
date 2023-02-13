import 'package:flutter/material.dart';
import 'package:sommeil/models/sleep_target.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/colorpicker.dart';
import 'package:progressive_time_picker/progressive_time_picker.dart';
import '../../widgets/text_prompt.dart';
import '../../models/schedule.dart';
import '../../models/weekday.dart';
import 'dart:core';
import 'package:get/get.dart';
import 'app_circle_time_picker.dart';
import '../../models/time_of_day_extension.dart';

class NewSchedule extends StatefulWidget {
  Schedule schedule;
  Function updateSchedules;
  Function? updateWeekdays;
  Operation operation;
  late Schedule oldSchedule = schedule;
  NewSchedule(
      {required this.updateSchedules,
      required this.schedule,
      required this.operation,
      this.updateWeekdays});

  @override
  _NewScheduleState createState() => _NewScheduleState();
}

class _NewScheduleState extends State<NewSchedule> {
  late PickedTime _sleepTime;
  late PickedTime _wakeTime;

  @override
  Widget build(BuildContext context) {
    _sleepTime = widget.schedule.sleepTime.toPickedTime();
    _wakeTime = widget.schedule.wakeTime.toPickedTime();

    /// Ajouter le Prompt aux fonctions ouvertes onLoad
    WidgetsBinding.instance
        .addPostFrameCallback(widget.schedule.name == Schedule.baseName
            ? (_) => showDialog(
                context: context,
                builder: (context) => TextPrompt(
                      (value) async {
                        final schedules = await Schedule.getAll();
                        bool nameExists =
                            schedules.any((schedule) => schedule.name == value);
                        if (!nameExists) {
                          setState(() {
                            widget.schedule.name = value;
                          });
                        }
                        return nameExists;
                      },
                    ))
            : (_) {});
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              widget.schedule.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(color: widget.schedule.color),
            )),
        bottomNavigationBar: NavBar(),
        body: Padding(
            padding: EdgeInsets.all(25),
            child: ListView(
              children: [
                Text(
                  'Temps de sommeil',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                AppCircleTimePicker(widget.schedule,
                    onSelectionChanged: (sleep, wake, isDisableRange) =>
                        setState(() {
                          widget.schedule.sleepTime =
                              TimeOfDayExtension.fromPickedTime(sleep);
                          widget.schedule.wakeTime =
                              TimeOfDayExtension.fromPickedTime(wake);
                        }),
                    onSelectionEnded: ((sleep, wake, isDisableRange) =>
                        setState(() {
                          _sleepTime = sleep;
                          _wakeTime = wake;
                        }))),
                widget.schedule.hoursSlept < SleepTarget.total
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Il vous manque ${(SleepTarget.total - widget.schedule.hoursSlept).toTimeOfDay().toStringFormatted()} pour atteindre votre objectif de sommeil',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextButton(
                              onPressed: () => Get.toNamed('/settings'),
                              child: Text('Modifier dans préférences'))
                        ],
                      )
                    : Text(
                        'Vous atteignez votre objectif de sommeil',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                Divider(
                  height: 100,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                Text(
                  'Couleur',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                ColorPicker((Color color) {
                  setState(() {
                    widget.schedule.color = color;
                  });
                }),
                TextButton(
                    onPressed: () {
                      switch (widget.operation) {
                        case Operation.addition:
                          Schedule.pickedTime(
                                  name: widget.schedule.name,
                                  color: widget.schedule.color,
                                  songURL:
                                      '//open.spotify.com/track/2RlgNHKcydI9sayD2Df2xp?si=7fcab8f35fb44f36',
                                  sleepTime: _sleepTime,
                                  wakeTime: _wakeTime)
                              .add();
                          break;
                        case Operation.edition:
                          widget.oldSchedule.edit(Schedule.pickedTime(
                              name: widget.schedule.name,
                              color: widget.schedule.color,
                              songURL:
                                  '//open.spotify.com/track/2RlgNHKcydI9sayD2Df2xp?si=7fcab8f35fb44f36',
                              sleepTime: _sleepTime,
                              wakeTime: _wakeTime));
                          Weekday.onScheduleEdited(widget.oldSchedule);
                          widget.updateWeekdays!();
                      }
                      widget.updateSchedules();
                      Navigator.of(Get.overlayContext!).pop();
                    },
                    child: Text('Terminé'))
              ],
            )));
  }
}
