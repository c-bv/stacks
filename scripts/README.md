crontab -e

0 2 * * * /opt/stacks/scripts/docker_vol_backup.sh >> /opt/stacks/logs/docker_vol_backup.log 2>&1