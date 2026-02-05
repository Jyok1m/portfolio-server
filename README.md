# Portfolio-server

## Tutorial Ansible:

### Create vault:
```
EDITOR=nano ansible-vault create group_vars/all/vault.yml
```

### Edit vault:
```
EDITOR=nano ansible-vault edit group_vars/all/vault.yml
```

### Vault structure:
```
vault_server_host: <server_ip>
vault_server_port: <port>
vault_server_user: <user>
vault_ssh_key_path: <ssh_file_path>
```

### Test connection:
```
ansible ovh-server -i inventory.yml -m ping --ask-vault-pass
```

### Result example:
```
ovh-server | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.13"
    },
    "changed": false,
    "ping": "pong"
}
```

## Playbooks:

### Hardening:

Playbook for server securing + ssh hardening : `./ansible/hardening.yml`

```
ansible-playbook hardening.yml -i inventory.yml --ask-vault-pass
```