FROM dunglas/frankenphp:php8.2-alpine

# Instalar extensões PHP necessárias
RUN install-php-extensions \
    pdo \
    pdo_mysql \
    calendar \
    gd \
    bcmath \
    sockets \
    pcntl

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /app/public
