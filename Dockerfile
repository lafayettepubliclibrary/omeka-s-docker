#FROM php:apache
FROM php:7.4.26-apache

# Omeka-S web publishing platform for digital heritage collections (https://omeka.org/s/)
# Initial maintainer: Oldrich Vykydal (o1da) - Klokan Technologies GmbH  
MAINTAINER Adam Melancon <adam.melancon@lafayettepubliclibrary.org>

RUN a2enmod rewrite

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update && apt-get -qq -y upgrade
RUN apt-get -qq update && apt-get -qq -y --no-install-recommends install \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libjpeg-dev \
    libmemcached-dev \
    zlib1g-dev \
    imagemagick \
    libmagickwand-dev

# Install the PHP extensions we need
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/
RUN docker-php-ext-install -j$(nproc) iconv pdo pdo_mysql mysqli gd
RUN pecl install mcrypt-1.0.4 && docker-php-ext-enable mcrypt && pecl install imagick && docker-php-ext-enable imagick 

# Add the Omeka-S PHP code
COPY ./omeka-s-3.1.1.zip /var/www/
RUN unzip -q /var/www/omeka-s-3.1.1.zip -d /var/www/ \
&&  rm /var/www/omeka-s-3.1.1.zip \
&&  rm -rf /var/www/html/ \
&&  mv /var/www/omeka-s/ /var/www/html/

COPY ./imagemagick-policy.xml /etc/ImageMagick/policy.xml
COPY ./.htaccess /var/www/html/.htaccess

# Add some Omeka modules
COPY ./omeka-s-modules-v6.tar.gz /var/www/html/
RUN rm -rf /var/www/html/modules/ \
&&  tar -xzf /var/www/html/omeka-s-modules-v6.tar.gz -C /var/www/html/ \
&&  rm /var/www/html/omeka-s-modules-v6.tar.gz

# Add some themes
COPY ./theme-centerrow-v1.7.2.zip ./theme-cozy-v1.5.2.zip ./theme-thedaily-v1.6.2.zip /var/www/html/themes/
RUN unzip -q /var/www/html/themes/theme-centerrow-v1.7.2.zip -d /var/www/html/themes/ \
&&  unzip -q /var/www/html/themes/theme-cozy-v1.5.2.zip -d /var/www/html/themes/ \
&&  unzip -q /var/www/html/themes/theme-thedaily-v1.6.2.zip -d /var/www/html/themes/ \
&&  rm /var/www/html/themes/theme-centerrow-v1.7.2.zip /var/www/html/themes/theme-cozy-v1.5.2.zip /var/www/html/themes/theme-thedaily-v1.6.2.zip

# Create one volume for files and config
RUN mkdir -p /var/www/html/volume/config/ && mkdir -p /var/www/html/volume/files/
COPY ./database.ini /var/www/html/volume/config/
RUN rm /var/www/html/config/database.ini \
&& ln -s /var/www/html/volume/config/database.ini /var/www/html/config/database.ini \
&& rm -Rf /var/www/html/files/ \
&& ln -s /var/www/html/volume/files/ /var/www/html/files \
&& chown -R www-data:www-data /var/www/html/ \
&& chmod 600 /var/www/html/volume/config/database.ini \
&& chmod 600 /var/www/html/.htaccess

VOLUME /var/www/html/volume/

CMD ["apache2-foreground"]
