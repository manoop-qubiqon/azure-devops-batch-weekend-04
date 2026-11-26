# Project: Spin Up 3 Ubuntu Instances & Configure with Ansible

A complete hands-on project that:

1. **Provisions 3 Ubuntu 22.04 VMs on Azure** using Terraform.
2. **Configures them with Ansible** — 2 web servers (nginx + custom page) and 1 load balancer (nginx reverse proxy / round-robin) — using **roles**, **handlers**, **templates**, **variables**, **conditionals**, **loops**, and **Vault**.
3. Uses **Azure dynamic inventory** so Ansible discovers the VMs by tag.

> This exercises every topic in the notes: architecture, playbooks/plays/tasks/handlers, modules, variables/facts/conditionals/loops, roles, vault, and dynamic inventory.

---

## Architecture

```
                       ┌────────────────┐
        Internet  ───► │  lb  (nginx)   │  round-robins to:
                       │  tag: role=lb  │
                       └───────┬────────┘
                       ┌───────┴────────┐
              ┌────────▼──────┐  ┌──────▼────────┐
              │ web1 (nginx)  │  │ web2 (nginx)  │
              │ tag: role=web │  │ tag: role=web │
              └───────────────┘  └───────────────┘
```

---

## Folder Structure

```
project/
├── README.md
├── terraform/
│   ├── main.tf              # 3 Ubuntu VMs, VNet, NSG, public IPs
│   ├── variables.tf
│   └── outputs.tf
├── ansible.cfg
├── azure_rm.yml             # dynamic inventory (queries Azure)
├── inventory.ini            # OPTIONAL static fallback (edit IPs)
├── site.yml                 # main playbook
├── group_vars/
│   └── all.yml
├── vars/
│   └── secrets.yml          # encrypt with ansible-vault
└── roles/
    ├── common/              # base packages, users, updates
    │   ├── tasks/main.yml
    │   └── defaults/main.yml
    ├── webserver/           # nginx + templated homepage
    │   ├── tasks/main.yml
    │   ├── handlers/main.yml
    │   ├── templates/index.html.j2
    │   └── defaults/main.yml
    └── loadbalancer/        # nginx reverse proxy over the web nodes
        ├── tasks/main.yml
        ├── handlers/main.yml
        ├── templates/lb.conf.j2
        └── defaults/main.yml
```

---

## Prerequisites (on your control node)

```bash
# Ansible + Azure collection
sudo apt update && sudo apt install -y ansible
ansible-galaxy collection install azure.azcollection
pip install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements.txt

# Terraform + Azure CLI
az login
terraform -version   # install if missing

# SSH key (used by both Terraform and Ansible)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

---

## Step 1 — Provision 3 VMs with Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

This creates `web1`, `web2` (tag `role=web`) and `lb` (tag `role=lb`), all Ubuntu 22.04, each with a public IP. Note the outputs:

```bash
terraform output
```

---

## Step 2 — Encrypt secrets with Vault

```bash
cd ..
ansible-vault encrypt vars/secrets.yml
# set and remember a vault password
```

(You can inspect the plaintext version in `vars/secrets.yml` before encrypting.)

---

## Step 3 — Confirm dynamic inventory sees the VMs

```bash
ansible-inventory -i azure_rm.yml --graph
ansible all -i azure_rm.yml -m ping
```

You should see groups like `tag_role_web` and `tag_role_lb`.

> **No Azure?** Use the static `inventory.ini` instead — paste the public IPs from `terraform output` — and swap `-i azure_rm.yml` for `-i inventory.ini` in the commands below.

---

## Step 4 — Run the playbook

```bash
ansible-playbook -i azure_rm.yml site.yml --ask-vault-pass
```

What happens:
- **common** role runs on all 3 (updates, base packages, a deploy user).
- **webserver** role runs on `tag_role_web` (installs nginx, deploys a templated page showing the hostname).
- **loadbalancer** role runs on `tag_role_lb` (nginx reverse proxy pointing at both web nodes).

---

## Step 5 — Test

```bash
# Get the LB public IP
terraform -chdir=terraform output lb_public_ip

# Hit it repeatedly — responses alternate between web1 and web2
for i in $(seq 1 6); do curl -s http://<LB_PUBLIC_IP> | grep Served; done
```

You'll see the served hostname flip between `web1` and `web2` — proof the LB is round-robining.

---

## Step 6 — Verify idempotency

Run the playbook again:
```bash
ansible-playbook -i azure_rm.yml site.yml --ask-vault-pass
```
The recap should show `changed=0` for already-configured tasks.

---

## Step 7 — Tear down (avoid charges!)

```bash
cd terraform
terraform destroy -auto-approve
```

---

## Topic-to-File Map (for revision)

| Topic | Where it's demonstrated |
|-------|------------------------|
| Architecture / inventory | `azure_rm.yml`, `inventory.ini`, `ansible.cfg` |
| Playbooks/plays/tasks/handlers | `site.yml`, each role's `handlers/main.yml` |
| Modules (apt, service, copy, template, file) | all role `tasks/main.yml` |
| Variables & facts | `group_vars/all.yml`, `{{ ansible_hostname }}` in templates |
| Conditionals (`when`) | `roles/common/tasks/main.yml` |
| Loops | `roles/common/tasks/main.yml` (packages, users) |
| Roles | entire `roles/` tree |
| Vault | `vars/secrets.yml` + `--ask-vault-pass` |
| Dynamic inventory | `azure_rm.yml` + `tag_role_web` targeting |
