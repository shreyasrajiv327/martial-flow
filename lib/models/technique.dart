class Technique {
  final String id;
  final String name;
  final String category;
  final String level;
  final List<String> steps;

  Technique({
    required this.id,
    required this.name,
    required this.category,
    required this.level,
    required this.steps,
  });

  factory Technique.fromMap(String id, Map<String, dynamic> map) => Technique(
    id: id,
    name: map['name'] ?? '',
    category: map['category'] ?? '',
    level: map['level'] ?? '',
    steps: List<String>.from(map['steps'] ?? []),
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'category': category,
    'level': level,
    'steps': steps,
  };
}
