# mostly based on Dockerfile at
# https://refactrd.com/user-authentication-with-django-rest-framework-and-json-web-tokens/
FROM alpine:edge

COPY requirements.txt .

RUN apk add --no-cache --virtual .build-deps \
  python3 python3-dev py3-pip \
  build-base ca-certificates \
  freetype-dev jpeg-dev libpng-dev zlib-dev \
  postgresql-dev \
  && /usr/sbin/update-ca-certificates \
  && pip3 install --upgrade pip \
  && pip3 install -r requirements.txt \
  && find /usr/local \
      \( -type d -a -name test -o -name tests \) \
      -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
      -exec rm -rf '{}' \; \
  && runDeps="$( \
      scanelf --needed --nobanner --recursive /usr/local \
              | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
              | sort -u \
              | xargs -r apk info --installed \
              | sort -u \
  )" \
  && apk add --virtual .rundeps $runDeps \
  && apk del .build-deps \
  && apk add --no-cache python3 libpq freetype libjpeg libpng zlib

CMD ['python3', 'manage.py', 'runserver', '0:80']
