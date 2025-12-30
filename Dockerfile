# 使用 PHP 8.3 FPM Alpine 版本
FROM php:8.3-fpm-alpine

# 安裝 Nginx 與 WordPress 必要的 PHP 擴展
RUN apk add --no-cache \
    nginx \
    supervisor \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
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

# 下載並解壓 WordPress
ADD https://wordpress.org/latest.tar.gz /tmp/wordpress.tar.gz
RUN tar -xzf /tmp/wordpress.tar.gz -C /tmp && \
    # 使用 . 確保包含隱藏檔，並確保目標目錄乾淨
    cp -rn /tmp/wordpress/. /var/www/html/ && \
    rm -rf /tmp/wordpress /tmp/wordpress.tar.gz

# 複製 Nginx 設定
COPY nginx.conf /etc/nginx/http.d/default.conf

# 核心修正：確保 nginx 執行時有權限讀取 pid 與 run 檔案 (Alpine 特色)
RUN mkdir -p /run/nginx

# 設定權限
RUN chown -R www-data:www-data /var/www/html

# 啟動命令：增加啟動前的權限強制檢查
CMD ["sh", "-c", "chown -R www-data:www-data /var/www/html && php-fpm -D && nginx -g 'daemon off;'"]
