import 'package:flutter/material.dart';
import 'dependencies.dart';
import 'features/product_list/presentation/page.dart';

Future<void> main() async {
  await initialiseDependencies();

  runApp(const ProductCatalogApp());
}

class ProductCatalogApp extends StatelessWidget {
  const ProductCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Catalog',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const ProductListPage(),
    );
  }
}
