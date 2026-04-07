import 'package:dart_mappable/dart_mappable.dart';

part 'quote.mapper.dart';

/// 语录
@MappableClass()
class Quote with QuoteMappable {
  final String content;
  const Quote({required this.content});
}
