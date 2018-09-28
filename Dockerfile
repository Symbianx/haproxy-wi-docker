FROM centos
MAINTAINER Pavel Loginov (https://github.com/Aidaho12/haproxy-wi)

COPY epel.repo /etc/yum.repos.d/epel.repo

RUN yum -y install httpd 

COPY haproxy-wi.conf /etc/httpd/conf.d/haproxy-wi.conf
COPY wrapper.sh /wrapper.sh

RUN yum -y install git nmap-ncat net-tools python35u dos2unix python35u-pip httpd python35u-devel gcc-c++ gcc gcc-gfortran python34-devel && \
	git clone https://github.com/Aidaho12/haproxy-wi.git /var/www/haproxy-wi && \
	mkdir /var/www/haproxy-wi/keys/ && \
	mkdir /var/www/haproxy-wi/app/certs/ && \
	chown -R apache:apache /var/www/haproxy-wi/ && \
	pip3 install -r /var/www/haproxy-wi/requirements.txt --no-cache-dir && \
	chmod +x /var/www/haproxy-wi/app/*.py && \
	chmod +x /var/www/haproxy-wi/app/tools/*.py && \
	chmod +x /wrapper.sh && \
	chown -R apache:apache /var/log/httpd/ && \
	yum -y erase yum -y install git python35u-pip gcc-c++  gcc-gfortran gcc --remove-leaves && \
	yum -y autoremove yum-plugin-remove-with-leaves && \
	yum clean all && \
	rm -rf /var/cache/yum && \
	rm -f /etc/yum.repos.d/* && \
	cd /var/www/haproxy-wi/app &&\
	./create_db.py && \
	chown -R apache:apache /var/www/haproxy-wi/ 
	
EXPOSE 80
VOLUME /var/www/haproxy-wi/

CMD /wrapper.sh