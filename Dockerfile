FROM centos
MAINTAINER Pavel Loginov (https://github.com/Aidaho12/haproxy-wi)

COPY epel.repo /etc/yum.repos.d/epel.repo

RUN yum -y install git nmap-ncat python34 dos2unix python34-pip httpd yum-plugin-remove-with-leaves svn gcc-c++ gcc gcc-gfortran python34-devel

COPY haproxy-wi.conf /etc/httpd/conf.d/haproxy-wi.conf

RUN git clone https://github.com/Aidaho12/haproxy-wi.git /var/www/haproxy-wi && \
	mkdir /var/www/haproxy-wi/keys/ && \
	mkdir /var/www/haproxy-wi/app/certs/ && \
	chown -R apache:apache /var/www/haproxy-wi/ && \
	pip3 install -r /var/www/haproxy-wi/requirements.txt --no-cache-dir && \
	chmod +x /var/www/haproxy-wi/app/*.py && \
	chmod +x /var/www/haproxy-wi/app/tools/*.py && \
	chown -R apache:apache /var/www/haproxy-wi/ && \
	chown -R apache:apache /var/log/httpd/ && \
	
WORKDIR /var/www/haproxy-wi/app
RUN ./update_db.py 
	
EXPOSE 80
VOLUME /var/www/haproxy-wi/

CMD /usr/sbin/httpd -DFOREGROUND