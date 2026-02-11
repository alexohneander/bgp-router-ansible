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
                      AS209735 (Lagrange)
                              │ 
                        Direct peering
                              │
                ┌─────────────┴────────────────┐
                │    bgp-router (BGP Router)   │
                │    FreeBSD + FRR             │
                │    AS20XXXX                  │
                │    2a06:9801:5a::/48         │
                └──────┬──────────────┬────────┘
                       │              │
                    GIF tunnel     GIF tunnel
                    (proto 41)     (proto 41)
                       │              │
                ┌──────┴─────┐   ┌────┴────────┐
                │ fsn1       │   │ ksb1        │
                │ Proxmox    │   │ Proxmox     │
                │ :1000::/64 │   │ :2000::/64  │
                └────────────┘   └─────────────┘
```