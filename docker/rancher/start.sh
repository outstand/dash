#!/bin/bash

INSTANCE_IP=$(ip -o -4 -br addr show eth0 | awk '{print $3}' | cut -d/ -f1)
iptables -t nat -A PREROUTING -p tcp -d 127.0.0.1 --dport 8400 -j DNAT --to ${INSTANCE_IP}
iptables -t nat -A PREROUTING -p tcp -d 127.0.0.1 --dport 8500 -j DNAT --to ${INSTANCE_IP}
iptables -t nat -A OUTPUT -o lo -p tcp -m tcp --dport 8400 -j DNAT --to ${INSTANCE_IP}
iptables -t nat -A OUTPUT -o lo -p tcp -m tcp --dport 8500 -j DNAT --to ${INSTANCE_IP}

# mkdir /Users
# mount --bind /Users /Users
# mount --make-shared /Users
mkdir -p /usr/src

cat > /etc/ssh/sshd_config <<EOM
AuthorizedKeysFile .ssh/authorized_keys
Subsystem sftp /usr/libexec/sftp-server
UseDNS no
PermitRootLogin no
AllowGroups docker

# We include dh-sha1 here for fsevents
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha1
Protocol 2
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key
PasswordAuthentication no
ChallengeResponseAuthentication no
PubkeyAuthentication yes
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-ripemd160-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,hmac-ripemd160,umac-128@openssh.com
EOM
