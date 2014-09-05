# based on https://github.com/sqawasmi/odoo-docker/blob/v8/Dockerfile

FROM ubuntu:14.04
MAINTAINER Ying Liu - www.MindIsSoftware.com 

ENV ODOO_USER openerp
ENV ODOO_DB_USER odoo
ENV ODOO_DB_PASSWORD ODOO_DB_USER
ENV ODOO_DB_HOST odoodb
ENV ODOO_DB_PORT 5432

RUN echo deb http://nightly.odoo.com/8.0/nightly/deb/ ./ >> /etc/apt/sources.list

# Configure locale
RUN locale-gen en_US.UTF-8 && update-locale
RUN echo 'LANG="en_US.UTF-8"' > /etc/default/locale
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y vim git wget curl

RUN apt-get install --allow-unauthenticated -y openerp

ENV OPENERP_HOME /home/$ODOO_USER
RUN mkdir -p $OPENERP_HOME 
RUN chown $ODOO_USER:$ODOO_USER $OPENERP_HOME 

# config odoo 
ENV ODOO_CONFIG /etc/openerp/openerp-server.conf
RUN sed -i "s/db_user = .*/db_user = $ODOO_DB_USER/g" $ODOO_CONFIG
RUN sed -i "s/db_password = .*/db_password = $ODOO_DB_PASSWORD/g" $ODOO_CONFIG
RUN sed -i "s/db_host = .*/db_host = $ODOO_DB_HOST/g" $ODOO_CONFIG
RUN sed -i "s/db_port = .*/db_port = $ODOO_DB_PORT/g" $ODOO_CONFIG

VOLUME ["/etc/openerp", "var/log/openerp"]

EXPOSE 8069

USER ODOO_USER

# It is critical to set HOME environment variable. 
# odoo won't start without it
ENV HOME $OPENERP_HOME

ENTRYPOINT ["/usr/bin/python"]

# we cannot use $ODOO_CONFIG inside the CMD string
CMD ["/usr/bin/openerp-server", "--config=/etc/openerp/openerp-server.conf", "--logfile=/var/log/openerp/openerp-server.log"]
