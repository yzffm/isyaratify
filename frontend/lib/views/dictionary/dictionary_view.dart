import 'package:flutter/material.dart';

import '../../widgets/placeholder_scaffold.dart';

/// Placeholder kamus. Data A-Z dan ilustrasi menyusul setelah referensi
/// alfabet tervalidasi.
class DictionaryView extends StatelessWidget {
  const DictionaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScaffold(
      title: 'Kamus alfabet',
      children: [Text('Daftar huruf A–Z akan tampil di sini.')],
    );
  }
}
