#!/bin/bash

set -euo pipefail


go test -v koding/klient/remote... \
  koding/klientctl... \
  koding/mountcli...
#  koding/fuseklient/transport...

# Manually testing individual functions because Fuse is having issues
# on wercker currently.
cat << EOF
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!Partial fuseklient tests run!!!

TODO: Remove -run whitelists once 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
EOF
#go test -v -run TestDir koding/fuseklient...
#go test -v -run TestNode koding/fuseklient...
#go test -v -run TestContentReadWriter koding/fuseklient...
#go test -v -run TestEntry koding/fuseklient...
#go test -v -run TestFakeTransport koding/fuseklient...
#go test -v -run TestErrorTransport koding/fuseklient...
#go test -v -run TestFindWatcher koding/fuseklient...
