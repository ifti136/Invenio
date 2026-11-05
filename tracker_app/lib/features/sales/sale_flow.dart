import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../inventory/inventory_providers.dart';
import 'cart_controller.dart';
import 'sale_models.dart';
import 'sale_providers.dart';

void openNewSale(BuildContext context, WidgetRef ref) {
  ref.read(cartProvider.notifier).reset();
  context.push('/sales/new');
}

Future<void> startEditSale(
  BuildContext context,
  WidgetRef ref,
  int saleId,
) async {
  final repository = ref.read(saleRepositoryProvider);
  final detail = await repository.getSaleDetail(saleId);
  if (detail == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This sale no longer exists.')),
      );
    }
    return;
  }

  final products = ref.read(productRepositoryProvider);
  final lines = <CartLine>[];
  for (final line in detail.lines) {
    final product = await products.getProduct(line.productId);
    lines.add(
      CartLine(
        productId: line.productId,
        name: line.productName,
        listPriceMinor: product?.priceMinor ?? line.unitPriceMinor,
        unitCostMinor: line.unitCostMinor,
        stock: (product?.stock ?? 0) + line.qty,
        lowStockAt: product?.lowStockAt ?? 0,
        qty: line.qty,
        unitPriceMinor: line.unitPriceMinor,
      ),
    );
  }

  final paid = detail.paidMinor;
  final payment = paid <= 0
      ? PaymentMode.due
      : (paid >= detail.sale.totalMinor
          ? PaymentMode.paid
          : PaymentMode.partial);
  final accountId =
      detail.payments.isEmpty ? null : detail.payments.last.accountId;

  ref.read(cartProvider.notifier).loadForEdit(
        lines,
        saleId: saleId,
        seed: SaleEditSeed(
          customerId: detail.sale.customerId,
          channelId: detail.sale.channelId,
          payment: payment,
          paidMinor: paid,
          accountId: accountId,
        ),
      );
  if (context.mounted) {
    context.push('/sales/new');
  }
}
