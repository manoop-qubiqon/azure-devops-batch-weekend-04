# 5. Ansible Roles

A **role** is a standardized way to package and reuse Ansible content — tasks, handlers, variables, templates, and files — in a predictable folder structure. Roles keep large projects clean and shareable.

---

## Why Roles?

Without roles a playbook becomes one giant file. Roles let you:
- Split logic into reusable, self-contained units (e.g. `nginx`, `postgres`, `common`).
- Share via Ansible Galaxy.
- Auto-load files by convention (no manual `include` for each part).

---

## Role Directory Structure

```
roles/
└── webserver/
    ├── tasks/
    │   └── main.yml        # main list of tasks (required)
    ├── handlers/
    │   └── main.yml        # handlers
    ├── templates/
    │   └── index.html.j2   # Jinja2 templates
    ├── files/
    │   └── app.conf        # static files to copy
    ├── vars/
    │   └── main.yml         # high-priority variables
    ├── defaults/
    │   └── main.yml         # default (lowest-priority) variables
    ├── meta/
    │   └── main.yml         # role metadata & dependencies
    └── README.md
```

Ansible **auto-loads** `main.yml` from each folder — you don't reference them explicitly.

| Folder | Holds | Auto-loaded |
|--------|-------|-------------|
| `tasks/` | Tasks to run | Yes (`main.yml`) |
| `handlers/` | Handlers | Yes |
| `templates/` | Jinja2 `.j2` files | Referenced by `template:` |
| `files/` | Static files | Referenced by `copy:` |
| `vars/` | Variables (high priority) | Yes |
| `defaults/` | Default variables (overridable) | Yes |
| `meta/` | Dependencies, author info | Yes |

---

## Creating a Role Skeleton

```bash
ansible-galaxy init roles/webserver
```
This generates the full folder structure for you.

---

## Example: A `webserver` Role

`roles/webserver/defaults/main.yml`:
```yaml
---
http_port: 80
server_name: "Default Server"
```

`roles/webserver/tasks/main.yml`:
```yaml
---
- name: Install nginx
  apt:
    name: nginx
    state: present
    update_cache: true

- name: Deploy homepage
  template:
    src: index.html.j2
    dest: /var/www/html/index.html
  notify: Restart nginx

- name: Ensure nginx running
  service:
    name: nginx
    state: started
    enabled: true
```

`roles/webserver/handlers/main.yml`:
```yaml
---
- name: Restart nginx
  service:
    name: nginx
    state: restarted
```

`roles/webserver/templates/index.html.j2`:
```html
<h1>{{ server_name }}</h1>
<p>Served on port {{ http_port }}</p>
```

---

## Using a Role in a Playbook

**Simple form:**
```yaml
---
- hosts: web
  become: true
  roles:
    - webserver
```

**With variable overrides:**
```yaml
---
- hosts: web
  become: true
  roles:
    - role: webserver
      vars:
        server_name: "Production Web"
        http_port: 8080
```

**`include_role` (run mid-task, conditionally):**
```yaml
tasks:
  - name: Apply webserver role only to Ubuntu
    include_role:
      name: webserver
    when: ansible_distribution == "Ubuntu"
```

---

## Role Dependencies (`meta/main.yml`)

```yaml
---
dependencies:
  - role: common
  - role: firewall
    vars:
      open_ports: [80, 443]
```
`common` and `firewall` run **before** this role.

---

## Variable Precedence (roles)

From lowest to highest (simplified):
```
role defaults  <  inventory vars  <  play vars  <  role vars  <  -e (extra vars)
```
Put overridable values in `defaults/`, and values you don't want overridden in `vars/`.

---

## Ansible Galaxy (community roles)

```bash
# Install a role from Galaxy
ansible-galaxy install geerlingguy.nginx

# Install from a requirements file
ansible-galaxy install -r requirements.yml
```

`requirements.yml`:
```yaml
roles:
  - name: geerlingguy.nginx
  - name: geerlingguy.postgresql
```

---

## Quick Recap

| Concept | Key point |
|---------|-----------|
| Role | Reusable bundle of tasks/vars/templates |
| `ansible-galaxy init` | Scaffold a role |
| `defaults/` vs `vars/` | Overridable vs high-priority variables |
| `roles:` | Apply roles in a play |
| `meta/main.yml` | Declare role dependencies |
| Ansible Galaxy | Public role repository |
