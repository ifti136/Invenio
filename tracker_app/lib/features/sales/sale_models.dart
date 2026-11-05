import '../../db/app_database.dart';

enum PaymentMode { paid, partial, due }

extension PaymentModeLabel on PaymentMode {
  String get label {
    switch (this) {
      case PaymentMode.paid:
        return 'Paid in full';
      case PaymentMode.partial:
        return 'Part';
      case PaymentMode.due:
        return 'Later';
    }
  }
}

class SaleLineInput {
  final int productId;
  final int qty;
  final int unitPriceMinor;
  final int unitCostMinor;
  final bool allowAboveStock;

  const SaleLineInput({
    required this.productId,
    required this.qty,
    required this.unitPriceMinor,
    required this.unitCostMinor,
    this.allowAboveStock = false,
  });
}

class SaleReceiptLine {
  final String name;
  final int qty;
  final int unitPriceMinor;

  const SaleReceiptLine({
    required this.name,
    required this.qty,
    required this.unitPriceMinor,
  });

  int get totalMinor => qty * unitPriceMinor;
}

class SaleReceipt {
  final int saleId;
  final String? customerName;
  final String status;
  final List<SaleReceiptLine> lines;
  final int totalMinor;
  final int paidMinor;
  final int dueMinor;

  const SaleReceipt({
    required this.saleId,
    this.customerName,
    required this.status,
    required this.lines,
    required this.totalMinor,
    required this.paidMinor,
    required this.dueMinor,
  });
}

class SaleSummary {
  final int id;
  final int createdAt;
  final int totalMinor;
  final String status;
  final int channelId;
  final String? customerName;
  final String channelName;
  final int paidMinor;
  final int dueMinor;
  final int itemCount;
  final String itemsLabel;
  final int profitMinor;

  const SaleSummary({
    required this.id,
    required this.createdAt,
    required this.totalMinor,
    required this.status,
    required this.channelId,
    required this.customerName,
    required this.channelName,
    required this.paidMinor,
    required this.dueMinor,
    required this.itemCount,
    required this.itemsLabel,
    required this.profitMinor,
  });
}

class SaleLine {
  final int id;
  final int productId;
  final String productName;
  final int qty;
  final int unitPriceMinor;
  final int unitCostMinor;

  const SaleLine({
    required this.id,
    required this.productId,
    required this.productName,
    required this.qty,
    required this.unitPriceMinor,
    required this.unitCostMinor,
  });

  int get lineTotalMinor => qty * unitPriceMinor;

  int get lineProfitMinor => qty * (unitPriceMinor - unitCostMinor);
}

class PaymentInfo {
  final int id;
  final int accountId;
  final String accountName;
  final int amountMinor;
  final int paidAt;
  final String? note;

  const PaymentInfo({
    required this.id,
    required this.accountId,
    required this.accountName,
    required this.amountMinor,
    required this.paidAt,
    this.note,
  });
}

class SaleDetail {
  final Sale sale;
  final String? customerName;
  final String? customerPhone;
  final String channelName;
  final List<SaleLine> lines;
  final List<PaymentInfo> payments;
  final int paidMinor;
  final int dueMinor;
  final int profitMinor;

  const SaleDetail({
    required this.sale,
    required this.customerName,
    required this.customerPhone,
    required this.channelName,
    required this.lines,
    required this.payments,
    required this.paidMinor,
    required this.dueMinor,
    required this.profitMinor,
  });
}

class DeletedSale {
  final Sale sale;
  final List<SaleLine> lines;
  final List<PaymentInfo> payments;

  const DeletedSale({
    required this.sale,
    required this.lines,
    required this.payments,
  });
}

class SalesDefaults {
  final int? channelId;
  final int? accountId;

  const SalesDefaults({this.channelId, this.accountId});
}

class RecordPaymentResult {
  final int paidMinor;
  final int dueMinor;
  final String status;

  const RecordPaymentResult({
    required this.paidMinor,
    required this.dueMinor,
    required this.status,
  });
}
