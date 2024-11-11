import 'package:fitness_workout_tracker/models/workout.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WorkoutService {
  final String baseUrl = 'http://localhost:3001/workouts'; 

  Future<List<Workout>> getAllWorkouts() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Workout.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load workouts');
    }
  }

  Future<void> deleteWorkout(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete workout');
    }
  }

  Future<void> editWorkout(Workout workout) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${workout.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(workout.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to edit workout');
    }
  }
}
