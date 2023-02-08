echo deployment surrealdb store 
sudo docker pull surrealdb/surrealdb:latest
sudo docker container create --name mysearch-db -p 7698:8000 -v /mysearch-db:/home surrealdb/surrealdb:latest\
  start  -u yang -p iamyang "file:///home/data"
sudo docker start mysearch-db

mkdir mysearch
cd mysearch

echo "Or download meilisearch from https://github.com/meilisearch/meilisearch/releases/latest and\
 save filename meilisearch as a file in the workdir."  
curl -LO https://github.com/meilisearch/meilisearch/releases/download/v1.0.0/
sudo mv meilisearch-linux-amd64 /usr/bin/meilisearch
chmod a+x /usr/bin/meilisearch

port=7699
echo building key file...
key=$(cat  master-key.txt)
if [ -n "$key" ]; then
    echo master-key using file is $key
else
    key=$(openssl rand -base64 24)
    echo create new master-key is $key
fi
echo $key >master-key.txt
echo building meilisearch service...

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
