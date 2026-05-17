import docker
import flask
import os
import re
import threading
import time
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo

app = flask.Flask(__name__)
client = docker.from_env()

logs = []
MAX_LOGS = 100


def get_tz():
    """Return timezone from TIMEZONE env (default UTC+8)."""
    tz_name = os.environ.get("TIMEZONE", "UTC+8")
    if tz_name.startswith("UTC"):
        offset_str = tz_name[3:]
        if not offset_str:
            return timezone.utc
        sign = 1 if offset_str[0] == "+" else -1
        offset_str = offset_str[1:]
        if ":" in offset_str:
            h, m = offset_str.split(":")
            hours = int(h) + int(m) / 60
        else:
            hours = int(offset_str)
        return timezone(timedelta(hours=sign * hours))
    try:
        return ZoneInfo(tz_name)
    except Exception:
        return timezone(timedelta(hours=8))


def add_log(message):
    timestamp = datetime.now(get_tz()).strftime("%Y-%m-%d %H:%M:%S")
    logs.append(f"[{timestamp}] {message}")
    if len(logs) > MAX_LOGS:
        logs.pop(0)


def format_ports(container):
    """Format container ports, falling back to attrs if .ports is empty."""
    ports = getattr(container, "ports", None) or {}
    # Check for host network mode when ports appear empty
    if not ports:
        network_mode = container.attrs.get("HostConfig", {}).get("NetworkMode", "")
        if network_mode == "host":
            return "host net"
    # Some containers have empty .ports but full data in attrs
    if not ports:
        ports = container.attrs.get("NetworkSettings", {}).get("Ports") or {}
    if not ports:
        # For containers with only exposed ports
        exposed = container.attrs.get("Config", {}).get("ExposedPorts") or {}
        ports = {k: None for k in exposed.keys()}
    if not ports:
        return "-"
    parts = []
    for k, v in ports.items():
        if v:
            for binding in v:
                host_ip = binding.get("HostIp", "")
                host_port = binding.get("HostPort", "")
                if host_ip:
                    parts.append(f"{host_ip}:{host_port}->{k}")
                else:
                    parts.append(f"{host_port}->{k}")
        else:
            parts.append(k)
    return ", ".join(parts) if parts else "-"


def format_status(container):
    """Format status like 'Up 2 minutes' (similar to 'docker ps')."""
    state = container.attrs.get("State", {})
    raw_status = state.get("Status", container.status).lower()
    if raw_status == "running":
        started_at_str = state.get("StartedAt", "")
        if started_at_str:
            try:
                # Docker returns ISO format like "2024-01-01T00:00:00.000000000Z"
                ts = started_at_str.replace("Z", "+00:00")
                started_at = datetime.fromisoformat(ts)
                now = datetime.now(get_tz())
                # Ensure both are offset-aware or naive
                if started_at.tzinfo is None:
                    started_at = started_at.replace(tzinfo=timezone.utc).astimezone(get_tz())
                delta = now - started_at
                seconds = int(delta.total_seconds())
                if seconds < 60:
                    return f"Up {seconds} second{'s' if seconds != 1 else ''}"
                elif seconds < 3600:
                    m = seconds // 60
                    return f"Up {m} minute{'s' if m != 1 else ''}"
                elif seconds < 86400:
                    h = seconds // 3600
                    return f"Up {h} hour{'s' if h != 1 else ''}"
                else:
                    d = seconds // 86400
                    return f"Up {d} day{'s' if d != 1 else ''}"
            except Exception:
                pass
        return "Up"
    return raw_status.capitalize()


def format_started_at(container):
    """Format StartedAt as yy/mm/dd hh:mm:ss."""
    state = container.attrs.get("State", {})
    started_at_str = state.get("StartedAt", "")
    if started_at_str:
        try:
            ts = started_at_str.replace("Z", "+00:00")
            dt = datetime.fromisoformat(ts)
            if dt.tzinfo is None:
                dt = dt.replace(tzinfo=timezone.utc).astimezone(get_tz())
            else:
                dt = dt.astimezone(get_tz())
            return dt.strftime("%y/%m/%d %H:%M:%S")
        except Exception:
            pass
    return "-"


def get_running_containers():
    try:
        containers = client.containers.list()
        result = []
        grep_e = os.environ.get("GREP_E_STRING")
        grep_ve = os.environ.get("GREP_vE_STRING")
        for c in containers:
            name = c.name
            if grep_e and not re.search(grep_e, name):
                continue
            if grep_ve and re.search(grep_ve, name):
                continue
            result.append({
                "id": c.short_id,
                "name": name,
                "image": c.image.tags[0] if c.image.tags else c.image.id[:12],
                "status": format_status(c),
                "raw_status": c.status,
                "started_at": format_started_at(c),
                "ports": format_ports(c),
            })
        return result
    except Exception as e:
        add_log(f"Error listing containers: {e}")
        return []


def restart_container(container_id):
    try:
        container = client.containers.get(container_id)
        name = container.name
        add_log(f"Restarting container: {name} ({container_id})...")
        container.restart(timeout=10)
        add_log(f"Container {name} restarted successfully.")
    except Exception as e:
        add_log(f"Failed to restart container {container_id}: {e}")


@app.route("/")
def index():
    containers = get_running_containers()
    return flask.render_template_string(HTML_PAGE, containers=containers, logs=logs)


@app.route("/api/containers")
def api_containers():
    return flask.jsonify(get_running_containers())


@app.route("/api/restart/<container_id>", methods=["POST"])
def api_restart(container_id):
    threading.Thread(target=restart_container, args=(container_id,), daemon=True).start()
    return flask.jsonify({"success": True, "message": f"Restarting {container_id}"})


@app.route("/api/logs")
def api_logs():
    return flask.jsonify(logs)


HTML_PAGE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Docker Container Manager</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: #0d1117;
            color: #c9d1d9;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        header {
            background: #161b22;
            border-bottom: 1px solid #30363d;
            padding: 20px 40px;
        }
        header h1 { font-size: 24px; color: #58a6ff; }
        header p { color: #8b949e; margin-top: 4px; font-size: 14px; }
        main {
            flex: 1;
            padding: 30px 40px;
        }
        .toolbar {
            margin-bottom: 20px;
            display: flex;
            gap: 10px;
            align-items: center;
        }
        .btn {
            padding: 8px 16px;
            border: 1px solid #30363d;
            background: #21262d;
            color: #c9d1d9;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.2s;
        }
        .btn:hover { background: #30363d; border-color: #8b949e; }
        .btn.primary { background: #238636; border-color: #238636; color: #fff; }
        .btn.primary:hover { background: #2ea043; }
        .btn.warn { background: #9e6a03; border-color: #9e6a03; color: #fff; }
        .btn.warn:hover { background: #b38807; }
        .container-grid {
            display: flex;
            flex-wrap: wrap;
            gap: 16px;
        }
        .card {
            background: #161b22;
            border: 1px solid #30363d;
            border-radius: 10px;
            padding: 18px 20px;
            min-width: 260px;
            flex: 1 1 260px;
            max-width: 360px;
            display: flex;
            flex-direction: column;
            gap: 10px;
            transition: border-color 0.2s;
        }
        .card:hover { border-color: #58a6ff; }
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .card-name {
            font-size: 16px;
            font-weight: 600;
            color: #e6edf3;
            word-break: break-all;
        }
        .badge {
            font-size: 12px;
            padding: 2px 8px;
            border-radius: 12px;
            font-weight: 500;
        }
        .badge.running { background: rgba(35,134,54,0.2); color: #3fb950; }
        .badge.other { background: rgba(158,106,3,0.2); color: #d29922; }
        .card-meta {
            font-size: 13px;
            color: #8b949e;
            line-height: 1.5;
        }
        .card-meta span { color: #58a6ff; }
        .card-actions {
            margin-top: auto;
            padding-top: 10px;
            border-top: 1px solid #21262d;
            display: flex;
            gap: 8px;
        }
        .card-actions .btn {
            flex: 1;
            text-align: center;
        }
        .empty {
            color: #8b949e;
            font-size: 15px;
            padding: 40px 0;
        }
        .log-section {
            background: #161b22;
            border-top: 1px solid #30363d;
            max-height: 320px;
            display: flex;
            flex-direction: column;
        }
        .log-header {
            padding: 12px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #0d1117;
            border-bottom: 1px solid #30363d;
        }
        .log-header h2 { font-size: 14px; color: #8b949e; font-weight: 500; }
        .log-body {
            flex: 1;
            overflow-y: auto;
            padding: 12px 40px;
            font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, monospace;
            font-size: 13px;
            line-height: 1.6;
        }
        .log-line {
            padding: 2px 0;
            color: #8b949e;
        }
        .log-line.success { color: #3fb950; }
        .log-line.error { color: #f85149; }
        .log-line.info { color: #58a6ff; }
    </style>
</head>
<body>
    <header>
        <h1>Docker Container Manager</h1>
        <p>Running containers on this host</p>
    </header>
    <main>
        <div class="toolbar">
            <button class="btn primary" onclick="refreshContainers()">Refresh</button>
            <span id="count"></span>
        </div>
        <div class="container-grid" id="grid">
            {% for c in containers %}
            <div class="card" data-id="{{ c.id }}">
                <div class="card-header">
                    <div class="card-name">{{ c.name }}</div>
                    <div class="badge {{ 'running' if c.raw_status == 'running' else 'other' }}">{{ c.status }}</div>
                </div>
                <div class="card-meta">
                    ID: <span>{{ c.id }}</span><br>
                    Image: <span>{{ c.image }}</span><br>
                    StartedAt: <span>{{ c.started_at }}</span><br>
                    Ports: <span>{{ c.ports }}</span>
                </div>
                <div class="card-actions">
                    <button class="btn warn" onclick="restart('{{ c.id }}', '{{ c.name }}')">Restart</button>
                </div>
            </div>
            {% endfor %}
            {% if not containers %}
            <div class="empty">No running containers found.</div>
            {% endif %}
        </div>
    </main>
    <section class="log-section">
        <div class="log-header">
            <h2>Activity Log</h2>
            <button class="btn" onclick="clearLogs()">Clear</button>
        </div>
        <div class="log-body" id="logBody">
            {% for line in logs %}
            <div class="log-line">{{ line }}</div>
            {% endfor %}
            {% if not logs %}
            <div class="log-line">Waiting for activity...</div>
            {% endif %}
        </div>
    </section>
    <script>
        function refreshContainers() {
            fetch('/api/containers')
                .then(r => r.json())
                .then(data => renderContainers(data));
        }
        function renderContainers(list) {
            const grid = document.getElementById('grid');
            const count = document.getElementById('count');
            count.textContent = list.length + ' running';
            if (!list.length) {
                grid.innerHTML = '<div class="empty">No running containers found.</div>';
                return;
            }
            grid.innerHTML = list.map(c => `
                <div class="card" data-id="${c.id}">
                    <div class="card-header">
                        <div class="card-name">${escapeHtml(c.name)}</div>
                        <div class="badge ${c.raw_status === 'running' ? 'running' : 'other'}">${c.status}</div>
                    </div>
                    <div class="card-meta">
                        ID: <span>${c.id}</span><br>
                        Image: <span>${escapeHtml(c.image)}</span><br>
                        StartedAt: <span>${c.started_at}</span><br>
                        Ports: <span>${escapeHtml(c.ports)}</span>
                    </div>
                    <div class="card-actions">
                        <button class="btn warn" onclick="restart('${c.id}', '${escapeHtml(c.name)}')">Restart</button>
                    </div>
                </div>
            `).join('');
        }
        function restart(id, name) {
            if (!confirm('Restart container "' + name + '"?')) return;
            fetch('/api/restart/' + id, { method: 'POST' })
                .then(r => r.json())
                .then(data => {
                    appendLog('Requested restart for ' + name, 'info');
                });
        }
        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
        function appendLog(text, cls) {
            const body = document.getElementById('logBody');
            const div = document.createElement('div');
            div.className = 'log-line ' + (cls || '');
            div.textContent = text;
            body.appendChild(div);
            body.scrollTop = body.scrollHeight;
        }
        function clearLogs() {
            document.getElementById('logBody').innerHTML = '<div class="log-line">Waiting for activity...</div>';
        }
        setInterval(() => {
            fetch('/api/logs')
                .then(r => r.json())
                .then(data => {
                    const body = document.getElementById('logBody');
                    if (!data.length) return;
                    body.innerHTML = data.map(line => {
                        let cls = '';
                        if (line.includes('success') || line.includes('Restarting')) cls = 'success';
                        if (line.includes('Error') || line.includes('Failed')) cls = 'error';
                        if (line.includes('Restarting')) cls = 'info';
                        return `<div class="log-line ${cls}">${escapeHtml(line)}</div>`;
                    }).join('');
                    body.scrollTop = body.scrollHeight;
                });
        }, 2000);
        setInterval(refreshContainers, 5000);
    </script>
</body>
</html>
"""

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
