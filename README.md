odoo-v8-nightly-docker
======================

## Overview
We created a self-contained [Odoo 8.0 Docker image]
(https://registry.hub.docker.com/u/yingliu4203/odoo8nightly/) that 
was installed from [the latest Odoo 8.0 nightly build] 
(http://nightly.openerp.com/8.0/nightly/deb/). 
The Docker image building source code is in [a GitHub repository]
(https://github.com/YingLiu4203/odoo-v8-nightly-docker). It is based on 
[Shaker Qawasmi's Odoo Dockerfile]
(https://github.com/sqawasmi/odoo-docker/blob/v8/Dockerfile) 
and uses some scripting ideas from 
[ANDRÉ SCHENKELS's Odoo installation script] 
(https://github.com/aschenkels-ictstudio/openerp-install-scripts/blob/master/odoo-v8/ubuntu-14-04/odoo_install.sh). 
We had several issues in creating this Docker image. 
They are listed at the end. 

There are three major changes from Shaker's Odoo image:  

* It uses the recently available Odoo 8.0 nightly build
* It is self-contained. We use a local postgresql database that 
comes with the Odoo 8.0 installation.
* It does not use extra configuration files. All configuration files 
are created using Docker commands.

## To Use It
To use it, just run the following command 
in a machine that has Docker installed:

```bash
sudo docker run --name odoo8 -p 2222:22 -p 5432:5432 -p 8069:8069 -d yingliu4203/odoo8nightly
```

The command creates a Docker instance named "odoo8" from the 
Docker image. All services are up and running. Just type 
"http://your-host-ip:8069" in your browser and enjoy. 

To stop it:

```bash
sudo docker stop odoo8
```

To restart it:

```bash
sudo docker start odoo8
```

The created Docker container exposes SSH (from 22 to 2222), 
Postgresql (5432) and Odoo (8069) ports in the host. 
You can connect to these services remotely.
To use SSH, you need to config user and password in the container.

Instead of SSH, you can access the container using a tool called
[nsenter](https://github.com/jpetazzo/nsenter).

```bash
# install nsenter into /usr/local/bin
docker run --rm -v /usr/local/bin:/target jpetazzo/nsenter

# login odoo container
docker-enter odoo8
```

In the container, you can stop Postgresql or Odoo service
by finding their process id and `kill`  them.
Then you can start the services using the init.d service command

```bash
/etc/init.d/postgresql start
/etc/init.d/openerp start
```

## Technical issues 

The [Docker build file] 
(https://github.com/YingLiu4203/odoo-v8-nightly-docker/blob/master/Dockerfile)
looks simple. However, there were some technical issues in creating
this file. We document them here thinking that somebody may want
to fork and customize it.  

* Set locale. Otherwise, Postgresql and Odoo may use different locale.
* Make /var/run/sshd directory. Otherwise, SSH may not run
* Set postgres as the owner of Postgresql directory. There is a 
"Permission denied" when you run an image that was built in Docker Hub.
* Set "ssl=false" in Postgresql configuration to fix another Docker bug.  
* Run all services in interactive mode using Supervisor. 
A service starts/stops when a container starts/stops. If you want,
you can kill any service and re-start it inside a container.
* Set **"HOME"** environment variable for **openerp** user. Odoo may
complain if it is not there. 
* Use CMD, not ENTTRYPOINT, to run supervisord

The tricky thing is that some issues, such as the Postgresql directory
ownership bug, only occur when you image is built by Docker Hub. 
