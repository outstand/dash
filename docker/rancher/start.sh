#!/bin/bash

iptables -I DOCKER-USER -i dns -j ACCEPT
iptables -I DOCKER-USER -o dns -j ACCEPT

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
# Include rsa host key for fsevents
HostKey /etc/ssh/ssh_host_rsa_key

PasswordAuthentication no
ChallengeResponseAuthentication no
PubkeyAuthentication yes
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com
EOM
