import 'package:talky_shared/packets/base_packet.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// 网络客户端
class WebClient {
  WebClient({required this.id, required WebSocketChannel webSocketChannel})
    : _webSocketChannel = webSocketChannel;
  final String id; // 标识符
  final WebSocketChannel _webSocketChannel; // 通信句柄
  String? accountId; // 登录到的账户ID

  /// 数据流
  Stream<dynamic> get dataStream => _webSocketChannel.stream;

  /// 检测是否已经登录
  bool get isLogged => accountId != null;

  /// 检测客户端连接关闭
  ///
  /// 当连接已经关闭时：true，并将客户端从列表中移除
  bool get isSocketClosed {
    return _webSocketChannel.closeCode != null;
  }

  /// 发送消息
  ///
  /// 当发送成功时，返回`true`
  bool send(BasePacket packet) {
    if (isSocketClosed) return false;
    _webSocketChannel.sink.add(packet.toJson());
    return true;
  }

  /// 登录到账户
  ///
  /// 当已经登录时返回false
  bool login(String id) {
    if (accountId != null) return false;
    accountId = id;
    return true;
  }

  /// 登出账户
  ///
  /// 当未登录时返回false
  bool logout() {
    if (accountId == null) return false;
    accountId = null;
    return true;
  }

  /// 关闭客户端
  ///
  /// 当发送成功时，返回`true`
  void close([int? closeCode, String? closeReason]) {
    if (isSocketClosed) return;
    _webSocketChannel.sink.close(closeCode, closeReason);
  }
}
