#!/bin/bash -eux

# call ssh_option with parameters: $1=name $2=value $3=file
function ssh_option() {
    name=${1//\//\\/}
    value=${2//\//\\/}
    sed -i \
        -e '/^#\?\(\s*'"${name}"'\s* \s*\).*/{s//\1'"${value}"'/;:a;n;ba;q}' \
        -e '$a'"${name}"' '"${value}" "$3"
}

printf "Harden the SSHD Configuration.\n"

# shellcheck disable=SC1091
. "/etc/os-release"

# Tweak sshd to prevent reverse DNS lookups which speeds up the login process.
ssh_option UseDNS no /etc/ssh/sshd_config
# Disallow password authentication
ssh_option PasswordAuthentication no /etc/ssh/sshd_config
# Disable root login via SSH by default.
ssh_option PermitRootLogin no /etc/ssh/sshd_config
# Disable ssh tunneling via tun device.
ssh_option PermitTunnel no /etc/ssh/sshd_config
# Allow tcp forwarding
ssh_option AllowTcpForwarding yes /etc/ssh/sshd_config
# Disallow X11 Forwarding
ssh_option X11Forwarding no /etc/ssh/sshd_config

# This option will also disable DNS lookups.
printf "\nOPTIONS=\"-u0\"\n\n" >>/etc/sysconfig/sshd

# We want our sshd host keys to be stronger than the default value. This will force sshd to
# use a stronger entropy source. It requires an entropy daemon like haveged or connections
# will experience massive delays while they wait for the kernel to collect enough entropy.
# It will also ensure we only generate ssh protocol version 2 RSA host keys.
#sed --in-place "s/SSH_USE_STRONG_RNG=0/SSH_USE_STRONG_RNG=1024/g" /etc/sysconfig/sshd
sed --in-place "s/# AUTOCREATE_SERVER_KEYS=\"\"/AUTOCREATE_SERVER_KEYS=\"RSA\"/g" /etc/sysconfig/sshd

if [ "${VERSION_ID}" -eq 7 ]; then
    # This will update the init script so when it goes to autogenerate the host keys, they are
    # 4096 bits, instead of the default.
    sed --in-place "s/\\-t rsa /\-t rsa -b 4096 /g" /usr/sbin/sshd-keygen

    # Remove the file exist test from the sshd-keygen.service
    sed --in-place -e "/ConditionFileNotEmpty=|\!\/etc\/ssh\/ssh_host_ecdsa_key/d" /usr/lib/systemd/system/sshd-keygen.service
    sed --in-place -e "/ConditionFileNotEmpty=|\!\/etc\/ssh\/ssh_host_ed25519_key/d" /usr/lib/systemd/system/sshd-keygen.service
fi

# We uncomment the RSA host key path in the sshd config to avoid complaints about the missing DSA host key.
sed --in-place "s/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/g" /etc/ssh/sshd_config
sed --in-place "s/HostKey \/etc\/ssh\/ssh_host_ed25519_key/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/g" /etc/ssh/sshd_config

## Set ServerAliveInterval and ClientAliveInterval to prevent SSH
## disconnections. The pattern match is tuned to each source config file.
## The $'...' quoting syntax tells the shell to expand escape characters.
sed --in-place -e $'/^\tServerAliveInterval/d' /etc/ssh/ssh_config
sed --in-place -e $'/^Host \\*$/a \\\tServerAliveInterval 420' /etc/ssh/ssh_config
sed --in-place -e $'/^Host \\*$/a \\\tTunnel no' /etc/ssh/ssh_config
sed --in-place -e $'/^Host \\*$/a \\\tCiphers aes128-ctr,aes192-ctr,aes256-ctr,arcfour256,aes128-cbc,3des-cbc' /etc/ssh/ssh_config
sed --in-place -e $'/^Host \\*$/a \\\tStrictHostKeyChecking no' /etc/ssh/ssh_config
sed --in-place -e $'/^Host \\*$/a \\\tHostBasedAuthentication no' /etc/ssh/ssh_config
sed --in-place -e $'/^Host \\*$/a \\\tForwardX11 no' /etc/ssh/ssh_config
sed --in-place -e $'/^Host \\*$/a \\\tForwardAgent no' /etc/ssh/ssh_config
sed --in-place -e $'/^Host \\*$/a \\\tProtocol 2' /etc/ssh/ssh_config
sed --in-place -e '/ClientAliveInterval/s/^.*/ClientAliveInterval 420/' /etc/ssh/sshd_config
