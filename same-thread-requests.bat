echo off

SET requests=%1
IF "%requests%"=="" (
 SET requests=5
)
ECHO Make %requests% requests to the Dispatcher server made one after another
FOR /L %%A IN (1, 1, %requests%) DO (
 echo %%A 
 curl -X POST -H "Content-Type: multipart/form-data;charset=ASCII" -F data="{\"email\":\"a.shcherbakov@ritoll.it\", \"name\":\"Mario Rossi %%A\", \"phone\":\"%date% %time%\", \"country\":\"Italia\",\"token\":\"super secret\"};type=application/json" -F file1=@..\java.png -F file2=@dumb.txt http://localhost/onm/register
 echo(
)
echo(
pause