# quick-MongoDB


## Getting started

- Clone the repo:

```shell
git clone https://github.com/Alyetama/quick-MongoDB.git
cd quick-MongoDB
```

- Edit `.env` file:

```shell
mv .env.example .env
nano .env  # or edit it with any other text editor
```

- Run:

```shell
docker-compose up -d
```

## Periodic backups

- Backup once:

```shell
bash backup.sh --once
```

- Backup every *n* period of time (default: 1d)

```shell
# s for seconds (default)
# m for minutes
# h for hours
# d for days

bash backup.sh every 1h
```

- Setup a systemctl service to run in the background

```shell
echo "Description=quick-MongoDB
Requires=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$PWD
ExecStart=/bin/bash $PWD/backup.sh
Restart=always

[Install]
WantedBy=multi-user.target" > mongodb-backup.service

mv mongodb-backup.service /etc/systemd/system/mongodb-backup.service

systemctl daemon-reload
systemctl start mongodb-backup.service
# To load automatically on reboot:
systemctl enable mongodb-backup.service
```
