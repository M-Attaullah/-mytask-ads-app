class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime date;
  final String color;

  const Note({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    this.color = 'yellow',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.millisecondsSinceEpoch,
      'color': color,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      color: map['color'] ?? 'yellow',
    );
  }

  Note copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? date,
    String? color,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      color: color ?? this.color,
    );
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, content: $content, date: $date, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.date == date &&
        other.color == color;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        content.hashCode ^
        date.hashCode ^
        color.hashCode;
  }
}
