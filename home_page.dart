import 'package:flutter/material.dart';

class Task {
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;
  String category;

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.category,
  });
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Task> tasks = [];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime selectedDueDate = DateTime.now();
  String selectedCategory = "Personal";

  void _addTask() {
    if (titleController.text.isEmpty) return;

    setState(() {
      tasks.add(
        Task(
          title: titleController.text,
          description: descriptionController.text,
          dueDate: selectedDueDate,
          category: selectedCategory,
        ),
      );
    });

    titleController.clear();
    descriptionController.clear();
    Navigator.pop(context);
  }

  void _editTask(int index) {
    titleController.text = tasks[index].title;
    descriptionController.text = tasks[index].description;
    selectedDueDate = tasks[index].dueDate;
    selectedCategory = tasks[index].category;

    showDialog(context: context, builder: (context) => _taskDialog(index));
  }

  void _deleteTask(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Delete Task"),
            content: Text("Are you sure you want to delete this task?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    tasks.removeAt(index);
                  });
                  Navigator.pop(context);
                },
                child: Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _markTaskComplete(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
    });
  }

  Widget _taskDialog(int? index) {
    return AlertDialog(
      title: Text(index == null ? "Add Task" : "Edit Task"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: "Title"),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: "Description"),
          ),
          DropdownButton<String>(
            value: selectedCategory,
            items:
                ["Academic", "Personal", "Work"]
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value!;
              });
            },
          ),
          ElevatedButton(
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDueDate,
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  selectedDueDate = pickedDate;
                });
              }
            },
            child: Text("Select Due Date"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => index == null ? _addTask() : _updateTask(index),
          child: Text(index == null ? "Add" : "Update"),
        ),
      ],
    );
  }

  void _updateTask(int index) {
    setState(() {
      tasks[index] = Task(
        title: titleController.text,
        description: descriptionController.text,
        dueDate: selectedDueDate,
        category: selectedCategory,
        isCompleted: tasks[index].isCompleted,
      );
    });

    titleController.clear();
    descriptionController.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Asian College TO-DO"),
        backgroundColor: Color(0xFF0056b3), // Blue theme
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFffd700), // Gold theme
        child: Icon(Icons.add),
        onPressed:
            () => showDialog(
              context: context,
              builder: (context) => _taskDialog(null),
            ),
      ),
      body:
          tasks.isEmpty
              ? Center(child: Text("No tasks yet!"))
              : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  Task task = tasks[index];
                  bool isDueSoon =
                      task.dueDate.difference(DateTime.now()).inDays <= 2;

                  return Card(
                    color: isDueSoon ? Colors.red[100] : Colors.white,
                    child: ListTile(
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration:
                              task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                      subtitle: Text(
                        "${task.category} - Due: ${task.dueDate.toLocal()}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editTask(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(index),
                          ),
                          Checkbox(
                            value: task.isCompleted,
                            onChanged: (value) => _markTaskComplete(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
