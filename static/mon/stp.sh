sudo apt update && apt install -y openssh-server zram-config unclutter
echo -e 'port 6816\npermitrootlogin prohibit-password' >> /etc/ssh/sshd_config
wget -qO- https://get.docker.com | bash
apt remove --purge "libreoffice-*" vlc-data -y; apt clean -y; apt autoremove -y
wget https://download.nomachine.com/download/8.10/Linux/nomachine_8.10.1_1_amd64.deb
dpkg -i nomachine_8.10.1_1_amd64.deb; rm nomachine_8.10.1_1_amd64.deb
echo "CreateDisplay 0" >> /usr/NX/etc/server.cfg
su - pd -c 'firefox --display=:0 -CreateProfile pd'
for i in $(ls -d /home/pd/snap/firefox/common/.mozilla/firefox/* | grep .pd$); do
    mkdir $i/chrome
    echo '@-moz-document url-prefix(https://pdu.i234.me) {
        #sds-desktop {
            top: 20px !important;
        }
        .x-column-inner {
            opacity:0 !important;
        }
        .x-window-tl {
            display: none !important;
        }
    }' > $i/chrome/userContent.css
    wget https://github.com/arkenfox/user.js/raw/master/user.js -P $i
    grep "toolkit.legacyUserProfileCustomizations.stylesheets" "$i/user.js" || echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$i/user.js"
    chown -R pd:pd $i
done
echo 'xset -dpms s off >/dev/null 2>&1
pkill -f firefox >/dev/null 2>&1; rm /home/pd/snap/firefox/common/.mozilla/firefox/*/*lock >/dev/null 2>&1
(ps aux | grep firefox | grep SurveillanceStation) || (firefox --display=:0 -P pd -kiosk https://pdu.i234.me:5001/webman/3rdparty/SurveillanceStation >/dev/null 2>&1) &
' > /home/pd/.bash_profile
{ echo '0 5 * * * su - pd -c "./.bash_profile &" &>/dev/null </dev/null'; } | crontab -u root -
mkdir .ssh; chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpwOis2kDy3KursJmtLLydEqHb87D6+ixTADi7myw8e pd@d-server
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAp96owJJPXX0o8o7gc6XRqpYGZMAqNpRRVGwJluK6vm pd@any' > .ssh/authorized_keys
su - pd -c 'mkdir .ssh; chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys'
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAp96owJJPXX0o8o7gc6XRqpYGZMAqNpRRVGwJluK6vm pd@any
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpwOis2kDy3KursJmtLLydEqHb87D6+ixTADi7myw8e pd@d-server
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjDMWXdYjxWMZMLHp1Tn38E0ahe8uaQ/eEGdcnnu4SF hass' > /home/pd/.ssh/authorized_keys
sleep 5 && reboot
