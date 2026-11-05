enum DatePeriod { thisMonth, lastMonth, thisYear, allTime }

extension DatePeriodLabel on DatePeriod {
  String get label {
    switch (this) {
      case DatePeriod.thisMonth:
        return 'This month';
      case DatePeriod.lastMonth:
        return 'Last month';
      case DatePeriod.thisYear:
        return 'This year';
      case DatePeriod.allTime:
        return 'All time';
    }
  }

  bool contains(DateTime date, {DateTime? now}) {
    final current = now ?? DateTime.now();
    switch (this) {
      case DatePeriod.thisMonth:
        final start = DateTime(current.year, current.month);
        final end = DateTime(current.year, current.month + 1);
        return !date.isBefore(start) && date.isBefore(end);
      case DatePeriod.lastMonth:
        final start = DateTime(current.year, current.month - 1);
        final end = DateTime(current.year, current.month);
        return !date.isBefore(start) && date.isBefore(end);
      case DatePeriod.thisYear:
        final start = DateTime(current.year);
        final end = DateTime(current.year + 1);
        return !date.isBefore(start) && date.isBefore(end);
      case DatePeriod.allTime:
        return true;
    }
  }

  ({DateTime start, DateTime end}) range({DateTime? now}) {
    final current = now ?? DateTime.now();
    switch (this) {
      case DatePeriod.thisMonth:
        return (
          start: DateTime(current.year, current.month),
          end: DateTime(current.year, current.month + 1),
        );
      case DatePeriod.lastMonth:
        return (
          start: DateTime(current.year, current.month - 1),
          end: DateTime(current.year, current.month),
        );
      case DatePeriod.thisYear:
        return (
          start: DateTime(current.year),
          end: DateTime(current.year + 1),
        );
      case DatePeriod.allTime:
        return (
          start: DateTime.fromMillisecondsSinceEpoch(0),
          end: DateTime(9999),
        );
    }
  }
}
