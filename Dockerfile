FROM php:7.1-apache

RUN apt-get update

# 1. install packages
RUN apt-get install -y \
  curl \
  git \
  sudo \
  supervisor \
  zip \
  unzip 
  
# 2. apache configs + document root
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN rm -rf /etc/apache2/sites-enabled/000-default.conf
ADD apache/000-default.conf /etc/apache2/sites-available/
RUN ln -s /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/
  
COPY ./instantclient/. /tmp/.

ENV LD_LIBRARY_PATH /usr/local/instantclient
RUN apt-get update && apt-get install -y git unzip zip libaio-dev libxml2-dev \
     && apt-get clean -y \
     && unzip -o /tmp/instantclient-basic-linux.x64-11.2.0.4.0 -d /usr/local/ \
     && unzip -o /tmp/instantclient-sdk-linux.x64-11.2.0.4.0 -d /usr/local/ \
     && unzip -o /tmp/instantclient-sqlplus-linux.x64-11.2.0.4.0 -d /usr/local/ \
     && ln -s /usr/local/instantclient_11_2 /usr/local/instantclient \
     && ln -s /usr/local/instantclient/libclntsh.so.11.1 /usr/local/instantclient/libclntsh.so \
     && ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus \
     && echo 'export LD_LIBRARY_PATH="/usr/local/instantclient"' >> /root/.bashrc \
     && echo 'export ORACLE_HOME="/usr/local/instantclient"' >> /root/.bashrc \
     && echo 'umask 0022' >> /root/.bashrc 
     
RUN  docker-php-ext-configure oci8 -with-oci8=instantclient,/usr/local/instantclient \
     && docker-php-ext-install oci8 
     
RUN docker-php-ext-install bcmath

RUN docker-php-ext-install pdo_mysql mysqli

# Install the gmp and mcrypt extensions
RUN apt-get update -y
RUN apt-get install -y libgmp-dev re2c libmhash-dev libmcrypt-dev file
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/
RUN docker-php-ext-configure gmp 
RUN docker-php-ext-install gmp

RUN apt-get install -y zlib1g-dev libicu-dev g++ \
&& docker-php-ext-configure intl \
&& docker-php-ext-install intl

# Install bz2
RUN apt-get install -y libbz2-dev
RUN docker-php-ext-install bz2
     
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN a2enmod rewrite
RUN a2enmod expires
RUN a2enmod mime
RUN a2enmod filter
RUN a2enmod deflate
RUN a2enmod proxy_http
RUN a2enmod headers
RUN a2enmod php7

# Edit PHP INI
RUN echo "memory_limit = 1G" > /usr/local/etc/php/php.ini
RUN echo "upload_max_filesize = 50M" >> /usr/local/etc/php/php.ini
RUN echo "post_max_size = 50M" >> /usr/local/etc/php/php.ini
RUN echo "max_input_time = 60" >> /usr/local/etc/php/php.ini
RUN echo "file_uploads = On" >> /usr/local/etc/php/php.ini
RUN echo "max_execution_time = 300" >> /usr/local/etc/php/php.ini
RUN echo "LimitRequestBody = 100000000" >> /usr/local/etc/php/php.ini
#RUN echo "extension = php_gmp.so" >> /usr/local/etc/php/php.ini

RUN apt-get install nano -y
RUN export COMPOSER_ALLOW_SUPERUSER=$uid
#6

ARG uid
RUN useradd -G www-data,root -u $uid -d /home/devuser devuser
RUN mkdir -p /home/devuser/.composer && \
    chown -R devuser:devuser /home/devuser

ENV APP_HOME /var/www/html

COPY . /var/www/html
RUN cd /var/www/html && composer install

#CMD php artisan config:cache
#CMD php artisan cache:clear
