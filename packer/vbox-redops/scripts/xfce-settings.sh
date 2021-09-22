# Add these settings for staging when we get to Vagrant

VAGRANT_HOME="/home/vagrant"

mkdir $VAGRANT_HOME/{Desktop,Downloads,Templates,Public,Documents,Music,Pictures,Videos}
chown -R $VAGRANT_HOME/*

touch $VAGRANT_HOME/.config/user-dirs.dirs

echo "
XDG_DESKTOP_DIR="$VAGRANT_HOME/Desktop"
XDG_DOWNLOAD_DIR="$VAGRANT_HOME/Downloads"
XDG_TEMPLATES_DIR="$VAGRANT_HOME/Templates"
XDG_PUBLICSHARE_DIR="$VAGRANT_HOME/Public"
XDG_DOCUMENTS_DIR="$VAGRANT_HOME/Documents"
XDG_MUSIC_DIR="$VAGRANT_HOME/Music"
XDG_PICTURES_DIR="$VAGRANT_HOME/Pictures"
XDG_VIDEOS_DIR="$VAGRANT_HOME/Videos"
" > $VAGRANT_HOME/.config/user-dirs.dirs
