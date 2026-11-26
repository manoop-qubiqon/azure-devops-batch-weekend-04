# 6. Ansible Vault

Ansible Vault **encrypts sensitive data** — passwords, API keys, certificates, private keys — so you can safely store secrets in version control alongside your playbooks.

---

## What Can Be Encrypted?

- Whole files (e.g. `vars/secrets.yml`).
- Individual variable values inside an otherwise plaintext file.

Encrypted content is AES256 and looks like this:
```
$ANSIBLE_VAULT;1.1;AES256
66386439653236336462...
```

---

## Encrypting a File

```bash
# Create a new encrypted file (opens editor)
ansible-vault create secrets.yml

# Encrypt an existing plaintext file
ansible-vault encrypt vars/secrets.yml

# View without decrypting to disk
ansible-vault view secrets.yml

# Edit in place (decrypts in memory)
ansible-vault edit secrets.yml

# Decrypt back to plaintext (careful!)
ansible-vault decrypt secrets.yml

# Change the password
ansible-vault rekey secrets.yml
```

Example `secrets.yml` (before encryption):
```yaml
db_password: "S3cr3tP@ss"
api_key: "abcd-1234-efgh-5678"
```

---

## Using Encrypted Files in a Playbook

```yaml
---
- hosts: db
  become: true
  vars_files:
    - vars/secrets.yml      # can be vault-encrypted
  tasks:
    - name: Set DB password
      debug:
        msg: "Using password {{ db_password }}"
```

Run it and supply the vault password:
```bash
# Prompt for the password interactively
ansible-playbook site.yml --ask-vault-pass

# Or read it from a file
ansible-playbook site.yml --vault-password-file ~/.vault_pass.txt
```

---

## Encrypting a Single Variable (inline)

Keep most of the file readable, encrypt just one value:

```bash
ansible-vault encrypt_string 'S3cr3tP@ss' --name 'db_password'
```

Output to paste into a vars file:
```yaml
db_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          39623866363...
          65643933...
```

---

## Vault Password File

Instead of typing the password each time:
```bash
echo "my-vault-password" > ~/.vault_pass.txt
chmod 600 ~/.vault_pass.txt
```

Point `ansible.cfg` at it so you never pass the flag:
```ini
[defaults]
vault_password_file = ~/.vault_pass.txt
```

> Never commit the password file itself. Add it to `.gitignore`.

---

## Multiple Vault IDs (different secrets, different passwords)

```bash
# Encrypt with a labeled vault id
ansible-vault encrypt --vault-id prod@prompt prod-secrets.yml
ansible-vault encrypt --vault-id dev@prompt dev-secrets.yml

# Run with both available
ansible-playbook site.yml \
  --vault-id dev@~/.vault_dev.txt \
  --vault-id prod@~/.vault_prod.txt
```

---

## Best Practices

| Do | Don't |
|----|-------|
| Encrypt only files/vars with real secrets | Encrypt entire playbooks (hard to review) |
| Keep secret vars in a dedicated `secrets.yml` | Mix secrets and normal config |
| Use a `vault_password_file` outside the repo | Commit the vault password |
| Add password files to `.gitignore` | Store plaintext secrets in git |
| Use inline `encrypt_string` for one-off values | Hardcode passwords in tasks |

---

## Quick Recap

| Command | Purpose |
|---------|---------|
| `ansible-vault create` | New encrypted file |
| `ansible-vault encrypt` | Encrypt existing file |
| `ansible-vault view` | Read without decrypting to disk |
| `ansible-vault edit` | Edit encrypted file |
| `ansible-vault rekey` | Change password |
| `ansible-vault encrypt_string` | Encrypt a single value |
| `--ask-vault-pass` / `--vault-password-file` | Supply password at runtime |
