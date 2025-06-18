import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:xml/xml.dart';

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
  State<HumanBodySelectorScreen> createState() => _HumanBodySelectorScreenState();
}

class _HumanBodySelectorScreenState extends State<HumanBodySelectorScreen> {
  String gender = 'Male';
  String side = 'Front';

  // Map<Path, title> - store the parsed SVG paths with their title attributes
  final Map<Path, String> _bodyParts = {};

  // The SVG's original viewport size from viewBox (default fallback)
  double svgWidth = 300;
  double svgHeight = 600;

  String? selectedPart;

  final Map<String, String> _svgPaths = {
    'Male Front': 'assets/image/male_front.svg',
    'Male Back': 'assets/image/male_back.svg',
    'Female Front': 'assets/image/female_front.svg',
    'Female Back': 'assets/image/female_back.svg',
  };

  @override
  void initState() {
    super.initState();
    _loadSvgData(_svgPaths['Male Front']!);
  }

  Future<void> _loadSvgData(String path) async {
    final svgString = await rootBundle.loadString(path);
    final svgDoc = XmlDocument.parse(svgString);

    _bodyParts.clear();

    // Get viewBox for coordinate conversion
    final svgElement = svgDoc.rootElement;
    final viewBoxAttr = svgElement.getAttribute('viewBox');
    if (viewBoxAttr != null) {
      final parts = viewBoxAttr.split(RegExp(r'[ ,]+'));
      if (parts.length == 4) {
        svgWidth = double.tryParse(parts[2]) ?? svgWidth;
        svgHeight = double.tryParse(parts[3]) ?? svgHeight;
      }
    } else {
      // Optionally parse width/height attributes if viewBox not present
      final widthAttr = svgElement.getAttribute('width');
      final heightAttr = svgElement.getAttribute('height');
      svgWidth = widthAttr != null ? double.tryParse(widthAttr) ?? svgWidth : svgWidth;
      svgHeight = heightAttr != null ? double.tryParse(heightAttr) ?? svgHeight : svgHeight;
    }

    // Parse all <path> elements
    final paths = svgDoc.findAllElements('path');
    for (final pathElement in paths) {
      final d = pathElement.getAttribute('d');
      final title = pathElement.getAttribute('title');
      if (d != null && title != null) {
        final path = parseSvgPath(d);
        _bodyParts[path] = title;
      }
    }

    setState(() {});
  }

  void _onTapDown(TapDownDetails details) {
    final localPos = details.localPosition;
    // The widget size for the SvgPicture.asset (hardcoded here)
    const widgetWidth = 300.0;
    const widgetHeight = 600.0;

    // Map tap from widget space to SVG viewport space
    final dx = localPos.dx * (svgWidth / widgetWidth);
    final dy = localPos.dy * (svgHeight / widgetHeight);
    final svgPos = Offset(dx, dy);

    for (final entry in _bodyParts.entries) {
      if (entry.key.contains(svgPos)) {
        print(entry);
        final partTitle = entry.value;
        print('Selected part title: $partTitle');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected Part: $partTitle')),
        );
        break;
      }
    }
  }

  void _updateView() {
    final key = '$gender $side';
    final path = _svgPaths[key]!;
    selectedPart = null;
    _loadSvgData(path);
  }

  @override
  Widget build(BuildContext context) {
    final String currentKey = '$gender $side';
    return Scaffold(
      appBar: AppBar(
        title: Text('$gender $side View'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Gender Toggle
          ToggleButtons(
            isSelected: [gender == 'Male', gender == 'Female'],
            onPressed: (index) {
              setState(() {
                gender = index == 0 ? 'Male' : 'Female';
                _updateView();
              });
            },
            children: const [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Male")),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Female")),
            ],
          ),
          const SizedBox(height: 10),
          // Side Toggle
          ToggleButtons(
            isSelected: [side == 'Front', side == 'Back'],
            onPressed: (index) {
              setState(() {
                side = index == 0 ? 'Front' : 'Back';
                _updateView();
              });
            },
            children: const [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Front")),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Back")),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTapDown: _onTapDown,
                child: SvgPicture.asset(
                  _svgPaths[currentKey]!,
                  width: 300,
                  height: 600,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
