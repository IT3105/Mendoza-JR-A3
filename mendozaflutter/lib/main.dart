import 'package:flutter/material.dart';
import 'screens/workout_grid.dart';
import 'screens/workout_list.dart'; 
import 'screens/add_workout.dart'; 
import 'models/workout.dart';
import 'services/workout_service.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Workout> workouts = [];
  final WorkoutService workoutService = WorkoutService();

  @override
  void initState() {
    super.initState();
    _fetchWorkouts();
  }

  Future<void> _fetchWorkouts() async {
    try {
      final fetchedWorkouts = await workoutService.getAllWorkouts();
      setState(() {
        workouts = fetchedWorkouts;
      });
    } catch (e) {
      print("Error fetching workouts: $e");
    }
  }

  void _showAddWorkoutForm() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AddWorkoutScreen(
          onAdd: () {
            _fetchWorkouts(); 
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Workout>> workoutsByDay = {};
    int totalDuration = 0;

    for (var workout in workouts) {
      totalDuration += workout.duration;
      if (!workoutsByDay.containsKey(workout.day)) {
        workoutsByDay[workout.day] = [];
      }
      workoutsByDay[workout.day]!.add(workout);
    }

    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/header_image.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5), 
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 40,
                child: Column(
                  children: [
                    Text(
                      'Fitness Tracker',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GridViewPage(), 
                              ),
                            );
                          },
                          child: Text('Grid View'),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            _showAddWorkoutForm();
                          },
                          child: Text('Add Workout'),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ListViewPage(),
                              ),
                            );
                          },
                          child: Text('List View'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2, 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workout Summary',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ...workoutsByDay.entries.map((entry) {
                        String day = entry.key;
                        List<Workout> dayWorkouts = entry.value;
                        int dayTotalDuration = dayWorkouts.fold(0, (sum, workout) => sum + workout.duration);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$day: ${dayWorkouts.length} workouts, $dayTotalDuration minutes',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        );
                      }).toList(),
                      SizedBox(height: 10),
                      Text(
                        'Total for the week: ${workouts.length} workouts, $totalDuration minutes',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1, 
                  child: Container(), 
                ),
              ],
            ),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
