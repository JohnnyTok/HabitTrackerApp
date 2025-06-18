import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HabitManagementPage extends StatefulWidget {
  final List<Map<String, String>> habits;
  final Function(List<Map<String, String>>) onUpdateHabits;

  const HabitManagementPage({
    super.key,
    required this.habits,
    required this.onUpdateHabits,
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
  final _formKey = GlobalKey<FormState>();
  final List<String> _categories = [
    'Health',
    'Work',
    'Study',
    'Exercise',
    'Personal',
    'Social',
  ];

  @override
  void initState() {
    super.initState();
    _timeController.text = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(_selectedDateTime);
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
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
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
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
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
        _timeController.text = DateFormat(
          'yyyy-MM-dd HH:mm',
        ).format(_selectedDateTime);
      });
    }
  }

  void _saveHabit() {
    if (!_formKey.currentState!.validate()) return;

    final newHabit = {
      'name': _nameController.text,
      'time': _timeController.text,
      'category':
          _categoryController.text.isNotEmpty
              ? _categoryController.text
              : 'General',
    };

    setState(() {
      if (_editingIndex != null) {
        widget.habits[_editingIndex!] = newHabit;
      } else {
        widget.habits.add(newHabit);
      }

      widget.onUpdateHabits(widget.habits);
      _resetForm();
    });
  }

  void _editHabit(int index) {
    final habit = widget.habits[index];
    setState(() {
      _editingIndex = index;
      _nameController.text = habit['name'] ?? '';
      _categoryController.text = habit['category'] ?? '';

      try {
        if (habit['time'] != null) {
          _selectedDateTime = DateFormat(
            'yyyy-MM-dd HH:mm',
          ).parse(habit['time']!);
          _timeController.text = habit['time']!;
        }
      } catch (e) {
        _timeController.text = DateFormat(
          'yyyy-MM-dd HH:mm',
        ).format(DateTime.now());
      }
    });
  }

  void _deleteHabit(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Delete Habit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Are you sure you want to delete this habit? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    widget.habits.removeAt(index);
                    widget.onUpdateHabits(widget.habits);
                    Navigator.pop(context);
                  });
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
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
    _timeController.text = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(_selectedDateTime);
    _editingIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingIndex != null ? 'Edit Habit' : 'Add Habit'),
        backgroundColor: Colors.teal[800],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_editingIndex != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _resetForm,
              tooltip: 'Cancel Editing',
            ),
        ],
      ),
      body: Column(
        children: [
          // Form Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Habit Form
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
                              _editingIndex != null
                                  ? 'Edit Habit'
                                  : 'Create New Habit',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Habit Name
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Habit Name',
                                labelStyle: const TextStyle(color: Colors.teal),
                                prefixIcon: const Icon(
                                  Icons.checklist,
                                  color: Colors.teal,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.teal,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a habit name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Category Selector
                            DropdownButtonFormField<String>(
                              value:
                                  _categoryController.text.isEmpty
                                      ? null
                                      : _categoryController.text,
                              decoration: InputDecoration(
                                labelText: 'Category',
                                labelStyle: const TextStyle(color: Colors.teal),
                                prefixIcon: const Icon(
                                  Icons.category,
                                  color: Colors.teal,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.teal,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              items:
                                  _categories.map((String category) {
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
                              validator: (value) {
                                return null; // Category is optional
                              },
                              dropdownColor: Colors.white,
                            ),
                            const SizedBox(height: 20),

                            // Time Picker
                            TextFormField(
                              controller: _timeController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Schedule Time',
                                labelStyle: const TextStyle(color: Colors.teal),
                                prefixIcon: const Icon(
                                  Icons.access_time,
                                  color: Colors.teal,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.teal,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.calendar_today,
                                    color: Colors.teal,
                                  ),
                                  onPressed: () => _selectDateTime(context),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
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

                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _saveHabit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal[800],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                child: Text(
                                  _editingIndex != null
                                      ? 'Update Habit'
                                      : 'Add Habit',
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
                  ),
                  const SizedBox(height: 24),

                  // Habit List Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Habits (${widget.habits.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.habits.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text(
                                        'Clear All Habits',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: const Text(
                                        'Are you sure you want to delete all habits? This action cannot be undone.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.teal,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              widget.habits.clear();
                                              widget.onUpdateHabits(
                                                widget.habits,
                                              );
                                              Navigator.pop(context);
                                            });
                                          },
                                          child: const Text(
                                            'Clear All',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            child: const Text(
                              'Clear All',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Habit List
          widget.habits.isEmpty
              ? _buildEmptyState()
              : Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 16,
                    left: 16,
                    right: 16,
                  ),
                  itemCount: widget.habits.length,
                  itemBuilder: (context, index) => _buildHabitItem(index),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist, size: 64, color: Colors.teal[200]),
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

  Widget _buildHabitItem(int index) {
    final habit = widget.habits[index];
    final formattedTime =
        habit['time'] != null
            ? DateFormat(
              'EEE, MMM d • h:mm a',
            ).format(DateFormat('yyyy-MM-dd HH:mm').parse(habit['time']!))
            : 'No time set';

    return Dismissible(
      key: Key('$index-${habit['name']}'),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        _deleteHabit(index);
        return false;
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(
                      habit['category'],
                    ).withOpacity(0.1),
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
          trailing: IconButton(
            icon: const Icon(Icons.edit, color: Colors.teal),
            onPressed: () => _editHabit(index),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'health':
        return Icons.favorite;
      case 'work':
        return Icons.work;
      case 'study':
        return Icons.school;
      case 'exercise':
        return Icons.directions_run;
      case 'personal':
        return Icons.person;
      case 'social':
        return Icons.people;
      default:
        return Icons.check_circle;
    }
  }

  Color _getCategoryColor(String? category) {
    final colors = {
      'Health': Colors.green,
      'Work': Colors.blue,
      'Study': Colors.purple,
      'Exercise': Colors.orange,
      'Personal': Colors.pink,
      'Social': Colors.teal,
    };
    return colors[category] ?? Colors.grey;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
