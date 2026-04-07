import 'dart:async';

import 'package:talky_client/core/enums/network_connection_state.dart';
import 'package:talky_client/features/settings/models/network_config_model.dart';
import 'package:talky_shared/log/log_entry.dart';
import 'package:talky_shared/log/log_level.dart';
import 'package:talky_shared/packets/base_packet.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// 网络服务
class NetworkService {
  /// 配置模型
  final NetworkConfigModel configModel;

  /// 通信句柄
  late WebSocketChannel _webSocketChannel;

  /// 当前状态
  NetworkConnectionState _currentState = NetworkConnectionState.disconnected;

  /// 日志流控制器
  final StreamController<LogEntry> _logStreamController;

  /// 连接流控制器
  final StreamController<NetworkConnectionState> _stateStreamController;

  /// 数据流控制器
  final StreamController<BasePacket> _dataStreamController;

  /// 流错误
  void Function(Object)? onStreamError;

  /// 连接错误
  void Function(Object)? onConnectionError;

  /// 数据错误
  void Function(Object)? onDataError;

  /// 连接断开
  void Function()? onDone;

  NetworkConnectionState get connectionState => _currentState;
  Stream<LogEntry> get logStream => _logStreamController.stream;
  Stream<NetworkConnectionState> get stateStream =>
      _stateStreamController.stream;
  Stream<BasePacket> get dataStream => _dataStreamController.stream;

  NetworkService({required this.configModel})
    : _logStreamController = StreamController<LogEntry>(),
      _stateStreamController =
          StreamController<NetworkConnectionState>.broadcast(),
      _dataStreamController = StreamController<BasePacket>.broadcast();

  /// 生成uri
  Uri buildUri() {
    return Uri(host: configModel.host, port: configModel.port, scheme: 'ws');
  }

  /// 连接到服务器
  Future<bool> connect() async {
    try {
      /// 检测是否已经连接到服务器
      if (_currentState != NetworkConnectionState.disconnected) {
        throw Exception('正在连接/已经连接到服务器');
      }
      final uri = buildUri();
      _log(LogLevel.info, '正在连接到服务器($uri)...');
      _webSocketChannel = WebSocketChannel.connect(uri);
      _webSocketChannel.stream.listen(
        (data) {
          try {
            _dataStreamController.add(BasePacketMapper.fromJson(data)); // 解析数据包
          } catch (e) {
            onDataError?.call(e);
          }
        },
        onDone: () {
          _updateState(NetworkConnectionState.disconnected); // 断开连接
          onDone?.call();
          _log(
            LogLevel.info,
            '与服务器断开连接(${_webSocketChannel.closeCode}:${_webSocketChannel.closeReason}).',
          );
        },
        onError: (e) {
          _updateState(NetworkConnectionState.disconnected); // 断开连接
          _log(LogLevel.info, '流错误: $e');
          _webSocketChannel.sink.close(-1, '流错误: $e');
          onStreamError?.call(e);
        },
      ); // 添加监听器
      _updateState(NetworkConnectionState.connecting); // 连接中
      await _webSocketChannel.ready;
      _updateState(NetworkConnectionState.connected); // 连接成功
      _log(LogLevel.info, '成功连接到服务器($uri)...');
      return true;
    } catch (e) {
      _log(LogLevel.info, '连接错误: $e');
      onConnectionError?.call(e);
      return false;
    }
  }

  /// 发送数据
  void send(BasePacket data) {
    if (_currentState != NetworkConnectionState.connected) {
      throw Exception('服务未启动');
    }
    _webSocketChannel.sink.add(data.toJson());
  }

  /// 关闭连接
  void close([int? closeCode, String? closeReason]) {
    if (_currentState != NetworkConnectionState.disconnected) {
      _updateState(NetworkConnectionState.disconnected);
      _webSocketChannel.sink.close(closeCode, closeReason);
    }
  }

  /// 销毁资源
  void dispose() {
    close(); // 关闭连接
    // 释放流控制器 //
    _logStreamController.close();
    _stateStreamController.close();
    _dataStreamController.close();
  }

  // 更新状态
  void _updateState(NetworkConnectionState newState) {
    if (_currentState == newState) return;
    _currentState = newState;
    _stateStreamController.add(newState); // 添加到流
  }

  // 记录日志
  void _log(LogLevel level, String m) {
    _logStreamController.add(LogEntry(level: level, m: m));
  }
}
