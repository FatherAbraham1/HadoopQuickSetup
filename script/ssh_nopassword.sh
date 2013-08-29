#!/usr/bin/expect

set host [lindex $argv 0]
set password [lindex $argv 1]
set pubkey [exec cat /root/.ssh/id_rsa.pub]

#spawn ssh-copy-id -i /root/.ssh/id_rsa.pub root@$host
spawn ssh -i /root/.ssh/id_rsa.pub root@$host "
umask 022
mkdir -p  /root/.ssh
echo \'$pubkey\' > /root/.ssh/authorized_keys
"
expect {
timeout {exit 1}
yes/no  {send "yes\r";exp_continue}
-nocase "password:" {send "$password\r"}
}
expect eof
