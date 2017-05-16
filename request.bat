REM this is a request for the server

REM curl -X POST -H "Content-Type: application/json" -d "{\"key\":\"val\"}" http://localhost/venditori/send

REM curl -X POST -H "Content-Type: application/json" -d "{\"html\":\"html version of the mail\", \"text\":\"text version of the mail\"}" http://localhost/venditori/send

curl -X POST -H "Content-Type: application/json" -d token="abcdefgh" -d data="{\"html\":\"html version of the mail\", \"text\":\"text version of the mail\"}" http://localhost/venditori/send

