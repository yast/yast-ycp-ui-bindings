#! /bin/bash

set -x

if [ "$TRAVIS_EVENT_TYPE" = "push" -a "$TRAVIS_BRANCH" = "master" ]; then
  docker run -it -e TRAVIS=1 -e TRAVIS_JOB_ID="$TRAVIS_JOB_ID" \
    -e SURGE_LOGIN="$SURGE_LOGIN" -e SURGE_TOKEN="$SURGE_TOKEN" \
    yast-ycp-ui-bindings-image \
    /bin/bash -c \
    "zypper  in -y npm doxygen; npm install --global surge; rake doc;
    surge --project ./autodocs/html --domain yast-ui-bindings.surge.sh"
else
  echo "not published"
fi
