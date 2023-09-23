import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CalendarView extends StatefulWidget {
  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _selectedDay = DateTime.now();
  TextEditingController _sleepHoursController = TextEditingController();
  TextEditingController _sleepQualityController = TextEditingController();
  Map<String, bool> _exerciseCompletionStatus = {};
  List<String> _workoutPlanForSelectedDay = [];
  Map<String, Map<String, dynamic>> _workoutPlan = {};

  String _selectedWorkoutPlan = 'Basic Fitness and Health'; // Default plan

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    _workoutPlanForSelectedDay.clear();
    final prefs = await SharedPreferences.getInstance();
    String? workoutPlanString = prefs.getString('workoutPlanDetails');

    if (workoutPlanString != null) {
      _workoutPlan = Map<String, Map<String, dynamic>>.from(jsonDecode(workoutPlanString));
    }

    String selectedWeekday = DateFormat('EEEE').format(_selectedDay);

    debugPrint('Selected Weekday: $selectedWeekday');

    if (prefs.getString(selectedWeekday) != null) {
      Map<String, dynamic> fetchedData = jsonDecode(prefs.getString(selectedWeekday)!);
      _sleepHoursController.text = fetchedData['sleepHours'] ?? '';
      _sleepQualityController.text = fetchedData['sleepQuality'] ?? '';
      _exerciseCompletionStatus = Map<String, bool>.from(fetchedData['exercises'] ?? {});
    } else {
      _exerciseCompletionStatus = Map.fromIterable(
        _workoutPlan[_selectedWorkoutPlan]?['contents'][selectedWeekday] ?? [],
        key: (e) => e,
        value: (e) => false,
      );
    }

    setState(() {
    var workoutsForTheDay = _workoutPlan[_selectedWorkoutPlan]!['contents'][selectedWeekday];
    _workoutPlanForSelectedDay = (workoutsForTheDay != null) ? (workoutsForTheDay as List<dynamic>).cast<String>() : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Calendar'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text('Selected Date: $_selectedDay'),
              onTap: _pickDate,
            ),
            TextFormField(
              controller: _sleepHoursController,
              decoration: InputDecoration(labelText: 'Sleep Hours'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _sleepQualityController,
              decoration: InputDecoration(labelText: 'Sleep Quality (1-10)'),
              keyboardType: TextInputType.number,
            ),
            Column(
              children: (_workoutPlanForSelectedDay).map((exercise) {
                bool isCompleted = _exerciseCompletionStatus[exercise] ?? false;
                return CheckboxListTile(
                  title: Text(exercise),
                  value: isCompleted,
                  onChanged: (bool? value) {
                    setState(() {
                      _exerciseCompletionStatus[exercise] = value ?? false;
                    });
                  },
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: _saveData,
              child: Text('Save'),
            ),
            if (_workoutPlanForSelectedDay.isNotEmpty)
              Column(
                children: [
                  Text('Workout Plan for $_selectedDay:'),
                  Column(
                    children: (_workoutPlanForSelectedDay).map((exercise) {
                      return Text(exercise);
                    }).toList(),
                  ),
                ],
              )
            else
              Text('No workout plan for $_selectedDay'),
          ],
        ),
      ),
    );
  }

  _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null && date != _selectedDay) {
      setState(() {
        _selectedDay = date;
      });
      _loadData();
    }
  }

  _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    String selectedWeekday = DateFormat('EEEE').format(_selectedDay);

    Map<String, dynamic> dataToSave = {
      'sleepHours': _sleepHoursController.text,
      'sleepQuality': _sleepQualityController.text,
      'exercises': _exerciseCompletionStatus,
    };

    prefs.setString(selectedWeekday, jsonEncode(dataToSave));
  }
}
