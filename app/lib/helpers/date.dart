import 'package:intl/intl.dart';

String formatTimestamp(String timestamp) {
  DateTime parsedDate = DateTime.parse(timestamp);
  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
  return formatter.format(parsedDate);
}
