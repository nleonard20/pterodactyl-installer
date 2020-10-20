# :bird: pterodactyl-installer

Unofficial scripts for installing Pterodactyl on both Panel & Daemon.

Read more about [Pterodactyl here](https://pterodactyl.io/).

# Supported installations

List of supported installation setups for panel and daemon (installations supported by this installation script).

### Supported panel operating systems and webservers

| Operating System  | Version | nginx support      | Apache support       |
| ----------------- | ------- | ------------------ | --------------       |
| Ubuntu            | 18.04   | :white_check_mark: | :white_check_mark:   |
|                   | 20.04   | :white_check_mark: | :white_check_mark:   |
| Centos            | 7       | :white_check_mark: | :white_check_mark:   |
|                   | 8       | :white_check_mark: | :white_check_mark:   |
| Debian            | 9       | :white_check_mark: | :white_check_mark:   |
|                   | 10       | :white_check_mark: | :white_check_mark:   |

### Supported daemon operating systems

| Operating System  | Version | Supported          |
| ----------------- | ------- | ------------------ |
| Ubuntu            | 18.04   | :white_check_mark: |
|                   | 20.04   | :white_check_mark: |
| Debian            | 9       | :white_check_mark: |
|                   | 10      | :white_check_mark: |
| CentOS            | 7       | :white_check_mark: |
|                   | 8       | :white_check_mark: |

# Using the installation scripts

Using the Pterodactyl Panel installation script:

`apt install sudo curl python`

`bash <(curl -s https://raw.githubusercontent.com/valkam08/pterodactyl-installer/master/install-panel.sh)`

Using the Pterodactyl Wings installation script:

`bash <(curl -s https://raw.githubusercontent.com/valkam08/pterodactyl-installer/master/install-wings.sh)`

Using the Pterodactyl Daemon installation script:

`bash <(curl -s https://raw.githubusercontent.com/valkam08/pterodactyl-installer/master/install-daemon.sh)`

The script will guide you through the install.

*Note: On some systems it's required to be already logged in as root before executing the one-line command.*
