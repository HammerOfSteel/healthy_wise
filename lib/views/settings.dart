import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  TextEditingController _ageController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  TextEditingController _healthHistoryController = TextEditingController();
  TextEditingController _chatGPTTokenController = TextEditingController();

  String _selectedLanguage = 'English';  // Default language
  bool _isAiActivated = false;
  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];

  String _selectedWorkoutPlan = 'Basic Fitness and Health'; // Default plan
  final List<String> _workoutPlans = [
    'Basic Fitness and Health',
    'Functional Fitness',
    'Longevity and Total Body Health',
  ];

  final Map<String, Map<String, dynamic>> _workoutPlanDetails = {
    'Basic Fitness and Health': {
      'daysPerWeek': 3,
      'workoutDays': ['Monday', 'Wednesday', 'Friday'],
      'exercisesPerDay': 3,
      'circuits': 3,
      'repsPerExercise': 12,
      'contents': {
        'Monday': ['Push-ups', 'Sit-ups', 'Squats'],
        'Wednesday': ['Push-ups', 'Planks', 'Lunges'],
        'Friday': ['Burpees', 'Leg Raises', 'Jumping Jacks'],
      },
    },
    'Functional Fitness': {
      'daysPerWeek': 4,
      'workoutDays': ['Monday', 'Tuesday', 'Thursday', 'Saturday'],
      'exercisesPerDay': 4,
      'circuits': 4,
      'repsPerExercise': 10,
      'contents': {
        'Monday': ['Pull-ups', 'Push-ups', 'Squats', 'Planks'],
        'Tuesday': ['Deadlifts', 'Box Jumps', 'Bench Press', 'Russian Twists'],
        'Thursday': ['Chin-ups', 'Dips', 'Leg Press', 'Hanging Leg Raises'],
        'Saturday': ['Kettlebell Swings', 'Medicine Ball Throws', 'Mountain Climbers', 'Yoga'],
      },
    },
    'Longevity and Total Body Health': {
      'daysPerWeek': 5,
      'workoutDays': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
      'exercisesPerDay': 2,
      'circuits': 2,
      'repsPerExercise': 15,
      'contents': {
        'Monday': ['Yoga', 'Meditation'],
        'Tuesday': ['Swimming', 'Cycling'],
        'Wednesday': ['Pilates', 'Tai Chi'],
        'Thursday': ['Hiking', 'Stretching'],
        'Friday': ['Rowing', 'Foam Rolling'],
      },
    },
  };

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('language', _selectedLanguage);
    prefs.setString('age', _ageController.text);
    prefs.setString('weight', _weightController.text);
    prefs.setString('height', _heightController.text);
    prefs.setString('healthHistory', _healthHistoryController.text);
    prefs.setString('chatGPTToken', _chatGPTTokenController.text);
    prefs.setBool('isAiActivated', _isAiActivated);
    prefs.setString('workoutPlan', _selectedWorkoutPlan); // Save the selected workout plan name
    prefs.setString('workoutPlanDetails', jsonEncode(_workoutPlanDetails)); // Save the entire workout plan details
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedLanguage = prefs.getString('language');
    if (!_languages.contains(storedLanguage)) {
      storedLanguage = 'English';
    }
    String? storedWorkoutPlan = prefs.getString('workoutPlan');
    if (!_workoutPlans.contains(storedWorkoutPlan)) {
      storedWorkoutPlan = 'Basic Fitness and Health';
    }
    setState(() {
      _selectedLanguage = storedLanguage!;
      _selectedWorkoutPlan = storedWorkoutPlan!;
      _ageController.text = prefs.getString('age') ?? '';
      _weightController.text = prefs.getString('weight') ?? '';
      _heightController.text = prefs.getString('height') ?? '';
      _healthHistoryController.text = prefs.getString('healthHistory') ?? '';
      _chatGPTTokenController.text = prefs.getString('chatGPTToken') ?? '';
      _isAiActivated = prefs.getBool('isAiActivated') ?? false;
    });
  }

  Future<void> _importCsv() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        File? file = result.files.singleOrNull?.path != null ? File(result.files.singleOrNull!.path!) : null;

        if (file != null) {
          final input = file.openRead();
          final fields = await input.transform(utf8.decoder).transform(CsvToListConverter()).toList();
          Map<DateTime, List<String>> workoutPlan = _processCSV(fields);
          _saveWorkoutPlan(workoutPlan);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CSV imported successfully!')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No file selected')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No file selected')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to import CSV: $e')));
    }
  }

  Map<DateTime, List<String>> _processCSV(List<List<dynamic>> fields) {
    Map<DateTime, List<String>> workoutPlan = {};
    for (int i = 1; i < fields.length; i++) {
      DateTime date = DateTime.parse(fields[i][0]);
      List<String> exercises = [];
      for (int j = 1; j < fields[i].length; j++) {
        exercises.add(fields[i][j].toString());
      }
      workoutPlan[date] = exercises;
    }
    return workoutPlan;
  }

  Future<void> _saveWorkoutPlan(Map<DateTime, List<String>> workoutPlan) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(workoutPlan);
    prefs.setString('workoutPlan', jsonString);
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (in kg)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Height (in cm)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _healthHistoryController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                labelText: 'Health History',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _chatGPTTokenController,
              decoration: InputDecoration(
                labelText: 'ChatGPT Token',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            SwitchListTile(
              title: Text("Activate AI Functionality"),
              value: _isAiActivated,
              onChanged: (value) {
                setState(() {
                  _isAiActivated = value;
                });
              },
            ),
            SizedBox(height: 10),
            DropdownButtonFormField(
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                }
              },
              items: _languages.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Language',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField(
              value: _selectedWorkoutPlan,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedWorkoutPlan = newValue;
                  });
                }
              },
              items: _workoutPlans.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Workout Plan',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _importCsv,
              child: Text('Import Workout Plan from CSV'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveSettings,
              child: Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
