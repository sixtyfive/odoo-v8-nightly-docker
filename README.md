odoo-v8-nightly-docker
======================

We created a self-contained [Odoo 8.0 Docker image]
(https://registry.hub.docker.com/u/yingliu4203/odoo8nightly/) that  
was installed from [the latest Odoo 8.0 nightly build] 
(http://nightly.openerp.com/8.0/nightly/deb/). 
The Docker image building source code is in GitHub 
 https://github.com/YingLiu4203/odoo-v8-nightly-docker. It is based on 
 [Shaker Qawasmi's Odoo Dockerfile]
(https://github.com/sqawasmi/odoo-docker/blob/v8/Dockerfile) 
and uses some scripting ideas from 
[ANDRÉ SCHENKELS's Odoo installation script] 
(https://github.com/aschenkels-ictstudio/openerp-install-scripts/blob/master/odoo-v8/ubuntu-14-04/odoo_install.sh). 

There are three major changes from Shaker's Odoo image:  

* It uses the recently available Odoo 8.0 nightly build
* It is self-contained. We use a local postgresql database that 
comes with the Odoo 8.0 installation.
* It does not use extra configuration files. All configuration files 
are created using Docker commands.

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
