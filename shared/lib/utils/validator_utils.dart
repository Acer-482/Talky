/// 验证器工具类
///
/// 提供表单常用的验证器
class ValidatorUtils {
  /// 地址正则
  static final RegExp _hostRegex = RegExp(
    r'^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$' // 域名验证
    r'|^(\d{1,3}\.){3}\d{1,3}$', // IPv4点分验证
  );

  /// 端口正则
  static final RegExp _portRegex = RegExp(
    r'^([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$',
  );

  /// 用户名
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入账户名称';
    }
    if (value.length < 4) {
      return '账户名称不小于四个字符';
    }
    return null;
  }

  /// 密码
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码不小于六个字符';
    }
    return null;
  }

  /// 年龄
  ///
  /// 允许为空
  static String? age(String? value) {
    if (value != null && value.isNotEmpty) {
      final ageInt = int.tryParse(value);
      if (ageInt == null) {
        return '请输入有效的数字年龄';
      }
      if (ageInt < 0 || ageInt > 150) {
        return '年龄必须在 0 到 150 之间';
      }
    }
    return null;
  }

  /// 手机号
  ///
  /// 允许为空
  static String? phoneNumber(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
        return '请输入正确的手机号';
      }
    }
    return null;
  }

  /// 邮箱
  ///
  /// 允许为空
  static String? eMail(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!RegExp(
        r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$',
      ).hasMatch(value)) {
        return '请输入正确的邮箱';
      }
    }
    return null;
  }

  /// 树洞名
  static String? chatGroupName(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入树洞名称';
    }
    if (value.length < 3) {
      return '树洞名称不小于三个字符';
    }
    return null;
  }

  /// 服务器主机
  static String? serverHost(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入服务器主机';
    }
    if (!_hostRegex.hasMatch(value)) {
      return '主机地址无效';
    }
    return null;
  }

  /// 服务器地址
  static String? serverPort(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入服务器端口';
    }
    if (!_portRegex.hasMatch(value)) {
      return '端口无效';
    }
    return null;
  }
}
