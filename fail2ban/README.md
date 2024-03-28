# Fail2Ban Docker Configuration

## Installation and Configuration

### Running Fail2Ban Container

Run the Fail2Ban container with volume mapping for the logs you wish to monitor:

```yml
version: '3.9'

services:
  fail2ban:
    image: crazymax/fail2ban:latest
    container_name: fail2ban
    restart: unless-stopped
    network_mode: host
    cap_add:
      - NET_ADMIN
      - NET_RAW
    env_file: .env
    volumes:
      - ./data:/data
      - /var/log/traefik:/var/log/traefik:ro
      - /var/log/vaultwarden:/var/log/vaultwarden:ro
      - /var/log/mail:/var/log/mail:ro

```

Adjust the volume mappings to match the locations of your log files on the host. This setup is prepared to monitor logs from Traefik, Vaultwarden, and a mail service. Ensure these directories contain the logs you intend to monitor with Fail2Ban.

### Configure Fail2Ban

Tailor the Fail2Ban configuration according to your needs. You may need to create or modify jail configurations, action files, and filter definitions to match the logs and services you're protecting.

Examples can be found in the `data` directory of this repository.

#### Use iptables tooling without nftables backend

The [crazymax/fail2ban](https://github.com/crazy-max/docker-fail2ban) image uses iptables for compatibility. However, distributions like Debian 10 (Buster), Ubuntu 19.04, Fedora 29, and their newer releases use the nftables backend by default for iptables tooling. This mismatch can cause the error `iptables: No chain/target/match by that name.`

To check if your system uses the nftables backend for iptables, run the following command on your host:

```shell
iptables --version
```

If the output contains `nftables`, you need to switch to 'legacy' mode.

If your system uses the nftables backend for iptables, switch to 'legacy' mode:

On **Ubuntu** or **Debian**:

```shell
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
sudo update-alternatives --set arptables /usr/sbin/arptables-legacy
sudo update-alternatives --set ebtables /usr/sbin/ebtables-legacy
```
