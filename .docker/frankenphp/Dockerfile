FROM dunglas/frankenphp:php8.2-alpine

# Install required PHP extensions
RUN install-php-extensions \
    pdo \
    pdo_mysql \
    calendar \
    gd \
    bcmath \
    sockets \
    pcntl

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /app/public
