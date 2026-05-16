#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mapfile -t YML_FILES < <(find "$SCRIPT_DIR" -iname '*.yml' | sort)

if [ ${#YML_FILES[@]} -eq 0 ]; then
  echo "Error: no .yml files found in $SCRIPT_DIR" >&2
  exit 1
elif [ ${#YML_FILES[@]} -eq 1 ]; then
  COMPOSE_FILE="${YML_FILES[0]}"
else
  echo "Multiple compose files found:"
  for i in "${!YML_FILES[@]}"; do
    printf '  %d) %s\n' "$((i + 1))" "$(basename "${YML_FILES[i]}")"
  done
  read -rp "Select file (1-${#YML_FILES[@]}): " choice
  if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#YML_FILES[@]}" ]; then
    echo "Invalid selection." >&2
    exit 1
  fi
  COMPOSE_FILE="${YML_FILES[$((choice - 1))]}"
fi

if grep -q '^# README' "$COMPOSE_FILE"; then
  echo
  echo "README from $(basename "$COMPOSE_FILE"):"
  awk '/^# README/{found=1; next} found && NF==0{exit} found{print}' "$COMPOSE_FILE"
  echo
fi

case "${1:-up}" in
  up|start)
    docker-compose -f "$COMPOSE_FILE" up -d
    docker-compose -f "$COMPOSE_FILE" ps
    ;;
  down|stop)
    docker-compose -f "$COMPOSE_FILE" down
    ;;
  restart)
    docker-compose -f "$COMPOSE_FILE" restart
    ;;
  logs)
    docker-compose -f "$COMPOSE_FILE" logs -f
    ;;
  pull)
    docker-compose -f "$COMPOSE_FILE" pull
    ;;
  *)
    exit 1
    ;;
esac

echo
echo "Usage: $0 {up|down|restart|logs|pull}"