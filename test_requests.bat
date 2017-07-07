echo off
REM ECHO "Simulate requests from the Reception server to the Dispatcher server" 
REM FOR /L %%A IN (1,1,1) DO curl -X POST -H "Content-Type: multipart/form-data;charset=ASCII" -F data="{\"html\":\"html %%A\", \"text\":\"text %%A\", \"token\":\"super secret\"};type=application/json" -F file=@dumb.txt http://localhost/venditori/send

ECHO "Simulate requests from the Reception server to the Dispatcher server" 
FOR /L %%A IN (1,1,1) DO curl -X POST -H "Content-Type: multipart/form-data;charset=ASCII" -F data="{\"html\":\"html %%A\", \"text\":\"text %%A\", \"token\":\"super secret\", \"email\":\"a.shcherbakov@ritoll.it\"};type=application/json" -F file=@dumb.txt http://localhost/onm/register