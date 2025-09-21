
import 'package:flutter/material.dart';

class QuickNumbersScreen extends StatelessWidget {
  const QuickNumbersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quick Numbers & Tutorials')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: Icon(Icons.phone, color: Colors.red),
                title: Text('Emergency Numbers'),
                subtitle: Text('Quick access to emergency contacts'),
                onTap: () {
                  // TODO: Show emergency numbers
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.school, color: Colors.blue),
                title: Text('Emergency Tutorials'),
                subtitle: Text('Learn basic emergency response'),
                onTap: () {
                  // TODO: Show tutorials
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}