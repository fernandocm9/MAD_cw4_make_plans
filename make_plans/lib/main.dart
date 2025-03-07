import 'dart:ui';
import 'package:flutter/material.dart';

class Plan {
  String name;
  String description;
  String selectedDate;
  String status;

  Plan({
    required this.name,
    required this.description,
    required this.selectedDate,
    required this.status,
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  bool isDragging = false; // Add this line

  List<Plan> _planList = [];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descController = TextEditingController();
    dateController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(1, 6, animValue)!;
        final double scale = lerpDouble(1, 1.02, animValue)!;
        return Transform.scale(
          scale: scale,
          child: Card(
            elevation: elevation,
            color: _planList[index].status == 'completed'
                ? Colors.green[100]
                : Colors.orangeAccent,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ReorderableListView(
        proxyDecorator: proxyDecorator,
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final Plan item = _planList.removeAt(oldIndex);
            _planList.insert(newIndex, item);
          });
        },
        children: List.generate(_planList.length, (index) {
          return GestureDetector(
            key: ValueKey(_planList[index]),
            onHorizontalDragStart: (details) {
              setState(() {
                isDragging = true;
              });
            },
            onHorizontalDragEnd: (details) {
              setState(() {
                isDragging = false;
                if (details.primaryVelocity! > 0) {
                  _planList[index].status = 'completed';
                } else if (details.primaryVelocity! < 0) {
                  _planList[index].status = 'pending';
                }
              });
            },
            child: ListTile(
              title: Text(_planList[index].name),
              subtitle: Text(_planList[index].description),
              tileColor: _planList[index].status == 'completed' ? Colors.green[100] : Colors.orangeAccent,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_planList[index].selectedDate),
                  const SizedBox(width: 10),
                  if (!isDragging) 
                    ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                ],
              ),
              onLongPress: () =>
                  _openAddPlanDialog(status: _planList[index].status, planIndex: index),
            ),
              onDoubleTap: () {
                setState(() {
                  _planList.removeAt(index);
                });
              },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddPlanDialog(status: 'pending'),
        tooltip: 'Add Plan',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openAddPlanDialog({String status = 'pending', int planIndex = -1}) async {
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
                      dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
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
                        status: status,
                      ));
                    } else {
                      _planList[planIndex] = Plan(
                        name: name,
                        description: description,
                        selectedDate: date,
                        status: _planList[planIndex].status,
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
