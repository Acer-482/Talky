@MappableLib(generateInitializerForScope: InitializerScope.package)
library;

import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/mappers.init.dart';

/// 初始化所有数据包
void initializeSharedMappers() {
  initializeMappers();
}
