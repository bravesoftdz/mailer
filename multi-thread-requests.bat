echo off
SET numofthreads=%1
IF "%numofthreads%"=="" (
 SET numofthreads=1
)
SET /A extrathreads=%numofthreads%-1
ECHO Simulate requests from %numofthreads%-many threads to the Reception server

FOR /L %%A IN (1, 1, %extrathreads%) DO (
 start %~dp0\same-thread-requests.bat %2
)

%~dp0\same-thread-requests.bat %2
echo(
pause