import 'package:dart_mappable/dart_mappable.dart';

part 'hobby_tag.mapper.dart';

/// 爱好标签
@MappableClass()
class HobbyTag with HobbyTagMappable {
  /// 爱好
  final String hobby;

  const HobbyTag({required this.hobby});
}
