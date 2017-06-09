REM this is a request for the server

REM curl -X POST -H "Content-Type: application/json" -d "{\"key\":\"val\"}" http://localhost/venditori/send

REM curl -X POST -H "Content-Type: application/json" -d "{\"html\":\"html version of the mail\", \"text\":\"text version of the mail\"}" http://localhost/venditori/send

REM curl -X POST -H "Content-Type: application/json" -d token="abcdefgh" -d data="{\"html\":\"html version of the mail\", \"text\":\"text version of the mail\"}" http://localhost/venditori/send




curl -X POST -H "Content-Type: multipart/form-data;charset=ASCII" -F data="{\"html\":\"html 1\", \"text\":\"text 1\", \"token\":\"super secret\"};type=application/json" -F file=@index.html http://localhost/venditori/send
curl -X POST -H "Content-Type: multipart/form-data;charset=ASCII" -F data="{\"html\":\"html 2\", \"text\":\"text 2\", \"token\":\"super secret\"};type=application/json" -F file=@index.html http://localhost/venditori/send
curl -X POST -H "Content-Type: multipart/form-data;charset=ASCII" -F data="{\"html\":\"html 3\", \"text\":\"text 3\", \"token\":\"super secret\"};type=application/json" -F file=@index.html http://localhost/venditori/send
curl -X POST -H "Content-Type: multipart/form-data;charset=ASCII" -F data="{\"html\":\"html 4\", \"text\":\"text 4\", \"token\":\"super secret\"};type=application/json" -F file=@index.html http://localhost/venditori/send
curl -X POST -H "Content-Type: multipart/form-data;charset=ASCII" -F data="{\"html\":\"html 5\", \"text\":\"text 5\", \"token\":\"super secret\"};type=application/json" -F file=@index.html http://localhost/venditori/send
curl -X POST -H "Content-Type: multipart/form-data;charset=ASCII" -F data="{\"html\":\"html 6\", \"text\":\"text 6\", \"token\":\"super secret\"};type=application/json" -F file=@index.html http://localhost/venditori/send
curl -X POST -H "Content-Type: multipart/form-data;charset=ASCII" -F data="{\"html\":\"html 7\", \"text\":\"text 7\", \"token\":\"super secret\"};type=application/json" -F file=@index.html http://localhost/venditori/send
curl -X POST -H "Content-Type: multipart/form-data;charset=ASCII" -F data="{\"html\":\"html 8\", \"text\":\"text 8\", \"token\":\"super secret\"};type=application/json" -F file=@index.html http://localhost/venditori/send
curl -X POST -H "Content-Type: multipart/form-data;charset=ASCII" -F data="{\"html\":\"html 9\", \"text\":\"text 9\", \"token\":\"super secret\"};type=application/json" -F file=@index.html http://localhost/venditori/send
curl -X POST -H "Content-Type: multipart/form-data;charset=ASCII" -F data="{\"html\":\"html 10\", \"text\":\"text 10\", \"token\":\"super secret\"};type=application/json" -F file=@index.html http://localhost/venditori/send