#prepare cloud-init to use ssh. See the url for details. > https://aquasoftware.net/blog/?p=1404
#Edit "network-config" and "user-data" accordingly according to the above documents.
#Then plug in the power cable and wait for about five minutes.

#install desktop enviroment
sudo apt update
sudo apt upgrade
sudo apt install ubuntu-desktop
sudo apt install --no-install-recommends lightdm
#Select lightdm on the DisplayManager selection screen.
sudo apt install lightdm-gtk-greeter
#autologin configuration
sudo groupadd -r autologin
sudo gpasswd -a $USER autologin
sudo nano /etc/lightdm/lightdm.conf #USERNAME replaced with individual usernames.
<<New
[Seat:*]
autologin-user=USERNAME
New
sudo reboot

#install i3-gaps
sudo add-apt-repository ppa:regolith-linux/stable
sudo apt install i3-gaps nitrogen dunst xfce4-clipman xfce4-screenshooter picom conky rofi dex
sudo apt install build-essential git cmake cmake-data pkg-config python3-sphinx python3-packaging libuv1-dev libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev
sudo apt install libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev libjsoncpp-dev libmpdclient-dev libcurl4-openssl-dev libnl-genl-3-dev
mkdir ~/Downloads
cd ~/Downloads
wget https://github.com/polybar/polybar/releases/download/3.5.7/polybar-3.5.7.tar.gz
tar -xzvf polybar-3.5.7.tar.gz
cd polybar-3.5.7
mkdir build
cd build
cmake ..
make -j$(nproc)
sudo make install
#netplan renderer setting
sudo nano /etc/netplan/50-cloud-init.yaml
<<Edit
network:
    ethernets:
        eth0:
            dhcp4: true
            optional: true
    version: 2
    renderer: NetworkManager
    wifis:
        wlan0:
            access-points:
                "SSID":
                   password: "PASSWORD"
            dhcp4: true
            dhcp6: true
Edit
sudo apt install zsh zsh-autosuggestions zsh-syntax-highlighting
chsh -s /bin/zsh $USER
#Connect the display.
sudo reboot

#Configure vino-server from gnome-control-center. See the url for details. > {工事中}
#Launch the terminal emulator.
#For zsh-newuser-install, please select (2).
sudo sed -i '$ a autologin-session=i3' /etc/lightdm/lightdm.conf
sudo reboot

#Japanese
sudo apt install language-pack-ja-base language-pack-ja language-pack-gnome-ja fcitx-mozc fonts-noto
localectl set-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"
source /etc/default/locale
tzselect
timedatectl set-ntp true
#install VSCode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt install apt-transport-https
sudo apt update
sudo apt install code
#install recommended
sudo apt install xfce4-terminal
mkdir ~/.fonts
cd ~/.fonts
wget --trust-server-names https://0e0.pw/zMQ5
fc-cache -fv
#i3wm configuration
sudo apt install subversion
cd ~/.config
rm -rf ~/.config/i3
svn checkout https://github.com/sarukiti/rasPi_config/trunk/channels/i3/.config/i3
svn checkout https://github.com/sarukiti/rasPi_config/trunk/channels/i3/.config/polybar
svn checkout https://github.com/sarukiti/rasPi_config/trunk/channels/i3/.config/rofi
svn checkout https://github.com/sarukiti/rasPi_config/trunk/channels/i3/.config/dunst
cd ~/.fonts
#FirgeNerd
curl -sL https://0e0.pw/HELp > FirgeNerd.zip && unzip FirgeNerd.zip && rm FirgeNerd.zip
fc-cache -fv
#powerline settings
nano ~/.zshrc
<<Delete
autoload -Uz promptinit
promptinit
prompt adam1
Delete
cd ~/Downloads
wget https://github.com/justjanne/powerline-go/releases/download/v1.21.0/powerline-go-linux-arm64
mv powerline-go-linux-arm64 powerline-go
sudo cp powerline-go /usr/bin
sudo chmod 755 /usr/bin/powerline-go
nano ~/.zshrc
<<Add
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

if [[ ${TERM} != "linux" ]]; then
    function powerline_precmd() {
        PS1="$(/usr/bin/powerline-go -error $? -shell zsh)"
    }
    function install_powerline_precmd() {
        for s in "${precmd_functions[@]}"; do
            if [ "$s" = "powerline_precmd" ]; then
                return
            fi
        done
        precmd_functions+=(powerline_precmd)
    }

    install_powerline_precmd
fi
Add
#lsd settings
wget https://github.com/Peltoche/lsd/releases/download/0.21.0/lsd_0.21.0_arm64.deb
sudo apt install ./lsd_0.21.0_arm64.deb
sed -i '$ a alias ls="lsd"' ~/.zshrc #I recommend to edit terminal color preset.
source ~/.zshrc
#VNCserver settings
sudo apt install xserver-xorg-video-dummy
sudo nano /usr/share/X11/xorg.conf.d/20-dummy.conf
<<Edit
Section "Device"
    Identifier  "Configured Video Device"
    Driver      "dummy"
    VideoRam 256000
EndSection

Section "Monitor"
    Identifier  "Configured Monitor"
    HorizSync 5.0 - 1000.0
    VertRefresh 5.0 - 200.0
    # 1920x1080 59.96 Hz (CVT 2.07M9) hsync: 67.16 kHz; pclk: 173.00 MHz
    Modeline "1920x1080_60.00"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync
EndSection

Section "Screen"
    Identifier  "Default Screen"
    Monitor     "Configured Monitor"
    Device      "Configured Video Device"
    DefaultDepth 24
    SubSection "Display"
        Depth 24
        Modes "1920x1080"
    EndSubSection
EndSection

Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "jp,us"
    Option "XkbModel" "jp106"
    Option "XkbVariant" ",dvorak"
    Option "XkbOptions" "grp:alt_shift_toggle"
EndSection
Edit
sudo reboot

#For the home directory, select "Keep the old name".
#install ros
#See the url for details. > http://wiki.ros.org/ja/noetic/Installation/Ubuntu

#For other settings that should be done in the GUI, see the url for details. > {工事中}
