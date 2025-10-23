# HOW TO DEPLOY THE FORK
# aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com
# docker build . -t <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com/observability/statsd
# docker push <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com/observability/statsd

FROM node:18.20.3

# Update OS packages to reduce vulnerabilities
RUN apt-get update && apt-get upgrade -y && apt-get clean

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Install python
# RUN apk add --no-cache --update g++ gcc libgcc libstdc++ linux-headers make python

# Setup node envs
ARG NODE_ENV
ENV NODE_ENV $NODE_ENV

# Install dependencies
COPY package.json /usr/src/app/
RUN npm install --omit dev && npm cache clean --force

# Copy required src (see .dockerignore)
COPY . /usr/src/app

# Set graphite hostname to "graphite"
RUN \
  ls -la && \
  cp -v exampleConfig.js config.js && \
  sed -i 's/graphite.example.com/graphite/' config.js

# Expose required ports
EXPOSE 8125/udp
EXPOSE 8126

# Start statsd
ENTRYPOINT [ "node", "stats.js", "config.js" ]
