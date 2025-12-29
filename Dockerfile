# 使用 PHP 8.3 FPM Alpine 版本
FROM php:8.3-fpm-alpine

# 安裝 Nginx 與 WordPress 必要的 PHP 擴展
RUN apk add --no-cache \
    nginx \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    freetype-dev \
    zip \
    libzip-dev \
    icu-dev \
    oniguruma-dev \
    bash

# 配置 PHP 擴展
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
    gd \
    mysqli \
    pdo_mysql \
    intl \
    bcmath \
    zip \
    opcache

# 設定工作目錄
WORKDIR /var/www/html

# 下載並解壓 WordPress 原始碼
ADD https://wordpress.org/latest.tar.gz /tmp/wordpress.tar.gz
RUN tar -xzf /tmp/wordpress.tar.gz -C /tmp && \
    cp -r /tmp/wordpress/* /var/www/html/ && \
    rm -rf /tmp/wordpress /tmp/wordpress.tar.gz

# 複製 Nginx 設定
COPY nginx.conf /etc/nginx/http.d/default.conf

# 設定權限 (WordPress 需要對 wp-content 有寫入權)
RUN chown -R www-data:www-data /var/www/html

# 暴露 80 埠
EXPOSE 80

# 啟動 Nginx 與 PHP-FPM
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
