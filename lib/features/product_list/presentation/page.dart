import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../models/models.dart';
import '../../product_detail/presentation/page.dart';
import 'bloc.dart';
import 'state.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductListBloc(),
      child: const _Content(),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content();

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    context.read<ProductListBloc>().add(ProductListEventInitialise());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductListBloc, ProductListState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Product Listing'),
            backgroundColor: Colors.white,
            shadowColor: Colors.black26,
            elevation: 2,
            centerTitle: true,
          ),
          body: Column(
            children: [
              Center(
                child: Container(
                  width: 800,
                  padding: const EdgeInsets.only(top: 20),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => context.read<ProductListBloc>().add(
                      ProductListEventSearch(query: value),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'eg. "phone"',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: switch (state) {
                  ProductListStateInitial() => const SizedBox(),
                  ProductListStateInProgress(:final products) =>
                    switch (products) {
                      ProductList(:final products) => _ProductListTile(
                        items: products,
                      ),
                      null => const Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(top: 48),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    },
                  ProductListStateSuccess(:final products) =>
                    (products.products?.isEmpty ?? false)
                        ? const _StatusText(text: 'Items not found')
                        : _ProductListTile(items: products.products),
                  ProductListStateSuccessMax(:final products) =>
                    _ProductListTile(items: products.products),
                  ProductListStateFailure(:final exception) => _StatusText(
                    text: exception.toString(),
                  ),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductListTile extends StatelessWidget {
  const _ProductListTile({this.items});

  final List<Product>? items;

  @override
  Widget build(BuildContext context) {
    final v = items;
    if (v == null || v.isEmpty) {
      return const SizedBox();
    }

    return ListView.separated(
      padding: const EdgeInsets.only(left: 30, top: 20, right: 30, bottom: 72),
      itemCount: v.length,
      itemBuilder: (context, index) {
        final item = v[index];

        return _ProductTile(value: item);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 20),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({this.value});

  final Product? value;

  @override
  Widget build(BuildContext context) {
    final v = value;
    if (v == null) {
      return const SizedBox();
    }

    final currencyFormatter = NumberFormat.currency(symbol: r'$');

    return Center(
      child: InkWell(
        onTap: () => v.id != null
            ? Navigator.of(context).push(
                MaterialPageRoute<dynamic>(
                  builder: (context) => ProductDetailPage(id: v.id!),
                ),
              )
            : null,
        child: Container(
          width: 600,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                spreadRadius: 2,
                offset: Offset(2, 2),
                color: Colors.black26,
              ),
            ],
          ),
          child: Row(
            spacing: 12,
            children: [
              CachedNetworkImage(
                imageUrl: v.thumbnail ?? '',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                placeholder: (context, url) {
                  return const Skeletonizer(
                    child: SizedBox(width: 120, height: 120),
                  );
                },
                errorWidget: (context, url, error) {
                  return const Icon(Icons.broken_image);
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.title ?? '', style: const TextStyle(fontSize: 18)),
                    Text(currencyFormatter.format(v.price)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(text),
      ),
    );
  }
}
