import 'package:dart_mappable/dart_mappable.dart';
part 'tip.mapper.dart';

/// 提示
@MappableClass()
class Tip with TipMappable {
  final int id; // 提示id
  final String content; // 内容

  const Tip({required this.id, required this.content});
}
