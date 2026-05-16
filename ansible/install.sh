if command -v ansible &> /dev/null; then
    echo "Ansible is already installed."
else
    echo "Installing Ansible..."
    uv tool install ansible-core --with ansible
fi
ansible --version