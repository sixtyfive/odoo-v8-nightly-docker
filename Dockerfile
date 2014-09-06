# based on https://github.com/sqawasmi/odoo-docker/blob/v8/Dockerfile

FROM ubuntu:14.04
MAINTAINER Ying Liu - www.MindIsSoftware.com 

# This is the account name created by Odoo setup
ENV ODOO_USER openerp

RUN echo deb http://nightly.odoo.com/8.0/nightly/deb/ ./ >> /etc/apt/sources.list

# Configure locale
RUN locale-gen en_US.UTF-8 && update-locale
RUN echo 'LANG="en_US.UTF-8"' > /etc/default/locale
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# install supporting packages
RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y vim git wget curl 
RUN apt-get install -y supervisor openssh-server

RUN apt-get install --allow-unauthenticated -y openerp

RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor

#### config postgresql

RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

# there might be a docker bug that postgresql could access 
# /etc/ssl/private/ssl-cert-snakeoil.key
RUN sed -i "s/ssl = true/ssl = false/g" /etc/postgresql/9.3/main/postgresql.conf

# start postgresql and create a role
USER postgres
RUN /etc/init.d/postgresql start &&\
    psql -e --command "CREATE USER $ODOO_USER WITH SUPERUSER PASSWORD 'openerp'" &&\
    /etc/init.d/postgresql stop

USER root

#### config odoo 

# Odoo setup doesn't create home directory
RUN mkdir -p /home/$ODOO_USER
RUN chown $ODOO_USER:$ODOO_USER -R /home/$ODOO_USER

# change user shell thus a root can su to the account
RUN chsh -s /bin/bash $ODOO_USER

# set the database user
RUN sed -i "s/db_user = .*/db_user = $ODOO_USER/g" /etc/openerp/openerp-server.conf

#### config supervesord 
ENV SUPERVISORD_CONFIG_DIR /etc/supervisor/conf.d
ENV SUPERVISORD_CONFIG_FILE $SUPERVISORD_CONFIG_DIR/supervisord.conf

RUN mkdir -p $SUPERVISORD_CONFIG_DIR 
RUN echo "[supervisord]" >> $SUPERVISORD_CONFIG_FILE
RUN echo "nodaemon=true" >> $SUPERVISORD_CONFIG_FILE
RUN echo "" >> $SUPERVISORD_CONFIG_FILE
RUN echo "[program:sshd]" >> $SUPERVISORD_CONFIG_FILE
RUN echo "command = /usr/sbin/sshd -D" >> $SUPERVISORD_CONFIG_FILE

RUN echo "" >> $SUPERVISORD_CONFIG_FILE
RUN echo "[program:postgresql]" >> $SUPERVISORD_CONFIG_FILE
RUN echo "user = postgres" >> $SUPERVISORD_CONFIG_FILE
RUN echo "command = /usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf" >> $SUPERVISORD_CONFIG_FILE

RUN echo "" >> $SUPERVISORD_CONFIG_FILE
RUN echo "[program:openerp]" >> $SUPERVISORD_CONFIG_FILE
RUN echo "user = openerp" >> $SUPERVISORD_CONFIG_FILE
RUN echo 'environment = USER="openerp", LOGNAME="openerp", HOME="/home/openerp"' >> $SUPERVISORD_CONFIG_FILE
RUN echo "command = /usr/bin/openerp-server --config=/etc/openerp/openerp-server.conf --logfile=/var/log/openerp/openerp-server.log" >> $SUPERVISORD_CONFIG_FILE

EXPOSE 22 5432 8069

# supervisord requires CMD
CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisor/conf.d/supervisord.conf"]
