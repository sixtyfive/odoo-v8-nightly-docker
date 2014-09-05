odoo-v8-nightly-docker
======================

An Odoo V8 nightly build docker image based on [Shaker Qawasmi's Odoo Dockerfile]
(https://github.com/sqawasmi/odoo-docker/blob/v8/Dockerfile) and 
[ANDRÉ SCHENKELS's Odoo installation script] 
(https://github.com/aschenkels-ictstudio/openerp-install-scripts/blob/master/odoo-v8/ubuntu-14-04/odoo_install.sh). 

We use a local postgresql database that comes with the Odoo 8.0 installatoin. 

Run the following command in a machine that has Docker installed: 

```bash
sudo docker run --name odoo8 -p 22:22 -p 5432:5432 -p 8069:8069 -d yingliu4203/odoo8nightly  
```

To stop it:

```bash
sudo docker stop odoo8
```

To restart it:
```bash
sudo docker start odoo8
```

The created Docker container exposes SSH (22), Postgresql (5432) and Odoo (8069)
pors using the same port numbers in the host. You can connect to these 
services remotely. For SSH, you need to config user password in the container. 
