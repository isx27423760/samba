#prova samba server

docker run --rm --privileged --name samba -h samba --network sambanet -it samba:18base /bin/bash

