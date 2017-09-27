echo off

ECHO "Simulate multiple thread requests to the Reception server" 
FOR /L %%A IN (1,1,5) DO (
 start %~dp0\same-thread-requests.bat %%A
)
echo(
pause