FROM python:3.9-alpine3.13
LABEL maintainer="leonardosanch@gmail.com"

ENV PYTHONUNBUFFERED=1

# Copiamos los archivos de requerimientos
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

WORKDIR /app
EXPOSE 8000

# Argumento de entorno para desarrollo
ARG DEV=false

# Configurar el entorno virtual y las dependencias
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
    build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then \
    /py/bin/pip install -r /tmp/requirements.dev.txt; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps

# Crear el usuario 'django-user' y cambiar los permisos de /app
RUN adduser -D django-user && \
    chown -R django-user /app

# Agregar el entorno virtual a la variable de entorno PATH
ENV PATH="/py/bin:$PATH"

# Ejecutar el contenedor como el usuario 'django-user'
USER django-user
