# 1. Interface erstellen
ifconfig gre0 create

# 2. Tunnel-Endpunkte setzen (Local und Remote Public IPs)
ifconfig gre0 tunnel 195.201.91.130 154.57.85.10

# 3. IPv4 Adresse im Tunnel setzen (deine Seite .130, Ziel .129)
ifconfig gre0 inet 10.249.7.130 10.249.7.129 netmask 255.255.255.252

# 4. IPv6 Adresse im Tunnel setzen
ifconfig gre0 inet6 2a0c:9a40:a005::33a/126

# 5. Interface aktivieren
ifconfig gre0 up

# 6. IPv6 Alias-Adresse setzen (optional) Test for ping
ifconfig lo0 inet6 2a06:9801:5a::1/128 alias

# 7. IPv6 Adresse für das wireguard routing von :1000::/64 setzen
ifconfig wg0 inet6 2a06:9801:5a:1000::1/64 alias
ifconfig wg0 inet6 2a06:9801:5a:4000::1/64 alias