# based on https://github.com/sqawasmi/odoo-docker/blob/v8/Dockerfile

FROM ubuntu:14.04
MAINTAINER Ying Liu - www.MindIsSoftware.com 

RUN echo deb http://nightly.odoo.com/master/nightly/deb/ ./ >> /etc/apt/sources.list

# Configure locale
RUN locale-gen en_US.UTF-8 && update-locale
RUN echo 'LANG="en_US.UTF-8"' > /etc/default/locale
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update
RUN apt-get upgrade -y

# alias here to fix a Docker bug
RUN apt-get install --allow-unauthenticated -y openerp

ENV OPENERP_HOME /home/openerp
RUN mkdir $OPENERP_HOME 
RUN chown openerp:openerp $OPENERP_HOME 

# config odoo 
ENV ODOO_CONFIG /etc/openerp/openerp-server.conf
RUN sed -i 's/db_user = .*/db_user = odoodba/g' $ODOO_CONFIG
RUN sed -i 's/db_password = .*/db_password = odoodba/g' $ODOO_CONFIG
RUN sed -i 's/db_host = .*/db_host = odoodb/g' $ODOO_CONFIG
RUN sed -i 's/db_port = .*/db_port = 5432/g' $ODOO_CONFIG

VOLUME ["/etc/openerp", "var/log/openerp"]

EXPOSE 8069

USER openerp

# It is critical to set HOME environment variable. 
# odoo won't start without it
ENV HOME $OPENERP_HOME

ENTRYPOINT ["/usr/bin/python"]

# we cannot use $ODOO_CONFIG inside the CMD string
CMD ["/usr/bin/openerp-server", "--config=/etc/openerp/openerp-server.conf", "--logfile=/var/log/openerp/openerp-server.log"]
