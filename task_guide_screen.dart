import 'package:flutter/material.dart';

class TaskGuideScreen extends StatefulWidget {
  const TaskGuideScreen({super.key});
  @override
  State<TaskGuideScreen> createState() => _TaskGuideScreenState();
}

class _TaskGuideScreenState extends State<TaskGuideScreen> {
  final Map<String, List<String>> _tasks = {
    'Morning routine': [
      'Wake up and sit up slowly',
      'Drink a glass of water',
      'Go to the bathroom and wash your face',
      'Get dressed',
      'Come to the kitchen for breakfast',
    ],
    'Taking medicine': [
      'Go to the medicine box',
      'Open the box for today',
      'Take out your tablets',
      'Drink water and swallow them',
      'Close the box and put it back',
    ],
    'Before leaving home': [
      'Turn off the gas knob',
      'Turn off all taps',
      'Pick up your keys',
      'Lock the front door',
      'Your necklace is around your neck — you are safe',
    ],
    'Going to sleep': [
      'Turn off lights in all rooms',
      'Check that the gas is off',
      'Lock the front door',
      'Drink water',
      'Go to bed — goodnight',
    ],
  };

  String? _selectedTask;
  int _stepIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (_selectedTask == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('What do I need to do?',
              style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          toolbarHeight: 70,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: _tasks.keys.map((task) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 80),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => setState(() {
                  _selectedTask = task;
                  _stepIndex = 0;
                }),
                child: Text(task,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            );
          }).toList(),
        ),
      );
    }

    final steps  = _tasks[_selectedTask]!;
    final isLast = _stepIndex == steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedTask!,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold)),
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () => setState(() => _selectedTask = null),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(steps.length, (i) {
                return Container(
                  width: i == _stepIndex ? 20 : 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: i <= _stepIndex
                        ? Colors.orange.shade700
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Text('Step ${_stepIndex + 1} of ${steps.length}',
                style:
                    const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 40),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: Colors.orange.shade300, width: 3),
                ),
                child: Center(
                  child: Text(
                    steps[_stepIndex],
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                if (_stepIndex > 0) ...[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        minimumSize: const Size(0, 70),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () =>
                          setState(() => _stepIndex--),
                      child: const Text('Back',
                          style: TextStyle(
                              fontSize: 22, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLast
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      minimumSize: const Size(0, 70),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: isLast
                        ? () => setState(() => _selectedTask = null)
                        : () => setState(() => _stepIndex++),
                    child: Text(
                      isLast ? 'Done!' : 'Next step',
                      style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}