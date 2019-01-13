#Samba server

## EDT ASIX M06-2018/19

ASIX M06 Escola del treball 

### Imatges:

* **samba:18homes** Servidor SAMBA amb usuaris locals i usuaris LDAP (unix). Es creen comptes d'usuari samba d'usuaris locals i d'alguns dels usuaris ldap (no tots). Es creen també els directoris home dels usuaris de ldap i se'ls assigna la pripietat/grup pertinent. Finalment s'exporten els shares d'exemple usuals i els [homes] dels usuaris samba. D'aquesta manera un hostpam (amb ldap) pot muntar els homes dels usuaris (home dins home) usant samba.

* **samba:18ldapsamba** Servidor SAMBA amb backend LDAP ldapsam. Requereix de l'ús de un servidor ldap preparat amb l'schema samba. Les dades dels usuaris samba es desen en els comptes d'usuari ldap.
