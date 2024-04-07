#!/bin/sh
rm -rf /usr/share/sddm/themes/chili
mkdir /usr/share/sddm/themes/chili
cp -rf ./* /usr/share/sddm/themes/chili/
rm -rf /usr/share/sddm/themes/chili/deploy.sh
