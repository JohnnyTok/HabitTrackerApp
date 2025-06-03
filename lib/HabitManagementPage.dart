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
  final List<String> _categories = ['Health', 'Work', 'Study', 'Exercise', 'Personal', 'Social'];

  @override
  void initState() {
    super.initState();
    // Initialize with current time
    _timeController.text = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime);
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (pickedDate == null) return;
    
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
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

  void _saveHabit() {
    if (!_formKey.currentState!.validate()) return;
    
    final newHabit = {
      'name': _nameController.text,
      'time': _timeController.text,
      'category': _categoryController.text.isNotEmpty 
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
          _selectedDateTime = DateFormat('yyyy-MM-dd HH:mm').parse(habit['time']!);
          _timeController.text = habit['time']!;
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
        title: const Text('Delete Habit'),
        content: const Text('Are you sure you want to delete this habit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.habits.removeAt(index);
                widget.onUpdateHabits(widget.habits);
                Navigator.pop(context);
              });
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
    _editingIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Management'),
        actions: [
          if (_editingIndex != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _resetForm,
              tooltip: 'Cancel Editing',
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Habit Form
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Habit Name',
                          prefixIcon: Icon(Icons.checklist),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a habit name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _categoryController.text.isEmpty ? null : _categoryController.text,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
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
                        validator: (value) {
                          return null; // Category is optional
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _timeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Schedule Time',
                          prefixIcon: const Icon(Icons.access_time),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDateTime(context),
                          ),
                        ),
                        onTap: () => _selectDateTime(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a time';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _saveHabit,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(_editingIndex != null ? 'Update Habit' : 'Add Habit'),
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
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (widget.habits.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Clear All Habits'),
                            content: const Text('Are you sure you want to delete all habits?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    widget.habits.clear();
                                    widget.onUpdateHabits(widget.habits);
                                    Navigator.pop(context);
                                  });
                                },
                                child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Habit List
            Expanded(
              child: widget.habits.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.checklist, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No habits yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          Text(
                            'Add your first habit using the form above',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.habits.length,
                      itemBuilder: (context, index) {
                        final habit = widget.habits[index];
                        final formattedTime = habit['time'] != null
                            ? DateFormat('EEE, MMM d • h:mm a').format(
                                DateFormat('yyyy-MM-dd HH:mm').parse(habit['time']!))
                            : 'No time set';
                            
                        return Dismissible(
                          key: Key('$index-${habit['name']}'),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            _deleteHabit(index);
                            return false;
                          },
                          child: Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(habit['name'] ?? ''),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(formattedTime),
                                  if (habit['category'] != null && habit['category']!.isNotEmpty)
                                    Chip(
                                      label: Text(
                                        habit['category']!,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: _getCategoryColor(habit['category']!),
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                    ),
                                ],
                              ),
                              leading: const Icon(Icons.repeat),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _editHabit(index),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Health': Colors.green[100],
      'Work': Colors.blue[100],
      'Study': Colors.purple[100],
      'Exercise': Colors.orange[100],
      'Personal': Colors.pink[100],
      'Social': Colors.teal[100],
    };
    return colors[category] ?? Colors.grey[200]!;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}