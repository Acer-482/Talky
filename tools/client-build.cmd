@echo off

cd ..\client
echo 正在构建Windows客户端...
call flutter build windows --release
cd ..\tools

cd ..\client
echo 正在构建Android客户端...
call flutter build apk --release
cd ..\tools

echo 正在签名...
call apksigner sign --ks release-key.keystore --ks-key-alias key ..\client\build\app\outputs\flutter-apk\app-release.apk

echo 验证签名...
call apksigner verify --verbose ..\client\build\app\outputs\flutter-apk\app-release.apk

echo 执行完毕 按任意键导出签名安装包到本目录
pause

xcopy ..\client\build\windows\x64\runner\Release .\client\windows\ /E /I
xcopy ..\client\build\app\outputs\flutter-apk .\client\apk\ /E /I
echo 执行完毕
pause
