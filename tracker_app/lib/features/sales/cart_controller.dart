import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import 'sale_models.dart';

class CartLine {
  final int productId;
  final String name;
  final int listPriceMinor;
  final int unitCostMinor;
  final int stock;
  final int lowStockAt;
  final int qty;
  final int unitPriceMinor;
  final bool allowAboveStock;

  const CartLine({
    required this.productId,
    required this.name,
    required this.listPriceMinor,
    required this.unitCostMinor,
    required this.stock,
    required this.lowStockAt,
    required this.qty,
    required this.unitPriceMinor,
    this.allowAboveStock = false,
  });

  int get lineTotalMinor => qty * unitPriceMinor;

  int get lineProfitMinor => qty * (unitPriceMinor - unitCostMinor);

  bool get isDiscount => unitPriceMinor < listPriceMinor;

  bool get isBelowCost => unitPriceMinor < unitCostMinor;

  bool get isAboveStock => qty > stock;

  CartLine copyWith({
    int? qty,
    int? unitPriceMinor,
    bool? allowAboveStock,
  }) {
    return CartLine(
      productId: productId,
      name: name,
      listPriceMinor: listPriceMinor,
      unitCostMinor: unitCostMinor,
      stock: stock,
      lowStockAt: lowStockAt,
      qty: qty ?? this.qty,
      unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
      allowAboveStock: allowAboveStock ?? this.allowAboveStock,
    );
  }
}

class SaleEditSeed {
  final int? customerId;
  final int channelId;
  final PaymentMode payment;
  final int paidMinor;
  final int? accountId;

  const SaleEditSeed({
    this.customerId,
    required this.channelId,
    required this.payment,
    required this.paidMinor,
    this.accountId,
  });
}

class CartState {
  final List<CartLine> lines;
  final int? editingSaleId;
  final SaleEditSeed? editSeed;

  const CartState({
    this.lines = const [],
    this.editingSaleId,
    this.editSeed,
  });

  bool get isEmpty => lines.isEmpty;

  int get itemCount => lines.fold(0, (sum, line) => sum + line.qty);

  int get totalMinor => lines.fold(0, (sum, line) => sum + line.lineTotalMinor);

  int get costMinor =>
      lines.fold(0, (sum, line) => sum + line.qty * line.unitCostMinor);

  int get profitMinor => totalMinor - costMinor;

  bool get hasBelowCost => lines.any((line) => line.isBelowCost);

  bool get hasUnapprovedOverStock =>
      lines.any((line) => line.isAboveStock && !line.allowAboveStock);
}

class CartController extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  void addProduct(Product product, {int qty = 1, int? unitPriceMinor}) {
    if (qty <= 0) return;
    final price = unitPriceMinor ?? product.priceMinor;
    final index =
        state.lines.indexWhere((line) => line.productId == product.id);
    if (index >= 0) {
      final existing = state.lines[index];
      _replace(
        index,
        existing.copyWith(qty: existing.qty + qty),
      );
      return;
    }
    state = CartState(
      lines: [
        ...state.lines,
        CartLine(
          productId: product.id,
          name: product.name,
          listPriceMinor: product.priceMinor,
          unitCostMinor: product.costMinor,
          stock: product.stock,
          lowStockAt: product.lowStockAt,
          qty: qty,
          unitPriceMinor: price,
        ),
      ],
      editingSaleId: state.editingSaleId,
      editSeed: state.editSeed,
    );
  }

  void addLine(CartLine line) {
    final index =
        state.lines.indexWhere((item) => item.productId == line.productId);
    if (index >= 0) {
      final existing = state.lines[index];
      _replace(index, existing.copyWith(qty: existing.qty + line.qty));
      return;
    }
    state = CartState(
      lines: [...state.lines, line],
      editingSaleId: state.editingSaleId,
      editSeed: state.editSeed,
    );
  }

  void removeProduct(int productId) {
    state = CartState(
      lines: state.lines.where((line) => line.productId != productId).toList(),
      editingSaleId: state.editingSaleId,
      editSeed: state.editSeed,
    );
  }

  void setQty(int productId, int qty) {
    if (qty < 1) return;
    final index = state.lines.indexWhere((line) => line.productId == productId);
    if (index < 0) return;
    _replace(index, state.lines[index].copyWith(qty: qty));
  }

  void setUnitPrice(int productId, int unitPriceMinor) {
    if (unitPriceMinor < 0) return;
    final index = state.lines.indexWhere((line) => line.productId == productId);
    if (index < 0) return;
    _replace(
      index,
      state.lines[index].copyWith(unitPriceMinor: unitPriceMinor),
    );
  }

  void setAllowAboveStock(int productId, bool allow) {
    final index = state.lines.indexWhere((line) => line.productId == productId);
    if (index < 0) return;
    _replace(
      index,
      state.lines[index].copyWith(allowAboveStock: allow),
    );
  }

  void loadForEdit(
    List<CartLine> lines, {
    required int saleId,
    SaleEditSeed? seed,
  }) {
    state = CartState(lines: lines, editingSaleId: saleId, editSeed: seed);
  }

  void reset() {
    state = const CartState();
  }

  void _replace(int index, CartLine line) {
    final lines = [...state.lines];
    lines[index] = line;
    state = CartState(
      lines: lines,
      editingSaleId: state.editingSaleId,
      editSeed: state.editSeed,
    );
  }
}

final cartProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);
