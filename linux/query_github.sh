SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"; [ -f $SCRIPTPATH/init.sh ] && source $SCRIPTPATH/init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/linux/init.sh)"

repo=$1

echo_info "URL Web: https://github.com/${repo}/releases"

url_api="https://api.github.com/repos/${repo}/releases/latest"
echo_info "URL API: $url_api"
latest_release_str=$(curl -sSL $url_api)
export github_latest_release_ver=$(echo $latest_release_str | grep -oP '(?<=tag_name": ")[^"]+' )

echo_info "browser_download_url list:"
echo $latest_release_str | grep -oP '(?<=browser_download_url": ")[^"]+'

run "env | grep ^github"