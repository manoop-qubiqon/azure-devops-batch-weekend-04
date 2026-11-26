# 1. Ansible Architecture

Ansible is an **agentless** configuration management and automation tool. It pushes configuration to servers over SSH — you don't install any agent/daemon on the machines you manage.

---

## Core Components

### Control Node
The machine where Ansible is installed and from which you run commands/playbooks.

- Any Linux/macOS machine (Windows only via WSL).
- Needs Python and Ansible installed.
- Holds your inventory, playbooks, roles, and SSH keys.

```bash
# Install on Ubuntu control node
sudo apt update
sudo apt install -y ansible

# Verify
ansible --version
```

### Managed Nodes (Hosts)
The servers Ansible configures. **No Ansible installed here** — they only need:
- SSH access (usually key-based).
- Python installed (for most modules).

### Inventory
A file listing the managed nodes, optionally grouped. Default location: `/etc/ansible/hosts`, but you normally keep a project-local one.

---

## How It Works (Push Model)

```
                 SSH
Control Node  ───────────►  Managed Node 1
 (Ansible)    ───────────►  Managed Node 2
              ───────────►  Managed Node 3
```

1. You run a playbook on the control node.
2. Ansible connects over SSH to each managed node.
3. It copies small Python modules to the node, executes them, collects results, then removes them.
4. No persistent agent remains.

---

## Inventory Basics

### INI format (`inventory.ini`)
```ini
[web]
web1 ansible_host=10.0.0.11
web2 ansible_host=10.0.0.12

[db]
db1 ansible_host=10.0.0.21

[all:vars]
ansible_user=azureuser
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### YAML format (`inventory.yml`)
```yaml
all:
  children:
    web:
      hosts:
        web1:
          ansible_host: 10.0.0.11
        web2:
          ansible_host: 10.0.0.12
    db:
      hosts:
        db1:
          ansible_host: 10.0.0.21
  vars:
    ansible_user: azureuser
```

---

## Ad-hoc Commands (quick one-offs)

```bash
# Ping all hosts (tests connectivity + Python)
ansible all -i inventory.ini -m ping

# Run a shell command on the 'web' group
ansible web -i inventory.ini -m command -a "uptime"

# Check disk space
ansible all -i inventory.ini -m shell -a "df -h"

# Install a package (needs sudo)
ansible web -i inventory.ini -m apt -a "name=nginx state=present" --become
```

| Flag | Meaning |
|------|---------|
| `-i` | Inventory file |
| `-m` | Module to run |
| `-a` | Arguments to the module |
| `--become` | Run with privilege escalation (sudo) |

---

## Key Config File: `ansible.cfg`

Place in your project root to set defaults so you don't repeat flags.

```ini
[defaults]
inventory = ./inventory.ini
remote_user = azureuser
host_key_checking = False
private_key_file = ~/.ssh/id_rsa

[privilege_escalation]
become = True
become_method = sudo
```

---

## Quick Recap

| Term | Meaning |
|------|---------|
| Control node | Where Ansible runs |
| Managed node | Server being configured (agentless) |
| Inventory | List of hosts and groups |
| Module | Unit of work executed on a host |
| Ad-hoc command | Single task run from CLI |
| Playbook | YAML file of orchestrated tasks |
