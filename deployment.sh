#deployment surrealdb store 
docker pull surrealdb/surrealdb:latest
docker container create --name surrealdb -p 7698:8000 -v /surrealhome:/home surrealdb/surrealdb:latest\
  start  -u yang -p iamyang "file:///home/data"
echo "Download meilisearch from https://github.com/meilisearch/meilisearch/releases/latest and\
 save filename meilisearch as a file in the workdir."  

port=7699
key=$(cat  master-key.txt)

if [ -n "$key" ]; then
    echo master-key using file is $key
else
    key=$(openssl rand -base64 24)
    echo create new master-key is $key
fi
echo $key >master-key.txt

chmod a+x meilisearch                                   

sudo mv meilisearch /usr/bin
cat << EOF > $(pwd)/meilisearch.service
[Unit]
Description=MeiliSearch
After=systemd-user-sessions.service

[Service]
Type=simple
ExecStart=/usr/bin/meilisearch --http-addr 127.0.0.1:$port --env production --master-key $key
[Install]
WantedBy=default.target
EOF

sudo mv meilisearch.service /etc/systemd/system/
cat /etc/systemd/system/meilisearch.service

sudo systemctl enable meilisearch
sudo systemctl start meilisearch
sudo systemctl status meilisearch
