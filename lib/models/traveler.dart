class Traveler {
  final String uid;
  final String firstName;
  final String lastName;
  final String username;
  final int age;
  final String gender;
  final String topDestination;
  final String dnaVibe;
  final DateTime? travelDate;
  final String continent;

  const Traveler({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.age,
    required this.gender,
    required this.topDestination,
    required this.dnaVibe,
    this.travelDate,
    required this.continent,
  });

  factory Traveler.fromMap(Map<String, dynamic> map) {
    return Traveler(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      username: map['username'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      topDestination: map['topDestination'] ?? '',
      dnaVibe: map['dnaVibe'] ?? '',
      travelDate: map['travelDate'] != null
          ? (map['travelDate'] as dynamic).toDate()
          : null,
      continent: map['continent'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'firstName': firstName,
    'lastName': lastName,
    'username': username,
    'age': age,
    'gender': gender,
    'topDestination': topDestination,
    'dnaVibe': dnaVibe,
    'travelDate': travelDate,
    'continent': continent,
  };
}