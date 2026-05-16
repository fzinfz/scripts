dir_inv="/data/conf/ansible/inv"

# Scan *.yaml files in current directory
mapfile -t playbooks < <(ls -1 *.yaml 2>/dev/null)
if [[ ${#playbooks[@]} -eq 0 ]]; then
    echo "Error: no *.yaml files found in $(pwd)" >&2
    exit 1
fi

echo ""
echo "Available playbooks:"
for i in "${!playbooks[@]}"; do
    printf "  %d) %s\n" "$((i + 1))" "${playbooks[$i]}"
done

echo ""
read -rp "Select a playbook to run [${#playbooks[@]}]: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#playbooks[@]} )); then
    echo "Error: invalid selection." >&2
    exit 1
fi

selected="${playbooks[$((choice - 1))]}"
base="${selected%.yaml}"
path_inv="${dir_inv}/${base}.ini"

if [[ ! -f "$path_inv" ]]; then
    echo "Error: inventory file not found: ${path_inv}" >&2
    exit 1
fi

echo ""
echo "Running: ansible-playbook -i ${path_inv} ${selected}"
ansible-playbook -i "$path_inv" "$selected"