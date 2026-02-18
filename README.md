# BGP Router Installation

## Action

```bash
ansible-playbook -i hosts site.yml --ask-vault-pass
```

## Architecture Overview

```text
                ┌──────────────────────────────┐
                │     Default-Free Zone        │
                └─────────────┬────────────────┘
                              │
                        AS209533 (iFog)
                              │ 
                           GRE Tunnel
                              │
                ┌─────────────┴────────────────┐
                │    bgp-router (BGP Router)   │
                │    FreeBSD + BIRD            │
                │    AS201033                  │
                │    2a06:9801:5a::/48         │
                └──────┬──────────────┬────────┘
                       │              │
                   Wireguard      Wireguard
                       │              │
                ┌──────┴─────┐   ┌────┴────────┐
                │ fsn1       │   │ ksb1        │
                │ Proxmox    │   │ Proxmox     │
                │ :1000::/64 │   │ :2000::/64  │
                └────────────┘   └─────────────┘
```
