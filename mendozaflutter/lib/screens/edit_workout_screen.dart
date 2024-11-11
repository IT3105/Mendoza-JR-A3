import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:fitness_workout_tracker/models/workout.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditWorkoutPage extends StatefulWidget {
  final Workout workout;
  final Function onUpdate;

  EditWorkoutPage({required this.workout, required this.onUpdate});

  @override
  _EditWorkoutPageState createState() => _EditWorkoutPageState();
}

class _EditWorkoutPageState extends State<EditWorkoutPage> {
  final TextEditingController workoutNameController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  String selectedDay = 'Sunday';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    workoutNameController.text = widget.workout.workoutName;
    repsController.text = widget.workout.reps.toString();
    setsController.text = widget.workout.sets.toString();
    durationController.text = widget.workout.duration.toString();
    selectedDay = widget.workout.day; 
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(20), 
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0), 
            child: Container(
              height: 500, 
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/header_image.jpg'), 
                  fit: BoxFit.cover, 
                ),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), 
            child: Container(
              height: 500, 
              color: Colors.black.withOpacity(0.5), 
            ),
          ),
          Container(
            height: 500, 
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit Workout', style: TextStyle(color: Colors.white, fontSize: 24)), 
                Form(
                  key: _formKey, 
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: workoutNameController,
                        decoration: InputDecoration(
                          labelText: 'Workout Name',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a workout name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: repsController,
                        decoration: InputDecoration(
                          labelText: 'Reps',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          } else if (int.parse(value) <= 0) {
                            return 'Reps cannot be negative or zero';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: setsController,
                        decoration: InputDecoration(
                          labelText: 'Sets',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          } else if (int.parse(value) <= 0) {
                            return 'Sets cannot be negative or zero';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: durationController,
                        decoration: InputDecoration(
                          labelText: 'Duration (seconds)',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          } else if (int.parse(value) <= 0) {
                            return 'Duration cannot be negative or zero';
                          }
                          return null;
                        },
                      ),
                      DropdownButton<String>(
                        dropdownColor: Colors.black,
                        value: selectedDay,
                        style: TextStyle(color: Colors.white),
                        iconEnabledColor: Colors.white,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedDay = newValue!;
                          });
                        },
                        items: <String>[
                          'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Spacer(), 
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); 
                      },
                      child: Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          Workout updatedWorkout = Workout(
                            id: widget.workout.id, 
                            workoutName: workoutNameController.text,
                            reps: int.parse(repsController.text),
                            sets: int.parse(setsController.text),
                            duration: int.parse(durationController.text),
                            day: selectedDay,
                          );

                          final response = await http.put(
                            Uri.parse('http://localhost:3001/workouts/${widget.workout.id}'), 
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: jsonEncode(updatedWorkout.toJson()),
                          );

                          if (response.statusCode == 200) {
                            widget.onUpdate(); 
                            Navigator.of(context).pop(); 
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Workout updated successfully!')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to update workout!')),
                            );
                          }
                        }
                      },
                      child: Text('Update', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
