# based on https://github.com/sqawasmi/odoo-docker/blob/v8/Dockerfile

FROM ubuntu:14.04
MAINTAINER Ying Liu - www.MindIsSoftware.com 

ENV ODOO_USER openerp
ENV ODOO_HOME /home/$ODOO_USER

RUN echo deb http://nightly.odoo.com/8.0/nightly/deb/ ./ >> /etc/apt/sources.list

# Configure locale
RUN locale-gen en_US.UTF-8 && update-locale
RUN echo 'LANG="en_US.UTF-8"' > /etc/default/locale
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y vim git wget curl 
RUN apt-get install -y supervisor openssh-server

RUN apt-get install --allow-unauthenticated -y openerp

RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor

RUN mkdir -p $ODOO_HOME 
RUN chown $ODOO_USER:$ODOO_USER $ODOO_HOME 

#### config postgresql
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

# Run the rest of the commands as the ``postgres`` user created by the ``postgres-9.3`` package 
USER postgres

# Create a PostgreSQL role 
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN /etc/init.d/postgresql start &&\
    psql -e --command "CREATE USER $ODOO_USER WITH SUPERUSER PASSWORD 'openerp'" &&\
    /etc/init.d/postgresql stop

USER root

#### config odoo 

# set the database user
RUN sed -i "s/db_user = .*/db_user = $ODOO_USER/g" /etc/openerp/openerp-server.conf

# change user shell thus a root can su to the account
RUN chsh -s /bin/bash $ODOO_USER

# add supervesord config file
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22 5432 8069

CMD ["/usr/bin/supervisord"]
