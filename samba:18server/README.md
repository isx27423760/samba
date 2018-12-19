#prova samba server


#### Execució

```
$ docker run --rm --privileged --name samba -h samba --network sambanet -it samba:18base


```
Abans te que estar engegat el ldapservergroup:

#### Execució

```
$ docker run --rm --name ldap -h ldap --net sambanet -d ldapserver:18group
```

