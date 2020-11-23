VERSION="1.0"

function main {
  echo "* Pterodactyl panel installation script "

  echo "* [1] - 0.7.19"
  echo "* [2] - latest"

  echo ""

  echo -n "* Quelle version voulez-vous installer : "
  read VERSION

  if [ "$WEBSERVER_INPUT" == "1" ]; then
    VERSION="0.7"
  elif [ "$WEBSERVER_INPUT" == "2" ]; then
    VERSION="1.0"
  fi

  bash <(curl -s https://raw.githubusercontent.com/valkam08/pterodactyl-installer/${VERSION}/install-panel-${VERSION}.sh)

}