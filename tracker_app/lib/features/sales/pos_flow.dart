import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../products/product_provider.dart';
import 'sale_repository.dart';
import 'widgets/product_picker_sheet.dart';
import 'widgets/quick_sell_sheet.dart';
import 'widgets/receipt_sheet.dart';

Future<void> startPosFlow(BuildContext context, WidgetRef ref) async {
  final products = ref.read(productListProvider).valueOrNull ?? [];
  final available = products.where((p) => p.stock > 0).toList();

  if (available.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          products.isEmpty
              ? 'Add a product before selling.'
              : 'No products in stock.',
        ),
      ),
    );
    return;
  }

  final id = await showProductPicker(context, products: available);
  if (id == null || !context.mounted) return;

  final product = available.firstWhere((p) => p.id == id);
  final lastSale =
      await ref.read(saleRepositoryProvider).lastSellingPriceFor(product.id);
  if (!context.mounted) return;

  final sale = await showQuickSellSheet(
    context,
    product: product,
    lastSellingPrice: lastSale?.sellingPrice,
  );
  if (sale != null && context.mounted) {
    await showReceiptSheet(
      context,
      sale: sale,
      productName: product.name,
    );
  }
}
