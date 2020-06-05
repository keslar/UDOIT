FROM postgres:alpine
ARG TZ
ARG SERVICE_DIR="./db"
ARG DISTRO="Alpine"
# from configuration variables
#ARG DB_PASSWORD
#ARG DB_USER
#ARG DB_NAME
#ARG DB_DATA_DIRECTORY
# Set environment variable necessary for postgres, 
# from configuration variables
ENV POSTGRES_PASSWORD  ${DB_PASSWORD}
ENV POSTGRES_USER      ${DB_USER}
ENV POSTGRES_DB        ${DB_NAME}
ENV PGDATA             ${DB_DATA_DIRECTORY}
RUN echo "${DB_PASSWORD}"
RUN echo "${DB_USER}"
RUN echo "${DB_NAME}"
RUN echo "${DB_DATA_DIRECTORY}"
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