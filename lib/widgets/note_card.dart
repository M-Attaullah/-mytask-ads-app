import 'package:flutter/material.dart';
import '../models/task_model.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NoteCard({
    Key? key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color displayColor = _getColor(note.color);
    return Card(
      color: displayColor.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Note title
                  Expanded(
                    child: Text(
                      note.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.primaryColorDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Delete button
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    tooltip: 'Delete note',
                  ),
                ],
              ),
              if (note.content.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  note.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(note.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(radius: 8, backgroundColor: displayColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColor(String color) {
    switch (color) {
      case 'yellow':
        return Colors.yellow;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'pink':
        return Colors.pink;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
