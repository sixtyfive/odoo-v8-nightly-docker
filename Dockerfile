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

# config local postgresql
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

# config odoo 
RUN sed -i "s/db_user = .*/db_user = $ODOO_USER/g" $/etc/openerp/openerp-server.conf

# add supervesord config file
ADD files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22 5432 8069

CMD ["/usr/bin/supervisord"]
