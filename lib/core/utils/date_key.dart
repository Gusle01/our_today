import 'package:intl/intl.dart';

/// 하루의 식별자(dateKey) 유틸. 형식: `yyyy-MM-dd` (기기 로컬 기준).
final DateFormat _fmt = DateFormat('yyyy-MM-dd');

String todayKey() => _fmt.format(DateTime.now());

String dateKeyOf(DateTime date) => _fmt.format(date);

DateTime parseDateKey(String key) => DateTime.parse(key);

/// 결정적 질문 선택 등에 쓰는 epoch day(1970-01-01 기준 일수).
int epochDayOf(String dateKey) =>
    DateTime.parse(dateKey).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
