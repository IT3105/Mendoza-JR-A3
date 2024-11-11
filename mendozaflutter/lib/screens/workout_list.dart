import 'package:flutter/material.dart';
import 'package:fitness_workout_tracker/models/workout.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_workout_screen.dart'; 

class ListViewPage extends StatefulWidget {
  @override
  _ListViewPageState createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {
  List<Workout> workouts = [];
  int currentPage = 0;
  final int workoutsPerPage = 6;
  String selectedDay = 'Sunday';

  @override
  void initState() {
    super.initState();
    fetchWorkouts();
  }

  Future<void> fetchWorkouts() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3001/workouts'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          workouts = data.map((json) => Workout.fromJson(json)).toList();
        });
      } else {
        _showErrorDialog('Failed to load workouts');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    }
  }

  List<Workout> get workoutsForSelectedDay {
    return workouts.where((workout) => workout.day == selectedDay).toList();
  }

  List<Widget> get paginatedWorkouts {
    List<Workout> dayWorkouts = workoutsForSelectedDay;
    int start = currentPage * workoutsPerPage;
    int end = (start + workoutsPerPage < dayWorkouts.length) ? start + workoutsPerPage : dayWorkouts.length;

    return dayWorkouts.sublist(start, end).map((workout) {
      return Card(
        child: ListTile(
          title: Text(workout.workoutName.isNotEmpty ? workout.workoutName : 'No Name'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reps: ${workout.reps}'),
              Text('Sets: ${workout.sets}'),
              Text('Duration: ${workout.duration} min'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await _deleteWorkout(workout.id);
                },
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditWorkoutPage(
                        workout: workout,
                        onUpdate: fetchWorkouts, 
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Future<void> _deleteWorkout(String id) async {
    final response = await http.delete(Uri.parse('http://localhost:3001/workouts/$id'));
    if (response.statusCode == 204) {
      setState(() {
        workouts.removeWhere((workout) => workout.id == id);
      });
    } else {
      _showErrorDialog('Failed to delete workout');
    }
  }

  void nextPage() {
    if ((currentPage + 1) * workoutsPerPage < workoutsForSelectedDay.length) {
      setState(() {
        currentPage++;
      });
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  void selectDay(String day) {
    setState(() {
      selectedDay = day;
      currentPage = 0;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Workout List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (String day in ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'])
                  ElevatedButton(
                    onPressed: () => selectDay(day),
                    child: Text(day),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(selectedDay == day ? Colors.grey : Colors.black),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: paginatedWorkouts.length,
              itemBuilder: (context, index) {
                return paginatedWorkouts[index];
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: previousPage,
                  child: Text('<'),
                ),
                SizedBox(width: 10),
                Text(
                  workoutsForSelectedDay.isEmpty
                      ? '1/1'
                      : '${currentPage + 1}/${(workoutsForSelectedDay.length / workoutsPerPage).ceil()}',
                ),
                SizedBox(width: 10),
                TextButton(
                  onPressed: nextPage,
                  child: Text('>'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
