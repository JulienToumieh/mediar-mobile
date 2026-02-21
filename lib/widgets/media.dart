import 'package:flutter/material.dart';

import '../services/api.dart';

class Media extends StatelessWidget {
  final int id;
  final String imageUrl;

  const Media({
    super.key,
    required this.id,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        '${API.apiBaseUrl}$imageUrl',
        fit: BoxFit.cover,
      ),
    );
  }
}

