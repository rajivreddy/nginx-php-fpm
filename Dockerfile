FROM debian:jessie

RUN apt-get update && apt-get upgrade -y
RUN echo "deb http://mirrors.linode.com/debian/ jessie main contrib non-free" >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.linode.com/debian/ jessie main contrib non-free" >> /etc/apt/sources.list

RUN echo "deb http://security.debian.org/ jessie/updates main contrib non-free" >> /etc/apt/sources.list
RUN echo "deb-src http://security.debian.org/ jessie/updates main non-free" >> /etc/apt/sources.list

# jessie-updates, previously known as 'volatile'
RUN echo "deb http://mirrors.linode.com/debian/ jessie-updates main contrib non-free" >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.linode.com/debian/ jessie-updates main contrib non-free" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install apache2 libapache2-mod-fastcgi php5-fpm -y
RUN apt-get install php5-mysql -y
RUN a2enmod actions
COPY cgi/fastcgi.conf /etc/apache2/mods-enabled/fastcgi.conf
RUN apache2ctl configtest

RUN apt-get install -y curl wget git htop supervisor vim openssh-server software-properties-common netcat
RUN apt-get install -y net-tools
RUN apt-get install -y \
    mysql-client \
    php5 \
    php5-cli \
    php5-common \
    php5-gd \
    php5-mcrypt \
    php5-fpm \
    php5-curl \
    php5-memcached \
    php5-xdebug \
    php5-xhprof \
    php5-mysql \
    php-pear \
    php5-dev
COPY superd/*.conf /etc/supervisor/conf.d/ 
COPY scripts/start-services.sh /start-services.sh
RUN chmod u+x /start-services.sh
COPY apache/000-default.conf /etc/apache2/sites-enabled/000-default.conf
RUN a2enmod rewrite headers fastcgi actions
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer
# Make sure globally installed Composer scripts are available
ENV PATH "/root/.composer/vendor/bin:$PATH"

# Install Drush through Composer globally
RUN composer global require drush/drush:8

# Install PHPUnit
RUN wget https://phar.phpunit.de/phpunit.phar \
    && chmod +x phpunit.phar \
    && mv phpunit.phar /usr/bin/phpunit
EXPOSE 80
EXPOSE 443

# Start our Services
CMD ["/start-services.sh"]

RUN usermod -u 1000 www-data
RUN usermod -G staff www-data