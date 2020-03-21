#!/usr/bin/env bash

gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
source /home/vagrant/.rvm/scripts/rvm
rvm --default use --install 2.7.0
