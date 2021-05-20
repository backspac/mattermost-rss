# mattermost-rss

RSS feed for Mattermost

## Installation

These instructions assume a `rss` user exists and its home folder is under `/srv`

```sh
cd $HOME
git clone https://github.com/backspac/mattermost-rss
cd mattermost-rss
bundle install --deployment
```

### systemd

```
# /etc/systemd/system/mattermost-rss.service

[Unit]
Description=RSS feed for Mattermost
After=syslog.target network.target mattermost.service

[Service]
User=rss
Group=rss

PrivateTmp=yes
WorkingDirectory=/srv/rss/mattermost-rss/

ExecStart=/bin/bash -lc 'bundle exec ruby mattermost-rss.rb'
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
```

```sh
systemctl enable mattermost-rss.service
systemctl start mattermost-rss.service
```

## Development

Probably the easiest way to get started and see if it works is to use a [Mattermost Helm Chart](https://github.com/mattermost/mattermost-helm) on [minikube](https://github.com/kubernetes/minikube).

Follow the TL;DR and run the given `kubectl port-forward` command after installing the chart.

You can then create a webhook, copy the link in your `config.yml` and run `bundle exec ruby mattermost-rss.rb`.
