FROM centos:7
RUN yum install -y autoconf wget automake bzip2 flex gcc git httpd-devel libaio-devel libass-devel libjpeg-turbo-devel libpng12-devel libtheora-devel libtool libva-devel libvdpau-devel libvorbis-devel libxml2-devel libxslt-devel perl texi2html unzip zip openssl openssl-devel  && \
    cd /usr/src &&  \
    #install modsec
    git clone -b nginx_refactoring https://github.com/SpiderLabs/ModSecurity.git /usr/src/modsecurity && \
    cd /usr/src/modsecurity && \
	./autogen.sh && \
	./configure --enable-standalone-module --disable-mlogc && \
	make && \
    cd / && \
    #install nginx
    wget http://nginx.org/download/nginx-1.15.7.tar.gz && \
	tar xvzf nginx-1.15.7.tar.gz && \
	cd ../nginx-1.15.7 && \
	./configure --user=root --group=root --with-debug --with-ipv6 --with-http_ssl_module --add-module=/usr/src/modsecurity/nginx/modsecurity --with-http_ssl_module --without-http_access_module --without-http_auth_basic_module --without-http_autoindex_module --without-http_empty_gif_module --without-http_fastcgi_module --without-http_referer_module --without-http_memcached_module --without-http_scgi_module --without-http_split_clients_module --without-http_ssi_module --without-http_uwsgi_module && \
	make && \
	make install
#extend image
FROM centos:7
COPY --from=0 /usr/src/modsecurity /usr/src/modsecurity
COPY --from=0 /usr/local/nginx/ /usr/local/nginx/
RUN ln -s /usr/local/nginx/sbin/nginx /bin/nginx && \
    cp /usr/src/modsecurity/unicode.mapping /usr/local/nginx/conf/ && \
	mkdir -p /opt/modsecurity/var/audit/ && \
    yum update -y && \
    yum install -y autoconf automake bzip2 flex gcc git httpd-devel libaio-devel libass-devel libjpeg-turbo-devel libpng12-devel libtheora-devel libtool libva-devel libvdpau-devel libvorbis-devel libxml2-devel libxslt-devel perl texi2html unzip zip openssl openssl-devel  && \
	git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /usr/src/owasp-modsecurity-crs && \
	cp -R /usr/src/owasp-modsecurity-crs/rules/ /usr/local/nginx/conf/  && \
	mv /usr/local/nginx/conf/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example  /usr/local/nginx/conf/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf && \
	mv /usr/local/nginx/conf/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example  /usr/local/nginx/conf/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf && \
    yum remove -y git
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
COPY modsec_includes.conf /usr/local/nginx/conf/modsec_includes.conf
COPY crs-setup.conf /usr/local/nginx/conf/rules/crs-setup.conf
COPY modsecurity.conf /usr/local/nginx/conf/modsecurity.conf
