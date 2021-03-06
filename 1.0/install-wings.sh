#!/bin/bash
###########################################################
# pterodactyl-installer for wings
# Copyright Vilhelm Prytz 2018-2019
#
# https://github.com/Valkam08/pterodactyl-installer
###########################################################

# check if user is root or not
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run with root privileges (sudo)." 1>&2
  exit 1
fi

# check for curl
CURLPATH="$(which curl)"
if [ -z "$CURLPATH" ]; then
    echo "* curl is required in order for this script to work."
    echo "* install using apt on Debian/Ubuntu or yum on CentOS"
    exit 1
fi

# check for python
PYTHONPATH="$(which python)"
if [ -z "$PYTHONPATH" ]; then
    echo "* python is required in order for this script to work."
    echo "* install using apt on Debian/Ubuntu or yum on CentOS"
    exit 1
fi

# define version using information from GitHub
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

echo "* Retrieving release information.."
VERSION="$(get_latest_release "pterodactyl/wings")"

echo "* Latest version is $VERSION"

# DL urls
DL_URL="https://github.com/pterodactyl/wings/releases/download/$VERSION/wings_linux_amd64"
CONFIGS_URL="https://raw.githubusercontent.com/Valkam08/pterodactyl-installer/master/1.0"

# variables
OS="debian"

# visual functions
function print_error {
  COLOR_RED='\033[0;31m'
  COLOR_NC='\033[0m'

  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1"
  echo ""
}

function print_brake {
  for ((n=0;n<$1;n++));
    do
      echo -n "#"
    done
    echo ""
}


# other functions
function detect_distro {
  echo "$(python -c 'import platform ; print platform.dist()[0]')" | awk '{print tolower($0)}'
}

function detect_os_version {
  echo "$(python -c 'import platform ; print platform.dist()[1].split(".")[0]')"
}

function check_os_comp {
  if [ "$OS" == "ubuntu" ]; then
    if [ "$OS_VERSION" == "18" ]; then
      SUPPORTED=true
    elif [ "$OS_VERSION" == "20" ]; then
      SUPPORTED=true
    else
      SUPPORTED=false
    fi
  elif [ "$OS" == "debian" ]; then
    if [ "$OS_VERSION" == "9" ]; then
      SUPPORTED=true
    elif [ "$OS_VERSION" == "10" ]; then
      SUPPORTED=true
    else
      SUPPORTED=false
    fi
  elif [ "$OS" == "centos" ]; then
    if [ "$OS_VERSION" == "7" ]; then
      SUPPORTED=true
    elif [ "$OS_VERSION" == "8" ]; then
      SUPPORTED=true
    else
      SUPPORTED=false
    fi
  else
    SUPPORTED=false
  fi

  # exit if not supported
  if [ "$SUPPORTED" == true ]; then
    echo "* $OS $OS_VERSION is supported."
  else
    echo "* $OS $OS_VERSION is not supported"
    print_error "Unsupported OS"
    exit 1
  fi
}

############################
## INSTALLATION FUNCTIONS ##
############################
function yum_update {
  yum update -y
}

function apt_update {
  apt update -y && apt upgrade -y
}

function install_docker {
  echo "* Installing docker .."
  if [ "$OS" == "debian" ]; then
    # install dependencies for Docker
    apt-get update
    apt-get -y install \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common

    # get their GPG key
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

    # show fingerprint to user
    apt-key fingerprint 0EBFCD88

    # add APT repo
    sudo add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/debian \
      $(lsb_release -cs) \
      stable"

    # install docker
    apt-get update
    apt-get -y install docker-ce

    # make sure it's enabled & running
    systemctl start docker
    systemctl enable docker

  elif [ "$OS" == "ubuntu" ]; then
    # install dependencies for Docker
    apt-get update
    apt-get -y install \
      apt-transport-https \
      ca-certificates \
      curl \
      software-properties-common

    # get their GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    # show fingerprint to user
    apt-key fingerprint 0EBFCD88

    # add APT repo
    sudo add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) \
     stable"

    # install docker
    apt-get update
    apt-get -y install docker-ce

    # make sure it's enabled & running
    systemctl start docker
    systemctl enable docker

  elif [ "$OS" == "centos" ]; then
    # install dependencies for Docker
    yum install -y yum-utils \
      device-mapper-persistent-data \
      lvm2

    # add repo to yum
    yum-config-manager \
      --add-repo \
      https://download.docker.com/linux/centos/docker-ce.repo

    # install Docker
    yum install -y docker-ce

    # make sure it's enabled & running
    systemctl start docker
    systemctl enable docker
  fi

  echo "* Docker has now been installed."
}

function install_wings {
  echo "* Installing pterodactyl wings .. "
  mkdir -p /etc/pterodactyl
  cd /srv/wings

  curl -L -o /usr/local/bin/wings $DL_URL
  chmod u+x /usr/local/bin/wings

  echo "* Done."
}

function systemd_file {
  echo "* Installing systemd service.."
  curl -o /etc/systemd/system/wings.service $CONFIGS_URL/wings.service
  systemctl enable --now wings
  echo "* Installed systemd service!"
}

####################
## MAIN FUNCTIONS ##
####################
function perform_install {
  echo "* Installing pterodactyl wings.."
  install_docker
  install_wings
  systemd_file
}

function main {
  print_brake 42
  echo "* Pterodactyl wings installation script "
  echo "* Detecting operating system."
  OS=$(detect_distro);
  OS_VERSION=$(detect_os_version);
  echo "* Running $OS version $OS_VERSION."
  print_brake 42

  # checks if the system is compatible with this installation script
  check_os_comp

  echo "* The installer will install Docker, required dependencies for the wings"
  echo "* as well as the wings itself. But it is still required to create the node"
  echo "* on the panel and then place the configuration on the node after the"
  echo "* installation has finished. Read more about the process:"
  echo "* https://pterodactyl.io/wings/installing.html#configure-wings"
  print_brake 42
  echo -n "* Proceed with installation? (y/n): "

  read CONFIRM

  if [ "$CONFIRM" == "y" ]; then
    perform_install
  elif [ "$CONFIRM" == "n" ]; then
    exit 0
  else
    print_error "Invalid input"
    exit 1
  fi
}

function goodbye {
  echo ""
  print_brake 70
  echo "* Installation finished."
  echo ""
  echo "* Make sure you create the node within the panel and then "
  echo "* copy the config to the node. You may then start the wings using "
  echo "* systemctl start wings"
  echo "* NOTE: It is recommended to also enable swap (for docker)."
  print_brake 70
  echo ""
}

# run main
main
goodbye
