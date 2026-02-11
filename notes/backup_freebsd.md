# Backup and Restore FreeBSD

## Backup

Prepare a list of installed packages:
`pkg prime-list > pkglist`
Backup your settings and home directory (following is an example, change it to match yours):

```bash
mkdir -p /mnt/backup/ /usr/local
mkdir -p /mnt/backup/ /home
mkdir -p /mnt/backup/ /etc

rsync -a /boot/loader.conf /mnt/backup/boot
rsync -a /etc /mnt/backup/etc
rsync -a /usr/local/etc /mnt/backup/usr/local
rsync -a /home /mnt/backup/home
```

## Restore

Install FreeBSD in the usual way.
Install packages:
`cat pkglist | xargs pkg install`
Restore settings and home directory:

```bash
rsync -a /backup/boot/loader.conf /boot
rsync -a /backup/etc /etc
rsync -a /backup/usr/local/etc /usr/local/etc
rsync -a /backup/home /home
```
