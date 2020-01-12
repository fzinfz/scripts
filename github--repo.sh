repo=$1

echo "URL Web: https://github.com/${repo}/releases"

url_api="https://api.github.com/repos/${repo}/releases/latest"
echo "URL API: $url_api"
latest_release_str=$(curl -sSL $url_api)
export github_latest_release_ver=$(echo $latest_release_str | grep -oP '(?<=tag_name": ")[^"]+' )
export github_latest_release_url=$(echo $latest_release_str | grep -oP '(?<=browser_download_url": ")[^"]+')

env | grep ^github
