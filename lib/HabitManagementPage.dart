import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class HabitManagementPage extends StatefulWidget {
  final List<Map<String, String>> habits;
  final Function(List<Map<String, String>>) onUpdateHabits;
  final int? editingIndex;

  const HabitManagementPage({
    super.key,
    required this.habits,
    required this.onUpdateHabits,
    this.editingIndex,
  });

  @override
  _HabitManagementPageState createState() => _HabitManagementPageState();
}

class _HabitManagementPageState extends State<HabitManagementPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  int? _editingIndex;
  String? _currentHabitId;
  final _formKey = GlobalKey<FormState>();
  final List<String> _categories = ['Health', 'Work', 'Study', 'Exercise', 'Personal', 'Social', 'General'];

  @override
  void initState() {
    super.initState();
    _editingIndex = widget.editingIndex;

    if (_editingIndex != null) {
      final habit = widget.habits[_editingIndex!];
      _nameController.text = habit['name'] ?? '';
      _categoryController.text = habit['category'] ?? 'General';
      _currentHabitId = habit['id'];

      try {
        if (habit['time'] != null && habit['time']!.isNotEmpty) {
          _selectedDateTime = DateFormat('yyyy-MM-dd HH:mm').parse(habit['time']!);
        } else {
          _selectedDateTime = DateTime.now();
        }
      } catch (e) {
        _selectedDateTime = DateTime.now();
      }
    }
    _timeController.text = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        _timeController.text = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime);
      });
    }
  }

  // UX IMPROVEMENT: Shows feedback and clears form
  void _saveHabit() {
    if (!_formKey.currentState!.validate()) return;

    final bool isUpdating = _editingIndex != null;
    const Uuid uuid = Uuid();

    final Map<String, String> newHabit = {
      'name': _nameController.text.trim(),
      'time': _timeController.text,
      'category': _categoryController.text.isNotEmpty ? _categoryController.text : 'General',
    };

    setState(() {
      if (isUpdating) {
        newHabit['id'] = _currentHabitId!;
        widget.habits[_editingIndex!] = newHabit;
      } else {
        newHabit['id'] = uuid.v4();
        widget.habits.add(newHabit);
      }
      widget.onUpdateHabits(widget.habits);
    });

    // 1. Show a confirmation SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isUpdating ? 'Habit updated successfully!' : 'Habit added successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // ADDED: Clear the form fields after saving/updating a habit
    _resetForm();

    // 2. To stay on the page, the Navigator.pop(context); line should remain commented out:
    // Navigator.pop(context);
  }

  void _editHabit(int index) {
    final habit = widget.habits[index];
    setState(() {
      _editingIndex = index;
      _nameController.text = habit['name'] ?? '';
      _categoryController.text = habit['category'] ?? 'General';
      _currentHabitId = habit['id'];

      try {
        if (habit['time'] != null && habit['time']!.isNotEmpty) {
          _selectedDateTime = DateFormat('yyyy-MM-dd HH:mm').parse(habit['time']!);
          _timeController.text = habit['time']!;
        } else {
          _selectedDateTime = DateTime.now();
          _timeController.text = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime);
        }
      } catch (e) {
        _timeController.text = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
      }
    });
  }

  void _deleteHabit(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this habit? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.teal)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.habits.removeAt(index);
                widget.onUpdateHabits(widget.habits);
                _resetForm(); // Reset form after deletion
                Navigator.pop(context);
              });
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Habit deleted.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _categoryController.clear();
    _selectedDateTime = DateTime.now();
    _timeController.text = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime);
    setState(() {
      _editingIndex = null;
      _currentHabitId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingIndex != null ? 'Edit Habit' : 'Add Habit'),
        backgroundColor: Colors.teal[800], // Consistent app bar color
        iconTheme: const IconThemeData(color: Colors.white), // Consistent icon color
        actions: [
          if (_editingIndex != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white), // Consistent icon color
              onPressed: _resetForm,
              tooltip: 'Cancel Editing',
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _editingIndex != null ? 'Edit Habit Details' : 'Create New Habit',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Habit Name',
                          labelStyle: const TextStyle(color: Colors.teal),
                          prefixIcon: const Icon(Icons.checklist, color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.teal),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a habit name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _categoryController.text.isEmpty
                            ? null
                            : _categories.contains(_categoryController.text)
                                ? _categoryController.text
                                : null,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: const TextStyle(color: Colors.teal),
                          prefixIcon: const Icon(Icons.category, color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                            focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.teal),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _categoryController.text = value ?? '';
                          });
                        },
                        dropdownColor: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _timeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Schedule Time',
                          labelStyle: const TextStyle(color: Colors.teal),
                          prefixIcon: const Icon(Icons.access_time, color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                            focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.teal),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today, color: Colors.teal),
                            onPressed: () => _selectDateTime(context),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        onTap: () => _selectDateTime(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a time';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _saveHabit,
                          style: ElevatedButton.styleFrom( // Added style for consistency
                            backgroundColor: Colors.teal[800],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: Text(
                            _editingIndex != null ? 'Update Habit' : 'Add Habit',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Your Habits (${widget.habits.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            widget.habits.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: widget.habits.length,
                    itemBuilder: (context, index) {
                      final habit = widget.habits[index];
                      final formattedTime = habit['time'] != null && habit['time']!.isNotEmpty
                          ? DateFormat('EEE, MMM d • h:mm a').format(
                                DateFormat('yyyy-MM-dd HH:mm').parse(habit['time']!))
                          : 'No time set';
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(habit['category']).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getCategoryIcon(habit['category']),
                              color: _getCategoryColor(habit['category']),
                              size: 24,
                            ),
                          ),
                          title: Text(
                            habit['name'] ?? 'Unnamed Habit',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formattedTime,
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                              if (habit['category'] != null && habit['category']!.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(habit['category']).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    habit['category']!,
                                    style: TextStyle(
                                      color: _getCategoryColor(habit['category']),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.teal),
                                onPressed: () => _editHabit(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteHabit(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist_rtl, size: 64, color: Colors.teal[200]),
            const SizedBox(height: 16),
            const Text(
              'No habits yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first habit using the form above',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'health': return Icons.favorite;
      case 'work': return Icons.work;
      case 'study': return Icons.school;
      case 'exercise': return Icons.directions_run;
      case 'personal': return Icons.person;
      case 'social': return Icons.people;
      default: return Icons.check_circle;
    }
  }

  Color _getCategoryColor(String? category) {
    final colors = {
      'Health': Colors.green,
      'Work': Colors.blue,
      'Study': Colors.purple,
      'Exercise': Colors.orange,
      'Personal': Colors.pink,
      'Social': Colors.cyan,
      'General': Colors.grey,
    };
    return colors[category] ?? Colors.grey;
  }
}
