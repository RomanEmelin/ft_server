# OS for my web server
FROM debian:buster
# It's me :D
LABEL maintainer="atrumksar@gmail.com"
LABEL name="emelin_roman"
# update linux package
RUN apt-get -y update && apt-get -y upgrade && apt-get -y install wget
RUN apt-get	-y install nginx
RUN	apt-get -y install mariadb-server
RUN apt-get -y install php7.3 php7.3-fpm php7.3-mysql php7.3-mbstring

# phpMyAdmin
WORKDIR /var/www/site/
WORKDIR /
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-english.tar.gz
RUN tar -xzvf phpMyAdmin-5.0.4-english.tar.gz
RUN rm phpMyAdmin-5.0.4-english.tar.gz
RUN mv phpMyAdmin-5.0.4-english/ /var/www/site/phpmyadmin


# copy my config files to conteiner
COPY ./srcs/init_server.sh .
# make selfcigned SSl certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-out /etc/ssl/certs/selfsigned_ssl.crt \
	-keyout /etc/ssl/private/selfsigned_ssl.key \
	-subj "/C=RU/ST=Tatarstan/L=Kazan/O=Ecole/OU=21/CN=localhost"
#copy nginx.conf and move to conteiner
COPY ./srcs/nginx.conf /etc/nginx/sites-available/nginx.conf
RUN ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/nginx.conf

COPY ./srcs/config.inc.php ./var/www/site/phpmyadmin
# make wordpress
RUN wget https://wordpress.org/latest.tar.gz
RUN tar -xzvf latest.tar.gz
RUN rm latest.tar.gz
RUN mv wordpress/ /var/www/site/wordpress
COPY ./srcs/wp-config.php /var/www/site/wordpress

# change Auth and init
RUN chown -R www-data /var/www/*
RUN chmod -R 755 /var/www/*

EXPOSE 80 443
CMD bash init_server.sh
