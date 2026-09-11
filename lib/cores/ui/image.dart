import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({required this.size, required this.url, super.key});

  const ProductImage.thumbnail({
    required this.url,
    this.size = const Size(120, 120),
    super.key,
  });

  final String url;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: size.width,
      height: size.height,
      fit: BoxFit.contain,
      placeholder: (context, url) {
        return Skeletonizer(
          child: Container(
            width: size.width,
            height: size.height,
            color: Colors.green, // Any color works
          ),
        );
      },
      errorWidget: (context, url, error) {
        return const Icon(Icons.broken_image);
      },
    );
  }
}
