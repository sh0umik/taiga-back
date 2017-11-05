# sh0umik/taiga-back

[Taiga](https://taiga.io/) is a project management platform for startups and agile developers & designers who want a simple, beautiful tool that makes work truly enjoyable.

This Docker image can be used for running the Taiga backend. It works together with the [filhocf/taiga-front-dist](https://registry.hub.docker.com/u/filhocf/taiga-front-dist/) image.

[![GitHub stars](https://img.shields.io/github/stars/filhocf/taiga-docker.svg?style=flat-square)](https://github.com/filhocf/taiga-docker)
[![GitHub forks](https://img.shields.io/github/forks/filhocf/taiga-docker.svg?style=flat-square)](https://github.com/filhocf/taiga-docker)
[![GitHub issues](https://img.shields.io/github/issues/filhocf/taiga-docker.svg?style=flat-square)](https://github.com/filhocf/taiga-docker/issues)

## Running

A [postgres](https://registry.hub.docker.com/_/postgres/) container should be linked to the taiga-back container. The taiga-back container will use the ``POSTGRES_USER`` and ``POSTGRES_PASSWORD`` environment variables that are supplied to the postgres container.

```
docker run --name taiga_back_container_name --link postgres_container_name:postgres sh0umik/taiga-back
```

## Docker-compose

For a complete taiga installation (``filhocf/taiga-back`` and ``filhocf/taiga-front-dist``) you can use this docker-compose configuration:

```
data:
  image: tianon/true
  volumes:
    - /var/lib/postgresql/data
    - /usr/local/taiga/media
    - /usr/local/taiga/static
    - /usr/local/taiga/logs
db:
  image: postgres
  environment:
    POSTGRES_USER: taiga
    POSTGRES_PASSWORD: password
  volumes_from:
    - data
taigaback:
  image: sh0umik/taiga-back:stable
  hostname: dev.example.com
  environment:
    SECRET_KEY: examplesecretkey
    EMAIL_USE_TLS: True
    EMAIL_HOST: smtp.gmail.com
    EMAIL_PORT: 587
    EMAIL_HOST_USER: youremail@gmail.com
    EMAIL_HOST_PASSWORD: yourpassword
  links:
    - db:postgres
  volumes_from:
    - data
taigafront:
  image: filhocf/taiga-front-dist:stable
  hostname: dev.example.com
  links:
    - taigaback
  volumes_from:
    - data
  ports:
    - 0.0.0.0:80:80
```

## Database Initialization

To initialize the database, use ``docker exec -it taiga-back bash`` and execute the following commands:

```bash
cd /usr/local/taiga/taiga-back/
python manage.py loaddata initial_user
python manage.py loaddata initial_project_templates
python manage.py loaddata initial_role
```

## Environment

* ``SECRET_KEY`` defaults to ``"insecurekey"``, but you might want to change this.
* ``DEBUG`` defaults to ``False``
* ``TEMPLATE_DEBUG`` defaults to ``False``
* ``PUBLIC_REGISTER_ENABLED`` defaults to ``True``

URLs for static files and media files from taiga-back:

* ``MEDIA_URL`` defaults to ``"http://$HOSTNAME/media/"``
* ``STATIC_URL`` defaults to ``"http://$HOSTNAME/static/"``

Domain configuration:

* ``API_SCHEME`` defaults to ``"http"``. Use ``https`` if ``filhocf/taiga-front-dist`` is used and SSL enabled.
* ``API_DOMAIN`` defaults to ``"$HOSTNAME"``
* ``API_NAME`` defaults to ``"api"``
* ``FRONT_SCHEME`` defaults to ``"http"``. Use ``https`` if ``filhocf/taiga-front-dist`` is used and SSL enabled.
* ``FRONT_DOMAIN`` defaults to ``"$HOSTNAME"``
* ``FRONT_NAME`` defaults to ``"front"``

Email configuration:

* ``EMAIL_USE_TLS`` defaults to ``False``
* ``EMAIL_HOST`` defaults to ``"localhost"``
* ``EMAIL_PORT`` defaults to ``"25"``
* ``EMAIL_HOST_USER`` defaults to ``""``
* ``EMAIL_HOST_PASSWORD`` defaults to ``""``
* ``DEFAULT_FROM_EMAIL`` defaults to ``"no-reply@example.com"``

Database configuration:

* ``POSTGRES_DB_NAME``. Use to override database name.
* ``POSTGRES_USER``. Use to override user specified in linked postgres container.
* ``POSTGRES_PASSWORD``. Use to override password specified in linked postgres container.
