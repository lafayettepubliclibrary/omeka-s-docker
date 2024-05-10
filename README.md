# Omeka-S in Docker containers

Built by Adam Melancon, IT Manager of the Lafayette (Louisiana) Public Library System.

http://www.lafayettepubliclibrary.org

This is an updated build of an Omkea-S image from https://hub.docker.com/r/dodeeric/omeka-s

## Source Repo
https://github.com/lafayettepubliclibrary/omeka-s-docker

## Launch the containers

Install Docker and Docker-compose on your host (can be a physical or virtual machine). 

Download the file "docker-compose.yml".

From the directory containing the "docker-compose.yml" file:

```
$ sudo docker-compose up -d
```

This will deploy three Docker containers:

- Container 1: mariadb (mysql) 
- Container 2: phpmyadmin (connected to container 1)
- Container 3: omeka-s (connected to container 1)

With your browser, go to:

- Omeka-S: http://hostname
- PhpMyAdmin: http://hostname:8080

At that point, you can start configuring your Omeka-S web portal.

Remarks:

- images will be downloaded automatically from the Docker hub: mariadb:latest, phpmyadmin:latest, lafayettepubliclibrary/omeka-s:3.1.1
- for the omeka-s container, /var/www/html/files (media files uploaded by the users) and /var/www/html/config/database.ini (configuration file with the credentials for the db) are put in a named volume and will survive the removal of the container. The mariadb container also puts the data (omeka-s db in /var/lib/mysql) in a named volume. Volumes are hosted in the host filesystem (/var/lib/docker/volumes).

To stop the containers:

```
$ sudo docker-compose stop
```

To remove the containers:

```
$ sudo docker-compose rm 
```

Remark: this will NOT delete the volumes (omeka and mariadb). If you launch again "sudo docker-compose up -d", the volumes will be re-used.

To login into a container:

```
$ sudo docker container exec -it <container-id-or-name> bash 
```

## Build a new image (optional)

If you want to modify the omeka-s image (by changing the Dockerfile file), you will need to build a new image:

E.g.:

```
$ git clone https://github.com/lafayettepubliclibrary/omeka-s-docker.git
$ cd omeka-s-docker
```

Edit the Dockerfile file.

Once done, build the new Docker image:

```
$ sudo docker image build -t foo/omeka-s:3.1.1-bar .
$ sudo docker image tag foo/omeka-s:3.1.1-bar foo/omeka-s:latest
```

Upload the image to your Docker hub repository:

Login in your account (e.g. foo) on hub.docker.com, and create a repository "omeka-s", then upload your customized image:

```
$ sudo docker login --username=foo
$ sudo docker image push foo/omeka-s:3.1.1-bar
$ sudo docker image push foo/omeka-s:latest
```

## Use Nginx as reverse proxy (optional) 

If you want to access Omeka-S on port 80 (or 443), you can use the Nginx reverse proxy and load balancer.

I'm using these containers for reverse proxy with https.
https://hub.docker.com/r/jwilder/nginx-proxy
https://hub.docker.com/r/nginxproxy/acme-companion

See the docker-compose-nginxproxy.yml file in the github repo for an example configration.

The example.lafayettepubliclibrary.org dns name is directed to the Docker host's Nginx container which will proxy them to the Omeka container. 
The example.lafayettepubliclibrary.org dns name has to point to the IP of the Docker host.

With your browser, go to: (lafayettepubliclibrary.org is replaced by your dns domain; e.g. mydomain.com)

- Omeka-S: http://example.mydomain.com

The Nginx container only exposes its TCP ports (80, 443) on the Docker host; the service containers run on the private "net" network.
