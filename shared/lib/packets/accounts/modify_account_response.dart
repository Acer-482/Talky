import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/account/account.dart';
import 'package:talky_shared/packets/status_response.dart';

part 'modify_account_response.mapper.dart';

/// 修改账户请求
@MappableClass()
class ModifyAccountResponse extends StatusResponse
    with ModifyAccountResponseMappable {
  /// 更新后的账户
  final Account? account;
  ModifyAccountResponse({
    required this.account,
    required super.status,
    super.message,
    super.stamp,
  });
}
