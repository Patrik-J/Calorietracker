//import 'dart:ui';
import 'dart:io';
import 'dart:convert';

const String settingsFile = 'settings.json';
const intakeFile = 'intake.json';
const int SETUP_DONE = 12;
const int SETUP_FAILED = 13;
const int SETUP_ALREADY_DONE = 14;
const int SETTINGS_CHANGED_SUCCESFULLY = 15;
const int SETTINGS_UNSUCCESSFULLY_CHANGED = 16;
//const int READING_SETTINGS_UNSUCCESSFULL = 17;
//const int READING_SETTINGS_SUCCESSFULL = 18;
//const int READING_INTAKE_UNSUCCESSFULL = 19;
//const int READING_INTAKE_SUCCESSFULL = 20;

class Setup {
  late File settings;
  late File intake;
  bool _check = false;

  int initSetup() {
    if(_check == false) {
      settings = File(settingsFile);
      if(_initSettingsFile(settings) == SETUP_FAILED) {
        throw Exception("Setup failed. Settings-file cannot be initiated.");
      }
      intake = File(intakeFile);
      if(_initIntakeFile(intake) == SETUP_FAILED) {
        throw Exception("Setup failed. Intake-file cannot be initiated.");
      }
      _check = true;
      return SETUP_DONE;
    }
    else {
      return SETUP_ALREADY_DONE;
    }
  }

  Future<int> _initSettingsFile(File settings) async {
    const String defaultSettings = '{\n"language": "deutsch",\n"appearance": "light-mode"\n}';
    try {
      await settings.writeAsString(defaultSettings);
    } catch (e) {
      return SETUP_FAILED;
    }
    return SETUP_DONE;
  }

  Future<int> _initIntakeFile(File intake) async {
    const String defaultIntake = '{\n"calories_goal": 1200,\n"calories_achieved": 300,\n"protein": 0.4,\n"carbs": 0.3,\n"fats": 0.3,\n"water_goal": 3,\n"water_drunk": 1.3\n}';
    try {
      await intake.writeAsString(defaultIntake);
    } catch (e) {
      return SETUP_FAILED;
    }
    return SETUP_DONE;
  }

  Future<int> changeSettings(String id, String change) async {
    try {
      String reading = settings.readAsStringSync();
      var readingData = jsonDecode(reading);
      readingData[id] = change;
      await settings.writeAsString(readingData);
    } catch(e) {
      return SETTINGS_UNSUCCESSFULLY_CHANGED;
    }
    return SETTINGS_CHANGED_SUCCESFULLY;
  }

  Future<String> readSettings(String id) async {
    try {
      String reading = settings.readAsStringSync();
      var readingData = jsonDecode(reading);
      return readingData[id];
    } catch(e) {
      throw Exception("Reading settings was unsuccessful.");
    }
  }

  Future<String> readIntake(String id) async {
    try {
      String reading = settings.readAsStringSync();
      var readingData = jsonDecode(reading);
      return readingData[id];
    } catch(e) {
      throw Exception("Reading intake was unsuccessful.");
    }
  }

}


