import 'package:flutter/material.dart';

class Plan {
  String name;
  String description;
  String date;
  String status;

  Plan({required this.name, required this.description, required this.date, required this.status});
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  int _planId = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          ],
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
    final result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(status == 'pending' ? 'Edit Plan' : 'Add Plan'),
          content: Column(
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                final description = descController.text;
                final date = dateController.text;
                final status = statusController.text;
                if (name.isNotEmpty && description.isNotEmpty && date.isNotEmpty) {
                  if (planIndex == -1) {
                    _planList.add(Plan(name: name, description: description, date: date, status: status));
                  } else {
                    _planList[planIndex] = Plan(name: name, description: description, date: date, status: status);
                  }
                  setState(() {});
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

  }
}
