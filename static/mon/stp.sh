sudo apt update && apt install -y openssh-server zram-config unclutter
echo -e 'port 6816\npermitrootlogin prohibit-password' >> /etc/ssh/sshd_config
wget -qO- https://get.docker.com | bash
apt remove --purge "libreoffice-*" vlc-data -y; apt clean -y; apt autoremove -y
wget https://download.nomachine.com/download/8.10/Linux/nomachine_8.10.1_1_amd64.deb
dpkg -i nomachine_8.10.1_1_amd64.deb; rm nomachine_8.10.1_1_amd64.deb
echo "CreateDisplay 0" >> /usr/NX/etc/server.cfg
sed -i 's/mode:\t\tone/mode:\t\toff/g' /home/pd/.xscreensaver
su - pd -c 'xscreensaver-command -restart'
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
    echo '
    user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
    user_pref("media.peerconnection.ice.relay_only", true);
    user_pref("signon.firefoxRelay.feature disabled", true);
    user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
    user_pref("browser.newtabpage.activity-stream.telemetry", false);
    user_pref("browser.ping-centre.telemetry", false);
    user_pref("datareporting.healthreport.service.enabled", false);
    user_pref("datareporting.healthreport.uploadEnabled", false);
    user_pref("datareporting.policy.dataSubmissionEnabled", false);
    user_pref("datareporting.sessions.current.clean", true);
    user_pref("devtools.onboarding.telemetry.logged", false);
    user_pref("toolkit.telemetry.archive.enabled", false);
    user_pref("toolkit.telemetry.bhrPing.enabled", false);
    user_pref("toolkit.telemetry.enabled", false);
    user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
    user_pref("toolkit.telemetry.hybridContent.enabled", false);
    user_pref("toolkit.telemetry.newProfilePing.enabled", false);
    user_pref("toolkit.telemetry.prompted", Number Value 2);
    user_pref("toolkit.telemetry.rejected", true);
    user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
    user_pref("toolkit.telemetry.server", Delete URL);
    user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
    user_pref("toolkit.telemetry.unified", false);
    user_pref("toolkit.telemetry.unifiedIsOptIn", false);
    user_pref("toolkit.telemetry.updatePing.enabled", false);
    user_pref("app.shield.optoutstudies.enabled", false);
    user_pref("captivedetect.canonicalURL", "");
    user_pref("network.captive-portal-service.enabled", false);
    user_pref("browser. sessionstore. resume_from_crash", false);
    user_pref("media.videocontrols.picture-in-picture.video-toggle-enabled", false);
    ' > "$i/user.js"
    chown -R pd:pd $i
done
echo 'xset -dpms s off >/dev/null 2>&1
pkill -f firefox >/dev/null 2>&1; rm /home/pd/snap/firefox/common/.mozilla/firefox/*/*lock >/dev/null 2>&1
(ps aux | grep firefox | grep SurveillanceStation) || (firefox --display=:0 -P pd -kiosk https://pdu.i234.me:5001/webman/3rdparty/SurveillanceStation >/dev/null 2>&1) &
' > /home/pd/.bash_profile && chown pd:pd /home/pd/.bash_profile && chmod +x /home/pd/.bash_profile
echo "Hidden=true" >> /etc/xdg/autostart/upg-notifier-autostart.desktop
{ echo '0 5 * * * su - pd -c "./.bash_profile &" &>/dev/null </dev/null'; } | crontab -u root -
mkdir .ssh; chmod 700 ~/.ssh; touch ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpwOis2kDy3KursJmtLLydEqHb87D6+ixTADi7myw8e pd@d-server
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAp96owJJPXX0o8o7gc6XRqpYGZMAqNpRRVGwJluK6vm pd@any' >> .ssh/authorized_keys
su - pd -c 'mkdir .ssh; chmod 700 ~/.ssh;touch ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys'
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAp96owJJPXX0o8o7gc6XRqpYGZMAqNpRRVGwJluK6vm pd@any
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpwOis2kDy3KursJmtLLydEqHb87D6+ixTADi7myw8e pd@d-server
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFjDMWXdYjxWMZMLHp1Tn38E0ahe8uaQ/eEGdcnnu4SF hass' >> /home/pd/.ssh/authorized_keys
echo 'd () { docker $@; }
dp () { while true; do TEXT=$(docker ps --format="table {{ .ID }}\t{{.Names}}\t{{.Status}}"); sleep 0.1; clear; echo "$TEXT"; done; }
ds () { docker stats --format "table {{.Container}}\t{{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}\t{{.MemUsage}}"; }
dl () { [[ ! -z $1 ]] && d logs -f $1; }
de () { [[ -z ${@:2} ]] && (docker exec -ti $1 bash || docker exec -ti $1 sh) || docker exec -ti $1 ${@:2}; }
r () { su - pd -c "./.bash_profile &" &>/dev/null </dev/null; }' > .bash_aliases
echo "DNSStubListener=no" >> /etc/systemd/resolved.conf
systemctl disable --now systemd-resolved
systemctl enable --now systemd-resolved
sleep 5 && reboot
