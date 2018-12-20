# Practica samba server

Creacio de un servidor samba que es conecta a un servidor ldap , i que a mes funciona com a servidor per
que altres host fora del server local , puguin montar un homes tant de usuaris locals de el servidor com de 
els usuaris del ldap.

### Pasos a fer 



#### Execució

```
$ docker run --rm --privileged --name samba -h samba --network sambanet -it samba:18base


```
Abans te que estar engegat el ldapservergroup:

#### Execució

```
$ docker run --rm --name ldap -h ldap --net sambanet -d ldapserver:18group
```

