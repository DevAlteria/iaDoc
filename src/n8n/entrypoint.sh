#!/bin/sh

pwd

if [ -f /home/node/.n8n/.prosioned ]; then
  echo "Already provisioned"
  n8n start
  exit 0
fi

echo IMPORTING CREDENTIALS
n8n import:credentials --separate --input=/credentials

echo IMPORTING WORKFLOWS
n8n import:workflow --separate --input=/workflows

echo CREATING DEFAULT ACCOUNT
echo -n Waiting for n8n
n8n start > /tmp/startupn8n 2>&1 &
MA_VAR=$(cat /tmp/startupn8n | grep "Editor is now accessible via:" | wc -l)
while [ "$MA_VAR" != "1" ];
do 
  sleep 1
  MA_VAR=$(cat /tmp/startupn8n | grep "Editor is now accessible via:" | wc -l)
  echo -n .
done
echo 
curl -X POST http://iadoc.alteria.vpn.alonsom.com/n8n/rest/owner/setup -H "Content-Type: application/json" -d '{"email":"dev@alteriaautomation.com","firstName":"alteria","lastName":"dev","password":"AlteriaKillM3!"}' >/dev/null 2>&1

kill -9 $(ps -a | grep "n8n start" | awk '{ print $1 }' | head -n1)

echo PROSIONED
touch /home/node/.n8n/.prosioned

echo STARTING
n8n start
