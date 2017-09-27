start cmd /c %~dp0\Reception\start.bat
start cmd /c %~dp0\Dispatcher\start.bat
start cmd /c %~dp0\ActiveQueue\start.bat
start cmd /c %~dp0\ConsumerMock\start.bat

pause

start cmd /c %~dp0\multi-thread-requests.bat


