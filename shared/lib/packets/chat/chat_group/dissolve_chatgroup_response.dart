import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/packets/status_response.dart';

part 'dissolve_chatgroup_response.mapper.dart';

/// 解散树洞回调
@MappableClass()
class DissolveChatgroupResponse extends StatusResponse
    with DissolveChatgroupResponseMappable {
  DissolveChatgroupResponse({
    required super.status,
    super.message,
    super.stamp,
  });
}
