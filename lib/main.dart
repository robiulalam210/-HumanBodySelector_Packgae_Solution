import 'package:flutter/material.dart';
import 'package:image_parts/svg_painter/maps.dart';
import 'human_body_selector.dart';
import 'svg_painter/models/body_part.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HumanBodySelectorScreen(),
    );
  }
}

class HumanBodySelectorScreen extends StatefulWidget {
  const HumanBodySelectorScreen({super.key});

  @override
  State<HumanBodySelectorScreen> createState() =>
      _HumanBodySelectorScreenState();
}

class _HumanBodySelectorScreenState extends State<HumanBodySelectorScreen> {
  String currentView = 'Male';

  final Map<String, String> humanMap = {
    'Male': Maps.MALE,
    'Male1': Maps.MALE1,
    'Human': Maps.HUMAN,
    'Human1': Maps.HUMAN1,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Human Body Selector')),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: humanMap.keys.map((key) {
              return ChoiceChip(
                label: Text(key),
                selected: currentView == key,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      currentView = key;
                    });
                  }
                },
              );
            }).toList(),
          ),
          Expanded(
            child: Container(
              child: HumanBodySelector(
                key: ValueKey(currentView),
                map: humanMap[currentView]!,
                multiSelect: false,
                strokeColor: Colors.cyan,
                toggle: true,
                onChanged: (bodyPart, active) {
                  debugPrint('ggggggggggggggggggSelected: ${bodyPart} - Active: $active');
                  debugPrint(
                      "${bodyPart.reversed.first.title} title ${bodyPart.reversed.first.title} id ${bodyPart.first.id} pain Level: ${bodyPart.first.painLevel} obj: ${bodyPart.first.props} active part ${active?.title}");

                },
                onLevelChanged: (List<BodyPart> parts) {
                  for (var part in parts) {
                    debugPrint(
                        "aaaaaaa${part.title} ${part.path} ${part.id} ${part.painLevel}");
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
