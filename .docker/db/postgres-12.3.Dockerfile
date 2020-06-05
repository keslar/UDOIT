ARG TARGET_VERSION
FROM postgres:12.3-alpine

# Time Zone
ARG TZ

# Paraneters
ARG PASSWORD
ARG USER 
ARG NAME
ARG DATA_DIRECTORY

# Constants
ARG SERVICE_DIR="./db"
ARG DISTRO="Alpine"

# Set environment variable necessary for postgres, 
# from configuration variables
ENV POSTGRES_PASSWORD  ${PASSWORD}
ENV POSTGRES_USER      ${USER}
ENV POSTGRES_DB        ${NAME}
ENV PGDATA             ${DATA_DIRECTORY}

# Copy over setup scripts to the container
COPY ./.shared/scripts/       /tmp/scripts/
COPY ${SERVICE_DIR}/scripts/  /tmp/scripts/
RUN chmod +x -R /tmp/scripts/

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
RUN /tmp/scripts/setup_postgres.sh ${POSTGRES_PASSWORD} ${POSTGRES_USER} ${POSTGRES_DB} ${PGDATA}
VOLUME ${PGDATA}

# entrypoint
RUN mkdir -p /bin/docker-entrypoint/ \
 && cp /tmp/scripts/docker-entrypoint/* /bin/docker-entrypoint/ \
 && chmod +x -R /bin/docker-entrypoint/ \
;

RUN /tmp/scripts/cleanup.sh

ENTRYPOINT ["/bin/docker-entrypoint/resolve-docker-host-ip.sh","postgres"]

EXPOSE ${DB_PORT}