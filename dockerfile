FROM mysql:8.0

ENV MYSQL_ROOT_PASSWORD=sanem2025
ENV MYSQL_DATABASE=bd_sanem
ENV MYSQL_USER=usuario
ENV MYSQL_PASSWORD=usuario123

COPY init.sql /docker-entrypoint-initdb.d/

EXPOSE 3306