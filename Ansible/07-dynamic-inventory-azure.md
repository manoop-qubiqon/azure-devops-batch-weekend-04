# 7. Dynamic Inventory for Azure Resources

A **static inventory** lists hosts by hand. In the cloud, VMs come and go — so you use a **dynamic inventory** that queries Azure's API and builds the host list automatically at runtime.

---

## Static vs Dynamic

| | Static | Dynamic |
|-|--------|---------|
| Source | Manually written file | Live query to Azure API |
| Updates | You edit it | Automatic |
| Best for | Fixed lab/servers | Autoscaling cloud VMs |

---

## Prerequisites

```bash
# Install the Azure collection
ansible-galaxy collection install azure.azcollection

# Install the required Python SDKs
pip install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements.txt

# Azure CLI (used for auth)
az login
```

### Authentication options
Ansible's Azure plugin authenticates via (in order of common use):
1. **Azure CLI** — just run `az login` (easiest for dev).
2. **Service principal via environment variables:**
```bash
export AZURE_SUBSCRIPTION_ID="xxxx"
export AZURE_CLIENT_ID="xxxx"
export AZURE_SECRET="xxxx"
export AZURE_TENANT="xxxx"
```
3. **Credentials file** `~/.azure/credentials`:
```ini
[default]
subscription_id=xxxx
client_id=xxxx
secret=xxxx
tenant=xxxx
```

---

## The Dynamic Inventory File

The file **must end in** `azure_rm.yml` (or `.azure_rm.yaml`) so the plugin picks it up.

`azure_rm.yml`:
```yaml
plugin: azure.azcollection.azure_rm

# Only include VMs from these resource groups (optional)
include_vm_resource_groups:
  - ansible-demo-rg

auth_source: cli          # use `az login` credentials

# Use the public IP so the control node can SSH in
hostvar_expressions:
  ansible_host: public_ipv4_addresses[0]

# Group hosts automatically by tags and other attributes
keyed_groups:
  - prefix: tag
    key: tags
  - prefix: os
    key: os_disk.operating_system_type
  - prefix: rg
    key: resource_group

# Only include running VMs
conditional_groups:
  running: powerstate == 'running'
```

---

## Testing the Dynamic Inventory

```bash
# List everything the plugin discovers
ansible-inventory -i azure_rm.yml --list

# Human-readable tree
ansible-inventory -i azure_rm.yml --graph

# Ping all discovered Azure VMs
ansible all -i azure_rm.yml -m ping
```

Example `--graph` output:
```
@all:
  |--@tag_role_web:
  |  |--web1_abcd
  |  |--web2_efgh
  |--@rg_ansible_demo_rg:
  |  |--web1_abcd
  |--@running:
  |  |--web1_abcd
```

---

## Using It in a Playbook

Because VMs are auto-grouped by tag, you can target `tag_role_web` (a VM tagged `role: web`):

```yaml
---
- name: Configure Azure web VMs
  hosts: tag_role_web        # group created from the Azure tag
  become: true
  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present
```

```bash
ansible-playbook -i azure_rm.yml site.yml
```

---

## Grouping by Tags (the key idea)

Tag your Azure VMs (in Terraform, ARM, portal, or CLI):
```bash
az vm update -g ansible-demo-rg -n web1 --set tags.role=web
```

Then `keyed_groups` with `prefix: tag` turns `role=web` into the Ansible group **`tag_role_web`**, which you target directly. This is how you map cloud infrastructure to Ansible plays without maintaining a host list.

---

## Common Config Reference

| Key | Purpose |
|-----|---------|
| `plugin` | Must be `azure.azcollection.azure_rm` |
| `include_vm_resource_groups` | Limit to specific RGs |
| `auth_source` | `cli`, `env`, `credential_file`, etc. |
| `keyed_groups` | Auto-create groups from tags/attributes |
| `conditional_groups` | Group by a condition (e.g. running) |
| `hostvar_expressions` | Set `ansible_host` to public/private IP |

---

## Quick Recap

- Dynamic inventory queries Azure live instead of a hand-written host list.
- File must be named `azure_rm.yml` and use the `azure.azcollection.azure_rm` plugin.
- Authenticate via `az login`, env vars, or a credentials file.
- `keyed_groups` turns Azure **tags** into Ansible **groups** (`tag_role_web`).
- Test with `ansible-inventory --graph` before running playbooks.
