odoo-v8-nightly-docker
======================

An Odoo V8 nightly build docker image based on [Shaker Qawasmi's Odoo Dockerfile]
(https://github.com/sqawasmi/odoo-docker/blob/v8/Dockerfile) and 
[ANDRÉ SCHENKELS's Odoo installation script] 
(https://github.com/aschenkels-ictstudio/openerp-install-scripts/blob/master/odoo-v8/ubuntu-14-04/odoo_install.sh). 

The major changes are 

* No extra file to be added. Only the Dockerfile is used to build the image. The configuration file is edited using sed command.
* Only install Odoo nighly build, no need to install ssh and supervisor. 

To run it with a postgres container

     docker run --name odoo --link postgres:odoodb -p 8069:8069 -d yingliu4203/odoov8:nightly
