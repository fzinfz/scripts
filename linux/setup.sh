
shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

set_timezone_shanghai() {
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    echo "Asia/Shanghai" > /etc/timezone
    export TZ='Asia/Shanghai'
}

add_current_path_to_PATH() {
    CURRENT_DIR=$(dirname "$(readlink -f "$BASH_SOURCE")")
    if [[ ! $PATH = *"$CURRENT_DIR"* ]];then
        export PATH=$PATH:$CURRENT_DIR
    fi
}


install-browser-debian8() {
    apt install -y firefox-esr firefox-esr-l10n-zh-cn firefox-esr-l10n-zh-tw \
    chromium chromium-l10n
}

install-docker() {
    curl -fsSL get.docker.com | bash
}
