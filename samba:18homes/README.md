# Practica samba server
## @edt ASIX M06 Franlin C. 20/12/2018

Creacio de un servidor samba que es conecta a un servidor ldap , i que a mes funciona com a servidor per
que altres host fora del server local , puguin montar un homes tant de usuaris locals de el servidor com de 
els usuaris del ldap. 
Es dira samba:18homes

### Reposistoris utilitzats:
* Totes aquestes imatges estan totes juntas en una xarxa propia creat amb dokcer .

       **$docker create network sambanet** 

* **ldapserver:18group** : Servidor ldap que tenim creat amb usuaris ldap y que cada un de ells pertany a diferents grups. 

* **samba:18homes** : Servidor SAMBA amb usuaris locals i usuaris LDAP unix, es crearan usuaris locals i alguns usuaris de LDAP.
Es crearan tambe els homes de aquest usuaris ldap i le tindrem que posar els permisos al cual pertany cada user.

    * **Exemple:**

        ```
        mkdir /tmp/home/pere
  
        chown -R pere.users /tmp/home/pere

        echo -e "pere\npere" | smbpasswd -a pere
        ```

* **hostpam:18samba** :  Farem servir la base de un que ja tenia, aquest contenidor funcionar com host fora del servei samba i ldap , llavors verificarem que pot fer mount dels usuaris locals del servei samba i dels usuaris ldap. El archiu clau de mudificaio es el **pam_mount.conf.xml** , pero abans tenin que instalar el paquet **cifs-utils**.


### Configuracio de samba:18homes

* Agafem la base de hostpam:auth per poder conectar amb getent al servidor ldap els serveis que caldrian seria el nslcd,ncd,nsswitch i ldap , el auth no cal en aquest contenidor. Per a fer que funcione com a servidor tenim que instalar els seguents paquets: cifs-utils , samba i samba-client.

* Despres de instalats tots els paquets necesaris modifiquem el smb.conf posant la deficio de homes pertinents:

```
[global]
        workgroup = MYGROUP
        server string = Samba Server Version %v
        log file = /var/log/samba/log.%m
        max log size = 50
        security = user
        passdb backend = tdbsam
        load printers = yes
        cups options = rawecho -e "pere\npere" | smbpasswd -a pere

[homes]
        comment = Home Directories
        browseable = no
        writable = yes
;       valid users = %S
;       valid users = MYDOMAIN\%S


```
* Ordres per provar que comunica amb el servei LDAP:
    ** $getent passwd **

* Fora del contenidor provem que tambe es pot comunicar amb el servei SAMBA: ** $smbclient -U pere //SAMBA/pere**. o muntar-ho:  ** $ mount -t cifs //IP/pere /mnt/ -o user=pere,password=pere**

### Configuracio del hostpam:18samba

* Configurem clau del hostpam:  **pam_mount.conf.xml**

```
    <volume user="*" fstype="cifs" server="samba" path="%(USER)"  mountpoint="~/%(USER)" />

```


#### Execució dels tres containers que necesitarem

* **SERVER LDAP: ldapserver:18group**

```
    $ docker run --rm --name ldap -h ldap --network sambanet -it francs2/ldapserver:18group

```

* **SERVER SAMBA: samba:18homes**

```
    $ docker run --rm --privileged --name samba -h samba --network sambanet -it francs2/samba:18homes

```

* **HOST PAM : hostpam:18samba**

```
    $ docker run --rm --privileged --name host -h host --network sambanet -it francs2/hostpam:18samba

```

#### Comprovar que funciona desde el hostpam:samba :

	```
	
	[root@host docker]# su - pere
	reenter password for pam_mount:
	[pere@host ~]$ pwd
	/tmp/home/pere
	[pere@host ~]$ ll
	total 0
	drwxr-xr-x 2 pere users 0 Jan  7 19:14 pere
	[pere@host ~]$ mount -t cifs
	//samba/pere on /tmp/home/pere/pere type cifs (rw,relatime,vers=default,cache=strict,username=pere,domain=,uid=5001,forceuid,gid=100,forcegid,addr=172.19.0.3,file_mode=0755,dir_mode=0755,soft,nounix,serverino,mapposix,rsize=1048576,wsize=1048576,echo_interval=60,actimeo=1)
	```



