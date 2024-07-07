# find mounted volumes of running docker container
```bash
docker inspect -f '{{ .Mounts }}' containerid
```

or
```bash
docker volume ls
```

first command will give you the path, add these to <directories>  in ossec.conf more monitoring

use docker commit to save a new image then docker save to export to tar file
