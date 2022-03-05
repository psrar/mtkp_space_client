import 'package:flutter/material.dart';

class DomensView extends StatelessWidget {
  final Map<String, String> existingPairs;

  const DomensView({Key? key, required this.existingPairs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<List<String>> pairs = [];
    existingPairs.forEach((key, value) => pairs.add([key, value]));
    pairs.sort((a, b) => a[0].compareTo(b[0]));

    return ListView.separated(
      padding: const EdgeInsets.all(6),
      itemBuilder: (context, index) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            pairs[index][0],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Преподаватель: ' + pairs[index][1])
        ],
      ),
      separatorBuilder: (context, index) =>
          const Divider(color: Colors.black26),
      itemCount: pairs.length,
    );
  }
}
