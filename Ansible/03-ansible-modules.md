# 3. Ansible Modules

Modules are the **units of work** Ansible executes on managed nodes. Each task calls exactly one module. Below are the most common ones.

> Most modules are **idempotent** — they only change the system if it isn't already in the desired state.

---

## `apt` — Debian/Ubuntu Packages

```yaml
- name: Install a single package
  apt:
    name: nginx
    state: present
    update_cache: true          # like apt update

- name: Install multiple packages
  apt:
    name:
      - git
      - curl
      - htop
    state: present

- name: Upgrade all packages
  apt:
    upgrade: dist

- name: Remove a package
  apt:
    name: apache2
    state: absent
```

| `state` | Meaning |
|---------|---------|
| `present` | Install if missing |
| `latest` | Install/upgrade to newest |
| `absent` | Remove |

---

## `yum` / `dnf` — RHEL/CentOS/Fedora Packages

```yaml
- name: Install nginx on RHEL family
  yum:
    name: nginx
    state: present

- name: Remove a package
  dnf:
    name: telnet
    state: absent
```

Use `apt` for Ubuntu/Debian, `yum`/`dnf` for RHEL/CentOS/Fedora.

---

## `service` — Manage Services

```yaml
- name: Start and enable nginx
  service:
    name: nginx
    state: started        # started | stopped | restarted | reloaded
    enabled: true         # start on boot
```

| `state` | Effect |
|---------|--------|
| `started` | Ensure running (no restart if already up) |
| `stopped` | Ensure stopped |
| `restarted` | Always restart |
| `reloaded` | Reload config without full restart |

---

## `copy` — Push a File to the Node

```yaml
- name: Copy a static file
  copy:
    src: files/index.html         # local path on control node
    dest: /var/www/html/index.html
    owner: www-data
    group: www-data
    mode: '0644'

- name: Write content inline (no source file)
  copy:
    content: "Hello from Ansible\n"
    dest: /etc/motd
```

---

## `template` — Push a File with Variables (Jinja2)

Like `copy`, but processes `{{ variables }}` first. Source files end in `.j2`.

`templates/index.html.j2`:
```html
<h1>Welcome to {{ server_name }}</h1>
<p>Environment: {{ env }}</p>
```

Task:
```yaml
- name: Deploy templated page
  template:
    src: templates/index.html.j2
    dest: /var/www/html/index.html
    mode: '0644'
  vars:
    server_name: web1
    env: production
```

| Module | Variable substitution? |
|--------|------------------------|
| `copy` | No — file copied as-is |
| `template` | Yes — Jinja2 rendered |

---

## `file` — Manage Files, Directories, Links, Permissions

```yaml
- name: Create a directory
  file:
    path: /opt/myapp
    state: directory
    owner: azureuser
    mode: '0755'

- name: Create an empty file
  file:
    path: /opt/myapp/app.log
    state: touch

- name: Create a symlink
  file:
    src: /opt/myapp/current
    dest: /opt/myapp/latest
    state: link

- name: Delete a file or directory
  file:
    path: /tmp/old
    state: absent
```

| `state` | Meaning |
|---------|---------|
| `directory` | Ensure directory exists |
| `touch` | Create empty file / update timestamp |
| `link` | Create symlink |
| `absent` | Delete |

---

## Other Commonly Used Modules

```yaml
- name: Run a shell command
  shell: echo $HOME > /tmp/home.txt

- name: Run a command (no shell features like pipes)
  command: /usr/bin/whoami

- name: Add a line to a file
  lineinfile:
    path: /etc/hosts
    line: "10.0.0.50 app.internal"

- name: Clone a git repo
  git:
    repo: https://github.com/example/app.git
    dest: /opt/app

- name: Create a user
  user:
    name: deploy
    groups: sudo
    shell: /bin/bash
```

> Prefer `command` over `shell` unless you need pipes/redirects. Prefer purpose-built modules (`apt`, `service`, `copy`) over `shell` because they're idempotent.

---

## Finding Module Docs

```bash
ansible-doc apt          # full docs for a module
ansible-doc -l           # list all modules
ansible-doc -s service   # short usage snippet
```

---

## Quick Recap

| Module | Purpose |
|--------|---------|
| `apt` / `yum` / `dnf` | Package management |
| `service` | Start/stop/enable services |
| `copy` | Push files as-is |
| `template` | Push files with variable substitution |
| `file` | Manage files, dirs, links, permissions |
| `shell` / `command` | Run arbitrary commands |
