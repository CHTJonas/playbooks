# xJupiter Ansible Playbooks

## Editing configuration

```
$ ansible-vault edit vars/vault.yml
$ ansible-vault edit group_vars/*.yml
$ ansible-vault edit host_vars/*.yml
```

## Dry run

```
$ ansible-playbook xjupiter.yml --check
$ ansible-playbook xjupiter.yml --check --diff --limit strephon
```

## Wet run

```
$ ansible-playbook xjupiter.yml
$ ansible-playbook xjupiter.yml --limit strephon
```
