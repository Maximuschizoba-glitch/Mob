FROM php:8.2-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libxml2-dev libzip-dev libonig-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring xml zip bcmath \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

RUN composer install --no-dev --optimize-autoloader --no-scripts --no-plugins

EXPOSE 8080

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["php artisan migrate --force 2>&1; echo 'MIGRATE_DONE'; php artisan serve --host=0.0.0.0 --port=${PORT:-8080}"]
