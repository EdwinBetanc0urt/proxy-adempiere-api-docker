FROM node:10-alpine3.11

LABEL maintainer="EdwinBetanc0urt@outlook.com" \
	description="Proxy ADempiere API RESTful"

ARG BASE_VERSION="rt-2.1"
ARG URL_REPO="https://github.com/adempiere/proxy-adempiere-api/archive"
ARG REPO_NAME="proxy-adempiere-api"

# Init ENV with default values
ENV VS_ENV=prod \
	BINARY_NAME="proxy-adempiere-api-$BASE_VERSION" \
	SERVER_HOST="localhost" \
	SERVER_PORT=8085 \
	ES_HOST="localhost" \
	ES_PORT=9200 \
	AD_DEFAULT_HOST="localhost" \
	AD_DEFAULT_PORT=50059 \
	AD_TOKEN="adempiere_token" \
	AD_STORE_TOKEN="adempiere_store_token" \
	API_URL_IMAGES="localhost" \
	API_HTTP_BASED="false" \
	STORE_URL_IMAGES="localhost" \
	STORE_HTTP_BASED="false"

# Add system dependencies
RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf && \
	rm -rf /var/cache/apk/* && \
	apk update && \
	apk upgrade musl && \
	apk add \
		--virtual .build-deps \
		curl \
		git \
		python \
		make \
		g++ \
		ca-certificates \
		wget

# Download and uncompress project
RUN mkdir -p /var/www/ && \
	cd /var/www/ && \
	echo "Downloading ... $URL_REPO/$BASE_VERSION.zip" && \
	curl --output "$BINARY_NAME.zip" \
		-L "$URL_REPO/$BASE_VERSION.zip" && \
	unzip -o $BINARY_NAME.zip && \
	mv $BINARY_NAME $REPO_NAME && \
	rm $BINARY_NAME.zip && \
	cd $REPO_NAME && \
	cp -rf ./packages/default-vsf ./src/modules && \
	cp ./docker/proxy-api/proxy-api.sh /usr/local/bin/ && \
	cp ecosystem.json /var/www/  && \
	cp package.json /var/www/  && \
	cp tsconfig.json /var/www/  && \
	cp nodemon.json /var/www/  && \
	cp graphql-schema-linter.config.js /var/www/  && \
	cp tsconfig.build.json /var/www/  && \
	yarn install --no-cache && \
	apk del .build-deps && \
	rm -rf /var/cache/apk/* \
		/var/lib/apt/list/* \
		/tmp/*

COPY default.json /var/www/proxy-adempiere-api/config/
COPY start.sh /var/www/proxy-adempiere-api/

WORKDIR /var/www/proxy-adempiere-api/

# Start app
CMD sh start.sh
