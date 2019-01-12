#! /bin/bash
# @edt ASIX M06 2018-2019
# instal.lacio de users en el server samba
# -------------------------------------

# Primera part cream usuaris i groups del mateix container del host:pam
groupadd localgrp01
groupadd localgrp02
useradd -g users -G localgrp01 local01
useradd -g users -G localgrp01 local02
useradd -g users -G localgrp01 local03
useradd -g users -G localgrp02 local04
useradd -g users -G localgrp02 local05
useradd -g users -G localgrp02 local06
echo "local01" | passwd --stdin local01
echo "local02" | passwd --stdin local02
echo "local03" | passwd --stdin local03
echo "local04" | passwd --stdin local04
echo "local05" | passwd --stdin local05
echo "local06" | passwd --stdin local06

cp /opt/docker/nslcd.conf /etc/nslcd.conf
cp /opt/docker/ldap.conf /etc/openldap/ldap.conf
cp /opt/docker/nsswitch.conf /etc/nsswitch.conf
cp /opt/docker/smb.conf  /etc/samba/smb.conf

/usr/sbin/nslcd && echo "nslcd Ok"
/usr/sbin/nscd && echo "nscd Ok"

mkdir /tmp/home
mkdir /tmp/home/pere
mkdir /tmp/home/pau
mkdir /tmp/home/anna
mkdir /tmp/home/marta
mkdir /tmp/home/jordi
mkdir /tmp/home/admin

cp INFO.txt /tmp/home/pere
cp INFO.txt /tmp/home/pau
cp INFO.txt /tmp/home/anna
cp INFO.txt /tmp/home/marta
cp INFO.txt /tmp/home/jordi
cp INFO.txt /tmp/home/admin

cp INFO.txt /home/local01
cp INFO.txt /home/local02
cp INFO.txt /home/local03


chown -R pere.users /tmp/home/pere
chown -R pau.users /tmp/home/pau
chown -R anna.alumnes /tmp/home/anna
chown -R marta.alumnes /tmp/home/marta
chown -R jordi.users /tmp/home/jordi
chown -R admin.wheel /tmp/home/admin
#------------------------------------------------------

mkdir /var/lib/samba/public
chmod 777 /var/lib/samba/public
cp /opt/docker/* /var/lib/samba/public/.
mkdir /var/lib/samba/privat
cp /opt/docker/smb.conf /etc/samba/smb.conf
cp /opt/docker/*.md /var/lib/samba/privat/.

# -----------------------------------------------------------
cp /opt/docker/smbldap.conf /etc/smbldap-tools/.
cp /opt/docker/smbldap_bind.conf /etc/smbldap-tools/.

smbpasswd -w secret
net getlocalsid
net getdomainsid

echo -e "jupiter\njupiter" | smbldap-populate
pdbedit -L
ldapsearch -x -LLL



echo -e "pere\npere" | smbpasswd -a pere
echo -e "pau\npau" | smbpasswd -a pau
echo -e "anna\nanna" | smbpasswd -a anna
echo -e "marta\nmarta" | smbpasswd -a marta
echo -e "jordi\njordi" | smbpasswd -a jordi
echo -e "admin\nadmin" | smbpasswd -a admin

echo -e "local01\nlocal01" | smbpasswd -a local01
echo -e "local02\nlocal02" | smbpasswd -a local02
echo -e "local03\nlocal03" | smbpasswd -a local03

ldapsearch -x -LLL -b 'dc=edt,dc=org' 'uid=pere'
pdbedit -L


