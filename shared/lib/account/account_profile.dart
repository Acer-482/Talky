import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/account/account.dart';
import 'package:talky_shared/hobby_tag/hobby_tag.dart';

part 'account_profile.mapper.dart';

/// 账户资料
@MappableClass()
class AccountProfile with AccountProfileMappable {
  final String id;
  final String username;
  final int? age;
  final List<HobbyTag>? hobbies;
  final String? description;
  final String? phoneNumber;
  final String? email;

  const AccountProfile({
    required this.id,
    required this.username,
    this.age,
    this.hobbies,
    this.description,
    this.phoneNumber,
    this.email,
  });

  factory AccountProfile.fromAccount(Account account) {
    return AccountProfile(
      id: account.id,
      username: account.username,
      age: account.age,
      hobbies: account.hobbyTags,
      description: account.signature,
      phoneNumber: account.phoneNumber,
      email: account.email,
    );
  }
}
