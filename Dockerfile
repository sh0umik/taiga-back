FROM python

# Based in work of Hylke Visser <htdvisser@gmail.com>
MAINTAINER Fahim Shariar <fahim.shoumik@gmail.com>

# For proxy, use as --build-arg in docker build command:
# --build-arg PKG_PROXY='Acquire::http { Proxy "http://<proxy_ip>:<port>"; };'
# --build-arg PIP_PROXY="--proxy=http://<proxy_ip>:<port>"
ARG PKG_PROXY
ARG PIP_PROXY

# Update all mirrors
RUN \
    # Set a package proxy in next line
    echo ${PKG_PROXY} > /etc/apt/apt.conf; \
    apt-get update -qq && \
    apt-get install -y netcat vim less curl && \
    rm -rf /var/lib/apt/lists/* && \
    pip install $PIP_PROXY circus gunicorn taiga-contrib-ldap-auth

# Install taiga-back
RUN \
  mkdir -p /usr/local/taiga/taiga-back && \
  useradd -d /usr/local/taiga taiga && \
  # git clone https://github.com/taigaio/taiga-back.git /usr/local/taiga/taiga-back && \
  wget -qO- https://github.com/taigaio/taiga-back/archive/stable.tar.gz | tar xvz --strip-components=1 -C /usr/local/taiga/taiga-back && \
  mkdir /usr/local/taiga/media /usr/local/taiga/static /usr/local/taiga/logs && \
  cd /usr/local/taiga/taiga-back && \
  # git checkout stable && \
  pip install $PIP_PROXY -r requirements.txt && \
  touch /usr/local/taiga/taiga-back/settings/dockerenv.py && \
  touch /usr/local/taiga/circus.ini

# Add Taiga Configuration
ADD ./local.py /usr/local/taiga/taiga-back/settings/local.py

# Configure and Start scripts
ADD ./configure /usr/local/taiga/configure
ADD ./start /usr/local/taiga/start
RUN chmod +x /usr/local/taiga/configure /usr/local/taiga/start

# VOLUME /usr/local/taiga/media
# VOLUME /usr/local/taiga/static
# VOLUME /usr/local/taiga/logs

EXPOSE 8000

CMD ["/usr/local/taiga/start"]

# Start line
# docker run -it --rm --name taiga-back --link pgdb:postgres -p 8000:8000 -e POSTGRES_HOST=postgres -e POSTGRES_PORT=5432 -e POSTGRES_USER=taiga -e POSTGRES_PASSWORD=changeme -e POSTGRES_DB_NAME=taiga -e EMAIL_USE_TLS=True -e EMAIL_HOST=smtp.example.com -e EMAIL_PORT=587 -e EMAIL_HOST_USER='youremail' -e EMAIL_HOST_PASSWORD='yourpassword' -e DEFAULT_FROM_EMAIL='youremail@example.com' -e TEMPLATE_DEBUG=True -e DEBUG=True -e API_DOMAIN=example.com -e LDAP_SERVER=ldap.example.com -e LDAP_PORT=636 -e LDAP_BIND_DN='uid=user,ou=Users,o=Builtin,dc=example,dc=com' -e LDAP_BIND_PASSWORD='password' -e LDAP_SEARCH_BASE='dc=example,dc=com' filhocf/taiga-back bash
