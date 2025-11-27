import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int completed;
  final int total;
  const ProgressIndicatorWidget({required this.completed, required this.total, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Completed: $completed / $total'),
        LinearProgressIndicator(value: total == 0 ? 0 : completed / total),
      ],
    );
  }
}

