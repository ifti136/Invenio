import 'package:drift/drift.dart';

import '../../db/app_database.dart';

class CustomerRepository {
  final AppDatabase _db;

  CustomerRepository(this._db);

  Stream<List<Customer>> watchCustomers() {
    final query = _db.select(_db.customers)
      ..orderBy([(customer) => OrderingTerm(expression: customer.name)]);
    return query.watch();
  }

  Future<List<Customer>> getCustomers() {
    final query = _db.select(_db.customers)
      ..orderBy([(customer) => OrderingTerm(expression: customer.name)]);
    return query.get();
  }

  Future<int> addCustomer({required String name, String? phone}) {
    return _db.into(_db.customers).insert(
          CustomersCompanion.insert(
            name: name,
            phone: Value(phone),
          ),
        );
  }
}
