# SAMBA ldapsam

## @edt ASIX M06 2018-2019

ASIX M06-ASO EDT

### Imatges:

* **francs2/samba:18ldapsamba** Servidor SAMBA amb backend LDAP *ldapsam*. Requereix de l'us de un 
servidor ldap preparat amb l'schema samba. Les dades dels usuaris samba es desen en els comptes
 d'usuari ldap.

### Arquitectura

Per implementar un host amb usuaris unix i ldap on els homes dels usuaris es muntin via samba de un 
servidor de disc extern caldra la seguent estructura:

  * **sambanet** Una xarxa propia per als containers implicats.

  * **francs2/ldapserver:18samba** Un servidor ldap en funcionament amb els usuaris de xarxa, inclos 
amb els schemas apropiats de samba (agafem una plantilla de schema a internet).

  * **francs2/samba:18ldapsamba** Un servidor samba que utilitza *ldapsam* com a backend.
Exporta els homes dels usuaris com a shares via *[homes]*. Aquest servidor esta configurat per tenir
usuaris locals i usuaris LDAP. Està configurat correctament l'acces al servidor LDAP.
Contindrà:

    1 *Usuaris unix* Samba requereix la existència de usuaris unix. Per tant caldrà disposar dels usuaris unix,
poden ser locals o de xarxa via LDAP. fichers claus nslcd i nsswitch per users ldap.

    2 *homes* Cal que els usuaris tinguin un directori home. Els usuaris unix local ja en tenen en crear-se
l'usuari, pero els usuaris LDAP no. Per tant cal crear el directori home dels usuaris ldap i assignar-li la 
propietat i el grup de l'usuari apropiat. Fen un mkdir i un chown dels diferents usuaris LDAP.

    3 *Usuaris samba* Cal crear els comptes d'usuari samba (recolsats en l'existencia del mateix usuari unix/ldap).
Per a cada usuari samba els pot crear amb *smbpasswd* el compte d'usuasi samba assignant-li el password de samba. 
Aquest es desarà en la base de dades ldap (Convé que sigui el mateix que el de ldap)

  * **francs2/hostpam:18ldapsamba** Un hostpam configurat per accedir als usuaris locals i ldap i que usant pam_mount.so
munta dins del home dels usuaris un home de xarxa via samba (cifs). Cal configurar */etc/security/pam_mount.conf.xml* 
per muntar el recurs samba dels *[homes]*.


#### Execució

```
docker network create sambanet

docker run --rm --name ldap -h ldap --net sambanet -d francs2/ldapserver:18samba

docker run --rm --name samba -h samba --net sambanet -it francs2/samba:18ldapsamba

docker run --rm --name host -h host --net sambanet -it francs2/hostpam:18ldapsamba
```

#### Configuració samba:18ldapsamba

/etc/samba/smb.conf
```
[global]
        workgroup = MYGROUP
        server string = Samba Server Version %v
        log file = /var/log/samba/log.%m
        max log size = 50
        security = user
        passdb backend = ldapsam:ldap://172.21.0.2
          ldap suffix = dc=edt,dc=org
          ldap user suffix = ou=usuaris
          ldap group suffix = ou=grups
          ldap machine suffix = ou=hosts
          ldap idmap suffix = ou=domains
          ldap admin dn = cn=Manager,dc=edt,dc=org
          ldap ssl = no
          ldap passwd sync = yes
        load printers = yes
        cups options = raw
[homes]
        comment = Home Directories
        browseable = no
        writable = yes
;       valid users = %S
;       valid users = MYDOMAIN\%S
[public]
	comment = Public Stuff
	path = /var/lib/samba/public
	read only = No
	guest ok = Yes
```

/etc/smbldap-tools/smbldap_bind.conf  : Establim els passwords apropiats de Ldap
```
# $Id$
#
############################
# Credential Configuration #
############################
# Notes: you can specify two differents configuration if you use a
# master ldap for writing access and a slave ldap server for reading access
# By default, we will use the same DN (so it will work for standard Samba
# release)
slaveDN="cn=Manager,dc=edt,dc=org"
slavePw="secret"
masterDN="cn=Manager,dc=edt,dc=org"
masterPw="secret"
```

/etc/smbldap-tools/smbldap.conf  : establim els noms del DIT 
```
# $Id$
#
# smbldap-tools.conf : Q & D configuration file for smbldap-tools

#  This code was developped by IDEALX (http://IDEALX.org/) and
#  contributors (their names can be found in the CONTRIBUTORS file).
#
#                 Copyright (C) 2001-2002 IDEALX
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
#  USA.

#  Purpose :
#       . be the configuration file for all smbldap-tools scripts

##############################################################################
#
# General Configuration
#
##############################################################################

# Put your own SID. To obtain this number do: "net getlocalsid".
# If not defined, parameter is taking from "net getlocalsid" return
#SID="S-1-5-21-2252255531-4061614174-2474224977"

# Domain name the Samba server is in charged.
# If not defined, parameter is taking from smb.conf configuration file
# Ex: sambaDomain="IDEALX-NT"
#sambaDomain="DOMSMB"

##############################################################################
#
# LDAP Configuration
#
##############################################################################

# Notes: to use to dual ldap servers backend for Samba, you must patch
# Samba with the dual-head patch from IDEALX. If not using this patch
# just use the same server for slaveLDAP and masterLDAP.
# Those two servers declarations can also be used when you have
# . one master LDAP server where all writing operations must be done
# . one slave LDAP server where all reading operations must be done
#   (typically a replication directory)

# Slave LDAP server URI
# Ex: slaveLDAP=ldap://slave.ldap.example.com/
# If not defined, parameter is set to "ldap://127.0.0.1/"
slaveLDAP="ldap://172.19.0.2/"

# Master LDAP server URI: needed for write operations
# Ex: masterLDAP=ldap://master.ldap.example.com/
# If not defined, parameter is set to "ldap://127.0.0.1/"
masterLDAP="ldap://172.19.0.2/"

# Use TLS for LDAP
# If set to 1, this option will use start_tls for connection
# (you must also used the LDAP URI "ldap://...", not "ldaps://...")
# If not defined, parameter is set to "0"
ldapTLS="0"

# How to verify the server's certificate (none, optional or require)
# see "man Net::LDAP" in start_tls section for more details
verify="require"

# CA certificate
# see "man Net::LDAP" in start_tls section for more details
cafile="/etc/pki/tls/certs/ldapserverca.pem"

# certificate to use to connect to the ldap server
# see "man Net::LDAP" in start_tls section for more details
clientcert="/etc/pki/tls/certs/ldapclient.pem"

# key certificate to use to connect to the ldap server
# see "man Net::LDAP" in start_tls section for more details
clientkey="/etc/pki/tls/certs/ldapclientkey.pem"

# LDAP Suffix
# Ex: suffix=dc=IDEALX,dc=ORG
suffix="dc=edt,dc=org"

# Where are stored Users
# Ex: usersdn="ou=Users,dc=IDEALX,dc=ORG"
# Warning: if 'suffix' is not set here, you must set the full dn for usersdn
usersdn="ou=usuaris,${suffix}"

# Where are stored Computers
# Ex: computersdn="ou=Computers,dc=IDEALX,dc=ORG"
# Warning: if 'suffix' is not set here, you must set the full dn for computersdn
computersdn="ou=hosts,${suffix}"

# Where are stored Groups
# Ex: groupsdn="ou=Groups,dc=IDEALX,dc=ORG"
# Warning: if 'suffix' is not set here, you must set the full dn for groupsdn
groupsdn="ou=grups,${suffix}"

# Where are stored Idmap entries (used if samba is a domain member server)
# Ex: idmapdn="ou=Idmap,dc=IDEALX,dc=ORG"
# Warning: if 'suffix' is not set here, you must set the full dn for idmapdn
idmapdn="ou=domains,${suffix}"

# Where to store next uidNumber and gidNumber available for new users and groups
# If not defined, entries are stored in sambaDomainName object.
# Ex: sambaUnixIdPooldn="sambaDomainName=${sambaDomain},${suffix}"
# Ex: sambaUnixIdPooldn="cn=NextFreeUnixId,${suffix}"
sambaUnixIdPooldn="sambaDomainName=${sambaDomain},${suffix}"

# Default scope Used
scope="sub"

# Unix password hash scheme (CRYPT, MD5, SMD5, SSHA, SHA, CLEARTEXT)
# If set to "exop", use LDAPv3 Password Modify (RFC 3062) extended operation.
password_hash="SSHA"

# if password_hash is set to CRYPT, you may set a salt format.
# default is "%s", but many systems will generate MD5 hashed
# passwords if you use "$1$%.8s". This parameter is optional!
password_crypt_salt_format="%s"
```

#### Configuració en el hostpam:18ldapsamba

*/etc/security/pam_mount.conf.xml*
```
<volume user="*" 
		fstype="cifs" 
		server="samba" 
		path="%(USER)"  
		mountpoint="~/%(USER)" />

```

#### Conporvació

En el servidor samba con un user ldap:
```

[root@samba docker]# pdbedit -Lv pere
Unix username:        pere
NT username:          pere
Account Flags:        [U          ]
User SID:             S-1-5-21-3769419288-3997272073-2812519253-1001
Primary Group SID:    S-1-5-21-3769419288-3997272073-2812519253-513
Full Name:            Pere Pou
Home Directory:       \\samba\pere
HomeDir Drive:        
Logon Script:         
Profile Path:         \\samba\pere\profile
Domain:               SAMBA
Account desc:         Watch out for this guy
Workstations:         
Munged dial:          
Logon time:           0
Logoff time:          never
Kickoff time:         never
Password last set:    Sat, 12 Jan 2019 19:25:03 UTC
Password can change:  Sat, 12 Jan 2019 19:25:03 UTC
Password must change: never
Last bad password   : 0
Bad password count  : 0
Logon hours         : FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF



[root@samba docker]# ldapsearch -x -LLL -b 'dc=edt,dc=org' 'uid=pere'
dn: uid=pere,ou=usuaris,dc=edt,dc=org
objectClass: posixAccount
objectClass: inetOrgPerson
objectClass: sambaSamAccount
cn: Pere Pou
sn: Pou
homePhone: 555-222-2221
mail: pere@edt.org
description: Watch out for this guy
ou: Profes
uid: pere
uidNumber: 5001
gidNumber: 100
homeDirectory: /tmp/home/pere
sambaSID: S-1-5-21-3769419288-3997272073-2812519253-1001
displayName: Pere Pou
userPassword:: e1NTSEF9N2xDOHV1MnVwQzB2SHpQYlhNc3RRU1VobXFFQ0hEN1o=
sambaNTPassword: 394248C9B811DB06DA043F2455B0A4BD
sambaPasswordHistory: 00000000000000000000000000000000000000000000000000000000
 00000000
sambaPwdLastSet: 1547321103
sambaAcctFlags: [U        
```

En un host client: 

```
[root@host docker]# smbtree -L
MYGROUP
	\\SAMBA          		Samba Server Version 4.7.10
		\\SAMBA\IPC$           	IPC Service (Samba Server Version 4.7.10)
		\\SAMBA\public         	Public Stuff


[root@host docker]# su - local02
[local02@host ~]$ pwd
/home/local02


[local02@host ~]$ su - pere
pam_mount password:
[pere@host ~]$ ll
total 0
drwxr-xr-x 2 pere users 0 Jan 12 19:25 pere
[pere@host ~]$ mount -t cifs
//samba/pere on /tmp/home/pere/pere type cifs (rw,relatime,vers=default,cache=strict,username=pere,domain=,uid=5001,forceuid,gid=100,forcegid,addr=172.19.0.3,file_mode=0755,dir_mode=0755,soft,nounix,serverino,mapposix,rsize=1048576,wsize=1048576,echo_interval=60,actimeo=1)


[root@host docker]# smbclient //SAMBA/public -U pere%pere
Try "help" to get a list of possible commands.
smb: \> ls
  .                                   D        0  Sat Jan 12 19:25:02 2019
  ..                                  D        0  Sat Jan 12 19:25:47 2019
  INFO.txt                            N       54  Sat Jan 12 19:25:02 2019
  Dockerfile                          N      469  Sat Jan 12 19:25:02 2019
  smbldap_bind.conf                   N      430  Sat Jan 12 19:25:02 2019
  startup.sh                          A      305  Sat Jan 12 19:25:02 2019
  smb.conf                            N      867  Sat Jan 12 19:25:02 2019
  nsswitch.conf                       N     1731  Sat Jan 12 19:25:02 2019
  populate.ldif                       N    19046  Sat Jan 12 19:25:02 2019
  ldap.conf                           N      311  Sat Jan 12 19:25:02 2019
  nslcd.conf                          N     4831  Sat Jan 12 19:25:02 2019
  install.sh                          A     2612  Sat Jan 12 19:25:02 2019
  smbldap.conf                        N     7803  Sat Jan 12 19:25:02 2019
  README.md                           N     9738  Sat Jan 12 19:25:02 2019

		656411128 blocks of size 1024. 591143560 blocks available
smb: \> 

```
