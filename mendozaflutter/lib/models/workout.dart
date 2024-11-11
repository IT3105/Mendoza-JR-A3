class Workout {
  String id;
  String workoutName;
  int reps;
  int sets;
  int duration;
  String day; 

  Workout({
    required this.id,
    required this.workoutName,
    required this.reps,
    required this.sets,
    required this.duration,
    required this.day, 
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['_id'],
      workoutName: json['workoutName'],
      reps: json['reps'],
      sets: json['sets'],
      duration: json['duration'],
      day: json['day'] ?? 'Sunday',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workoutName': workoutName,
      'reps': reps,
      'sets': sets,
      'duration': duration,
      'day': day,
    };
  }
}
