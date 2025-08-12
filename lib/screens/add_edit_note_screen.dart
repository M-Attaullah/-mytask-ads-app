import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../view_models/task_view_model.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note; // null for add, note object for edit

  const AddEditNoteScreen({Key? key, this.note}) : super(key: key);

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedColor = 'yellow';

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final note = widget.note!;
      _titleController.text = note.title;
      _contentController.text = note.content;
      _selectedDate = note.date;
      _selectedColor = note.color;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'Add New Note'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveNote,
            child: const Text(
              'SAVE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Note Title *',
                  hintText: 'Enter note title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a note title';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 16),

              // Content field
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Enter note content',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 16),

              // Date picker
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Color dropdown
              DropdownButtonFormField<String>(
                value: _selectedColor,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.color_lens),
                ),
                items: ['yellow', 'blue', 'green', 'pink', 'purple']
                    .map(
                      (color) => DropdownMenuItem(
                        value: color,
                        child: Row(
                          children: [
                            _buildColorCircle(color),
                            const SizedBox(width: 8),
                            Text(color[0].toUpperCase() + color.substring(1)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedColor = value!;
                  });
                },
              ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'UPDATE NOTE' : 'ADD NOTE',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorCircle(String color) {
    Color displayColor;
    switch (color) {
      case 'yellow':
        displayColor = Colors.yellow;
        break;
      case 'blue':
        displayColor = Colors.blue;
        break;
      case 'green':
        displayColor = Colors.green;
        break;
      case 'pink':
        displayColor = Colors.pink;
        break;
      case 'purple':
        displayColor = Colors.purple;
        break;
      default:
        displayColor = Colors.grey;
    }
    return CircleAvatar(radius: 8, backgroundColor: displayColor);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final note = Note(
      id: _isEditing ? widget.note!.id : null,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      date: _selectedDate,
      color: _selectedColor,
    );
    final noteViewModel = context.read<NoteViewModel>();
    bool success;
    if (_isEditing) {
      success = await noteViewModel.updateNote(note);
    } else {
      success = await noteViewModel.addNote(note);
    }
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Note updated successfully!'
                : 'Note added successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Failed to update note' : 'Failed to add note',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
