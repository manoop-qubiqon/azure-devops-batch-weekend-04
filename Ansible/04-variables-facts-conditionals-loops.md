# 4. Variables, Facts, Conditionals, Loops

These give playbooks their flexibility — reusing logic across hosts, environments, and lists of items.

---

## Variables

### Defining variables

**In a playbook:**
```yaml
- hosts: web
  vars:
    http_port: 80
    app_name: myapp
  tasks:
    - name: Show the port
      debug:
        msg: "App {{ app_name }} runs on port {{ http_port }}"
```

**In a separate vars file:**
```yaml
# vars/main.yml
http_port: 80
app_name: myapp
```
```yaml
- hosts: web
  vars_files:
    - vars/main.yml
```

**In the inventory:**
```ini
[web:vars]
http_port=8080
```

**On the command line (`-e`, highest priority):**
```bash
ansible-playbook site.yml -e "http_port=9090"
```

### Using variables — Jinja2 `{{ }}`
```yaml
- name: Create app directory
  file:
    path: "/opt/{{ app_name }}"
    state: directory
```

> Quote the value when it **starts** with `{{ }}`, e.g. `path: "{{ mypath }}"`.

### Registering output into a variable
```yaml
- name: Check nginx status
  command: systemctl is-active nginx
  register: nginx_status

- name: Print it
  debug:
    var: nginx_status.stdout
```

---

## Facts

Facts are **automatically discovered** details about each host (OS, IP, memory, CPU...). Gathered at the start of a play.

```yaml
- hosts: all
  tasks:
    - name: Show OS family and IP
      debug:
        msg: "{{ ansible_facts['distribution'] }} - {{ ansible_default_ipv4.address }}"
```

See all facts for a host:
```bash
ansible web1 -i inventory.ini -m setup
# Filter:
ansible web1 -i inventory.ini -m setup -a "filter=ansible_distribution*"
```

Common facts:

| Fact | Example |
|------|---------|
| `ansible_facts['distribution']` | `Ubuntu` |
| `ansible_facts['distribution_version']` | `22.04` |
| `ansible_default_ipv4.address` | `10.0.0.11` |
| `ansible_hostname` | `web1` |
| `ansible_processor_vcpus` | `2` |
| `ansible_memtotal_mb` | `3934` |

Speed up plays by disabling fact gathering when not needed:
```yaml
- hosts: web
  gather_facts: false
```

---

## Conditionals — `when`

Run a task only if a condition is true.

```yaml
- name: Install apache on Debian family
  apt:
    name: apache2
    state: present
  when: ansible_facts['os_family'] == "Debian"

- name: Install httpd on RedHat family
  yum:
    name: httpd
    state: present
  when: ansible_facts['os_family'] == "RedHat"
```

### Multiple conditions
```yaml
# AND (list = all must be true)
when:
  - ansible_distribution == "Ubuntu"
  - ansible_distribution_major_version == "22"

# OR
when: ansible_distribution == "Ubuntu" or ansible_distribution == "Debian"
```

### Based on a registered variable
```yaml
- name: Check if file exists
  stat:
    path: /etc/myapp.conf
  register: cfg

- name: Create it only if missing
  copy:
    content: "default config"
    dest: /etc/myapp.conf
  when: not cfg.stat.exists
```

---

## Loops

### Simple loop
```yaml
- name: Install several packages
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - git
    - curl
    - htop
```

### Loop over a list variable
```yaml
vars:
  users:
    - alice
    - bob
tasks:
  - name: Create users
    user:
      name: "{{ item }}"
      state: present
    loop: "{{ users }}"
```

### Loop over dictionaries
```yaml
- name: Create users with groups
  user:
    name: "{{ item.name }}"
    groups: "{{ item.group }}"
  loop:
    - { name: 'alice', group: 'admin' }
    - { name: 'bob',   group: 'devs'  }
```

### Loop with condition
```yaml
- name: Print only even numbers
  debug:
    msg: "{{ item }}"
  loop: [1, 2, 3, 4, 5, 6]
  when: item % 2 == 0
```

---

## Quick Recap

| Feature | Purpose | Key syntax |
|---------|---------|-----------|
| Variables | Reusable values | `vars:`, `{{ var }}`, `-e` |
| `register` | Capture task output | `register: result` |
| Facts | Auto host info | `ansible_facts[...]`, `setup` module |
| `when` | Conditional execution | `when: condition` |
| `loop` | Repeat a task | `loop:` with `{{ item }}` |
