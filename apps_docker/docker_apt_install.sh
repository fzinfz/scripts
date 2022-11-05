. ./_pre.sh

command -v apt >/dev/null 2>/dev/null || exit_err "OS not supported"

apt list --installed 2>/dev/null | grep docker.io
[ $? -eq 0 ] && exit_err "docker.io by Linux installed"

apt list --installed 2>/dev/null | grep docker-ce
[ $? -eq 0 ] && exit_err "docker-ce by Docker Inc installed"

echo_tip https://docs.docker.com/engine/install/debian/#set-up-the-repository

apt-get update
apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
run "apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin"