FROM php:8.3-fpm-alpine

# 安裝必要套件
RUN apk add --no-cache nginx supervisor freetype-dev libjpeg-turbo-dev libpng-dev libwebp-dev zip libzip-dev icu-dev oniguruma-dev bash

# 安裝 PHP 擴展
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd mysqli pdo_mysql intl bcmath zip opcache

WORKDIR /var/www/html

# 下載 WordPress 並確保包含所有隱藏檔案
ADD https://wordpress.org/latest.tar.gz /tmp/wordpress.tar.gz
RUN tar -xzf /tmp/wordpress.tar.gz -C /tmp && \
    cp -rn /tmp/wordpress/. /var/www/html/ && \
    rm -rf /tmp/wordpress /tmp/wordpress.tar.gz

# 修正：同時建立兩個可能的 Nginx 配置目錄，確保相容性
COPY nginx.conf /etc/nginx/http.d/default.conf
RUN mkdir -p /etc/nginx/conf.d && cp /etc/nginx/http.d/default.conf /etc/nginx/conf.d/default.conf

# 核心修正：建立 Nginx 運行所需的 PID 目錄
RUN mkdir -p /run/nginx

# 確保權限
RUN chown -R www-data:www-data /var/www/html /run/nginx /var/lib/nginx /var/log/nginx

EXPOSE 80

# 啟動腳本：先檢查權限再啟動服務
CMD ["sh", "-c", "chown -R www-data:www-data /var/www/html && php-fpm -D && nginx -g 'daemon off;'"]