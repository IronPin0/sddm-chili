#!/bin/sh
sudo rm -rf /usr/share/sddm/themes/chili
sudo mkdir /usr/share/sddm/themes/chili
sudo cp -rf ./* /usr/share/sddm/themes/chili/
sudo rm -rf /usr/share/sddm/themes/chili/deploy.sh
