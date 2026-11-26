# 2. Playbooks, Plays, Tasks, Handlers

A **playbook** is a YAML file that describes the desired state of your systems. It's the heart of Ansible automation.

---

## The Hierarchy

```
Playbook  (a .yml file)
 └── Play      (maps a group of hosts to a set of tasks)
      ├── Task     (calls one module — the actual unit of work)
      ├── Task
      └── Handler  (special task triggered only on change)
```

- **Playbook** = the whole file, one or more plays.
- **Play** = "run these tasks on these hosts."
- **Task** = a single action (install a package, copy a file...).
- **Handler** = a task that runs only when notified by another task.

---

## A Complete Example

`site.yml`:
```yaml
---
- name: Configure web servers          # this is a PLAY
  hosts: web
  become: true                         # use sudo for the whole play

  tasks:
    - name: Install nginx              # TASK 1
      apt:
        name: nginx
        state: present
        update_cache: true

    - name: Copy custom index page     # TASK 2
      copy:
        src: files/index.html
        dest: /var/www/html/index.html
      notify: Restart nginx            # triggers the handler if this changes

    - name: Ensure nginx is running    # TASK 3
      service:
        name: nginx
        state: started
        enabled: true

  handlers:
    - name: Restart nginx              # HANDLER
      service:
        name: nginx
        state: restarted
```

Run it:
```bash
ansible-playbook -i inventory.ini site.yml
```

---

## Understanding Handlers

Handlers exist to avoid unnecessary restarts.

- A handler runs **only if** a task with `notify` reports a **change**.
- Handlers run **once**, at the **end** of the play, even if notified many times.
- The `notify` value must exactly match the handler's `name`.

```yaml
tasks:
  - name: Deploy nginx config
    template:
      src: nginx.conf.j2
      dest: /etc/nginx/nginx.conf
    notify: Restart nginx        # only restarts when the file actually changes

handlers:
  - name: Restart nginx
    service:
      name: nginx
      state: restarted
```

If the config is already correct, nothing changes → no restart. That's **idempotency**.

---

## Idempotency (Important Concept)

Running the same playbook twice should produce the same result. On the second run Ansible reports `ok` instead of `changed` because the system is already in the desired state.

```
PLAY RECAP
web1 : ok=3  changed=0  unreachable=0  failed=0
```

---

## Multiple Plays in One Playbook

```yaml
---
- name: Configure web tier
  hosts: web
  become: true
  tasks:
    - name: Install nginx
      apt: { name: nginx, state: present }

- name: Configure database tier
  hosts: db
  become: true
  tasks:
    - name: Install PostgreSQL
      apt: { name: postgresql, state: present }
```

---

## Useful Playbook Run Flags

```bash
# Dry run — show what WOULD change, change nothing
ansible-playbook site.yml --check

# Show diffs of file changes
ansible-playbook site.yml --diff

# Limit to specific hosts
ansible-playbook site.yml --limit web1

# Start at a specific task
ansible-playbook site.yml --start-at-task "Install nginx"

# Increase verbosity for debugging
ansible-playbook site.yml -vvv

# Prompt for sudo password
ansible-playbook site.yml --ask-become-pass
```

---

## Quick Recap

| Term | Role |
|------|------|
| Playbook | Full YAML automation file |
| Play | Maps hosts → tasks |
| Task | One module call |
| Handler | Runs only when notified by a change |
| `notify` | Links a task to a handler |
| Idempotency | Re-running yields the same state |
