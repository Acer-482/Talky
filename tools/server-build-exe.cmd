@echo off

cd ..\server
echo 正在构建服务端...

call dart compile exe .\bin\server.dart -o talky_server.exe
cd ..\tools

echo 执行完毕 按任意键导出服务端到本目录
pause

move ..\server\talky_server.exe .\talky_server.exe
echo 执行完毕
pause
