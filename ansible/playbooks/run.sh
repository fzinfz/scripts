dir_inv="/data/conf/ansible/inv"

export ANSIBLE_STDOUT_CALLBACK=yaml

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

log_folder=/tmp/ansible
mkdir -p "$log_folder"
rm -f $log_folder/*.log # clear old logs
timestamp=$(date +%Y%m%d_%H%M%S)
export ANSIBLE_LOG_PATH="${log_folder}/${base}_${timestamp}.log"

if [[ ! -f "$path_inv" ]]; then
    echo "Error: inventory file not found: ${path_inv}" >&2
    exit 1
fi

echo ""

if [[ "$selected" == "routers.yaml" ]]; then
    raw_playbook="/tmp/ansible/routers.raw.yaml"
    script_file="/data/scripts/openwrt/uci/wireless_show_ssid.sh"
    awk '
        /ansible\.builtin\.script/ {
            print "      ansible.builtin.raw: |"
            while ((getline line < script_file) > 0) {
                print "        " line
            }
            close(script_file)
            next
        }
        { print }
    ' script_file="$script_file" "$selected" > "$raw_playbook"
    echo "Running: ansible-playbook -i ${path_inv} ${raw_playbook}"
    ansible-playbook -i "$path_inv" "$raw_playbook"
else
    echo "Running: ansible-playbook -i ${path_inv} ${selected}"
    ansible-playbook -i "$path_inv" "$selected"
fi