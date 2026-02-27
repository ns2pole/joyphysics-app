import 'package:flutter/material.dart';

class FormulaCollectionView extends StatefulWidget {
  const FormulaCollectionView({super.key});

  @override
  State<FormulaCollectionView> createState() => _FormulaCollectionViewState();
}

class _FormulaCollectionViewState extends State<FormulaCollectionView> {
  final _pageController = PageController();
  int _index = 0;

  static const _images = <String>[
    'assets/others/physics_formulas_1.png',
    'assets/others/physics_formulas_2.png',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('物理公式集'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('${_index + 1}/${_images.length}'),
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _images.length,
        onPageChanged: (v) => setState(() => _index = v),
        itemBuilder: (context, i) {
          return Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 6.0,
              child: Image.asset(
                _images[i],
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}

