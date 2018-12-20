# Version: 0.0.1
# @edt M06 2018-2019
# samba prova
# -------------------------------------
FROM fedora:27
LABEL author="@edt ASIX M06-ASO"
LABEL description="SAMBA server 2018-2019"
RUN dnf -y install vim procps samba samba-client passwd openldap-clients nss-pam-ldapd authconfig pam_mount cifs-utils
RUN mkdir /opt/docker
COPY * /opt/docker/
RUN chmod +x /opt/docker/install.sh /opt/docker/startup.sh
WORKDIR /opt/docker
CMD ["/opt/docker/startup.sh"]

