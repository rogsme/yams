#!/bin/bash

git clone https://gitlab.com/rogs/yams.git --depth=1 /tmp/yams > /dev/null 2>&1
bash /tmp/yams/install.sh
rm -rf /tmp/yams
