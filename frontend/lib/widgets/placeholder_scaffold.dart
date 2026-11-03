import 'package:flutter/material.dart';

/// Kerangka halaman placeholder yang konsisten dan responsif (konten dibatasi
/// lebarnya agar nyaman di desktop web maupun mobile portrait).
class PlaceholderScaffold extends StatelessWidget {
  const PlaceholderScaffold({
    super.key,
    required this.title,
    required this.children,
    this.showAppBar = true,
  });

  final String title;
  final List<Widget> children;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(title)) : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
