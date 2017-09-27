echo off

ECHO "Simulate requests from the Reception server to the Dispatcher server made one after another" 
FOR /L %%A IN (1,1,5) DO (
 echo %%A 
 curl -X POST -H "Content-Type: multipart/form-data;charset=ASCII" -F data="{\"email\":\"a.shcherbakov@ritoll.it\", \"name\":\"Mario Rossi %%A\", \"phone\":\"%date% %time%\", \"country\":\"Italia\",\"token\":\"super secret\"};type=application/json" -F file1=@dumb.txt -F file2=@dumb.txt http://localhost/onm/register
 echo(
)
echo(
pause