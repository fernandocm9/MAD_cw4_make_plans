import 'package:flutter/material.dart';

class Plan {
  String name;
  String description;
  String selectedDate;
  String status;

  Plan({required this.name, required this.description, required this.selectedDate, required this.status});
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const PlanManagerScreen(title: 'Make Plans'),
    );
  }
}

class PlanManagerScreen extends StatefulWidget {
  const PlanManagerScreen({super.key, required this.title});

  final String title;

  @override
  State<PlanManagerScreen> createState() => _PlanManagerScreen();
}

class _PlanManagerScreen extends State<PlanManagerScreen> {
  late TextEditingController nameController;
  late TextEditingController descController;
  late TextEditingController dateController;
  late TextEditingController statusController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descController = TextEditingController();
    dateController = TextEditingController();
    statusController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    dateController.dispose();
    statusController.dispose();
    super.dispose();
  }
  
  List<Plan> _planList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _planList.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onDoubleTap: () {setState(() {_planList.removeAt(index);});},
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0) {
                  setState(() {_planList[index].status = 'completed';});
                } else if (details.delta.dx < 0) {
                  setState(() {_planList[index].status = 'pending';});
                }
              },
              child: ListTile(
                title: Text(_planList[index].name),
                tileColor: _planList[index].status == 'completed' ? Colors.green[100] : Colors.orangeAccent,
                subtitle: Text(_planList[index].description),
                trailing: Text(_planList[index].selectedDate),
                onLongPress: () => _openAddPlanDialog(status: _planList[index].status, planIndex: index),
              )
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddPlanDialog(status:'pending'),
        tooltip: 'Add Plan',
        child: const Icon(Icons.add),
      ),
    );
  }

    Future<void> _openAddPlanDialog({String status = 'pending', int planIndex = -1}) async {
    // Reset controllers for new plans, or load existing data if editing
    if (planIndex == -1) {
      nameController.clear();
      descController.clear();
      dateController.clear();
    } else {
      nameController.text = _planList[planIndex].name;
      descController.text = _planList[planIndex].description;
      dateController.text = _planList[planIndex].selectedDate;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(planIndex == -1 ? 'Add Plan' : 'Edit Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      dateController.text = "${pickedDate.toLocal()}".split(' ')[0]; // Format: YYYY-MM-DD
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Select Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                final description = descController.text;
                final date = dateController.text;

                if (name.isNotEmpty && description.isNotEmpty && date.isNotEmpty) {
                  setState(() {
                    if (planIndex == -1) {
                      _planList.add(Plan(
                        name: name,
                        description: description,
                        selectedDate: date,
                        status: status, // Use the passed status
                      ));
                    } else {
                      _planList[planIndex] = Plan(
                        name: name,
                        description: description,
                        selectedDate: date,
                        status: _planList[planIndex].status, // Preserve status when editing
                      );
                    }
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text(planIndex == -1 ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }
}
