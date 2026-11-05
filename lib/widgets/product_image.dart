import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
  });

  final String source;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (source.isEmpty) return _placeholder();

    if (source.startsWith('data:image/')) {
      try {
        return Image.memory(
          base64Decode(source.split(',').last),
          fit: fit,
          errorBuilder: (_, _, _) => _placeholder(),
        );
      } on FormatException {
        return _placeholder();
      }
    }

    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }

    if (kIsWeb) return _placeholder();

    return Image.file(
      File(source),
      fit: fit,
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }

  Widget _placeholder() => Container(
    color: const Color(0xFFE6F2E9),
    alignment: Alignment.center,
    child: const Icon(
      Icons.fastfood_outlined,
      size: 36,
      color: Color(0xFF176B45),
    ),
  );
}
