FROM erlang:23

ARG APP_NAME=fleet_mgmt
ARG APP_VSN=0.1.0
ARG MIX_ENV=prod

ENV APP_NAME=${APP_NAME} \
    APP_VSN=${APP_VSN} \
    MIX_ENV=${MIX_ENV} \
	LANG=C.UTF-8

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y git bash

WORKDIR /opt/app

COPY fleet_mgmt.zip /opt/app/

RUN mkdir -p /opt/build && \
  unzip /opt/app/fleet_mgmt.zip -d /opt/build && \
  cd /opt && \
  chmod +x -R build/
 
WORKDIR /opt/build

CMD trap 'exit' INT; /opt/build/${APP_NAME} -c coupons.json