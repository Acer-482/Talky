import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/account/account_profile.dart';
import 'package:talky_shared/packets/status_response.dart';

part 'get_account_profile_response.mapper.dart';

/// 获取账户资料
@MappableClass()
class GetAccountProfileResponse extends StatusResponse
    with GetAccountProfileResponseMappable {
  GetAccountProfileResponse({
    this.profile,
    required super.status,
    super.message,
    super.stamp,
  });

  /// 账户资料
  final AccountProfile? profile;
}
