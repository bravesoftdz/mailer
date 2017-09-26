start cmd /c %~dp0\startOneConsumer.bat %~dp0\config_folder\Consumer2-phone.conf
start cmd /c %~dp0\startOneConsumer.bat %~dp0\config_folder\Consumer3-email.conf
start cmd /c %~dp0\startOneConsumer.bat %~dp0\config_folder\Consumer4-db.conf

%~dp0\startOneConsumer.bat %~dp0\config_folder\Consumer1-email.conf

pause