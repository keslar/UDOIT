ARG TARGET_VERSION
FROM php:${TARGET_VERSION}-fpm

# Timezone
ARG TZ

# Paraneters
ARG TYPE
ARG HOST
ARG PASSWORD
ARG USER 
ARG NAME
ARG DIRECTORY
ARG PORT

# Constants
ARG SERVICE_DIR="./app"
ARG DISTRO="Debian"

# Copy over setup scripts to the container
COPY ./.shared/scripts/       /tmp/scripts/
COPY ${SERVICE_DIR}/scripts/  /tmp/scripts/
RUN chmod +x -R /tmp/scripts/

# Fix an error in autoconf
ARG DEBIAN_FRONTEND=noninteractive

# set timezone
RUN /tmp/scripts/set_timezone.sh ${TZ}

# install software common to all contianers
RUN /tmp/scripts/install_common_software.sh

# install software specific to this container
RUN /tmp/scripts/install_software.sh

# run configuration steps
# COPY config files from ${SERVICE_DIR}/applicationname/directory/file
# run script or commands to update config files
# Create data directory
RUN git clone 
COPY ./app/config/localConfig.template.php /var/www/html/config/localConfig.php
COPY ./app/composer/ /var/www/html/
RUN ls /var/www/html/
RUN /tmp/scripts/setup_php-fpm.sh "${TYPE}" "${HOST}" "${PORT}" "${PASSWORD}" "${USER}" "${NAME}" "${DIRECTORY}"
VOLUME ${DIRECTORY}

# entrypoint
RUN mkdir -p /bin/docker-entrypoint/ \
 && cp /tmp/scripts/docker-entrypoint/* /bin/docker-entrypoint/ \
 && chmod +x -R /bin/docker-entrypoint/ \
;

RUN /tmp/scripts/cleanup.sh

ENTRYPOINT ["/bin/docker-entrypoint/resolve-docker-host-ip.sh","postgres"]

EXPOSE ${PORT}