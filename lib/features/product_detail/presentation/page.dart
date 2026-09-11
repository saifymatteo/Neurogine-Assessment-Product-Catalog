import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import '../../../cores/ui/image.dart';
import '../../../models/models.dart';
import 'bloc.dart';
import 'state.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProductDetailBloc()..add(ProductDetailEventInitialise(id: id)),
      child: const _Content(),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailBloc, ProductDetailState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Product Detail'),
            backgroundColor: Colors.white,
            shadowColor: Colors.black26,
            elevation: 2,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Container(
              alignment: Alignment.topCenter,
              margin: const EdgeInsets.only(
                left: 20,
                top: 40,
                right: 20,
                bottom: 78,
              ),
              child: switch (state) {
                ProductDetailStateInitial() => const SizedBox(),
                ProductDetailStateInProgress() =>
                  const CircularProgressIndicator(),
                ProductDetailStateSuccess(:final product) => _ProductView(
                  product: product,
                ),
                ProductDetailStateFailure(:final id, :final exception) =>
                  Column(
                    children: [
                      Text(exception.toString()),
                      TextButton(
                        onPressed: () => context.read<ProductDetailBloc>().add(
                          ProductDetailEventInitialise(id: id),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
              },
            ),
          ),
        );
      },
    );
  }
}

class _ProductView extends StatelessWidget {
  const _ProductView({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProductHeader(product: product),
        if (product.images?.isNotEmpty ?? false) ...[
          const SizedBox(height: 24),
          _ProductImages(images: product.images!),
        ],
        if (product.reviews?.isNotEmpty ?? false) ...[
          const SizedBox(height: 24),
          _ProductReviews(reviews: product.reviews!),
        ],
      ],
    );
  }
}

class _ProductHeader extends StatelessWidget {
  const _ProductHeader({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: r'$');

    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(width: 600),
      child: Row(
        spacing: 4,
        children: [
          ProductImage.thumbnail(
            url: product.thumbnail ?? '',
            size: const Size(200, 200),
          ),
          Expanded(
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title ?? '', style: const TextStyle(fontSize: 18)),
                Text(
                  product.description ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(currencyFormatter.format(product.price)),
                IgnorePointer(
                  child: RatingBar.builder(
                    initialRating: product.rating ?? 0,
                    maxRating: 5,
                    allowHalfRating: true,
                    itemBuilder: (context, index) =>
                        const Icon(Icons.star_rounded, color: Colors.amber),
                    onRatingUpdate: (value) {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImages extends StatelessWidget {
  const _ProductImages({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Images', style: TextStyle(fontSize: 24)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final image in images)
                ProductImage(url: image, size: const Size(400, 400)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductReviews extends StatelessWidget {
  const _ProductReviews({required this.reviews});

  final List<ProductReview> reviews;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat.yMMMMd();

    return Column(
      children: [
        const Text('Reviews', style: TextStyle(fontSize: 24)),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 600),
          child: Column(
            spacing: 20,
            children: [
              for (final review in reviews) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 8,
                        children: [
                          Text(review.reviewerName ?? ''),
                          if (review.date != null)
                            Text(dateFormatter.format(review.date!)),
                        ],
                      ),
                      Text(review.comment ?? ''),
                      IgnorePointer(
                        child: RatingBar.builder(
                          initialRating: review.rating?.toDouble() ?? 0,
                          maxRating: 5,
                          allowHalfRating: true,
                          itemSize: 24,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (value) {},
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
