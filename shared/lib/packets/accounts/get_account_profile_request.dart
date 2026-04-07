import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/packets/request_packet.dart';

part 'get_account_profile_request.mapper.dart';

/// 获取账户资料
@MappableClass()
class GetAccountProfileRequest extends RequestPacket
    with GetAccountProfileRequestMappable {
  GetAccountProfileRequest({required this.id, super.stamp});

  final String id; // 账户id
}
