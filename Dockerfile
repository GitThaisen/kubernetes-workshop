FROM mhart/alpine-node:9.1.0

LABEL maintainer Markus Voss <markus.voss@nrk.no>

# Change timezone
RUN apk add --update tzdata
ENV TZ=Europe/Oslo

# Clean APK cache
RUN rm -rf /var/cache/apk/*

# Add .npmrc so we can read private @nrk repositories on npm Orgs
# https://docs.npmjs.com/private-modules/docker-and-private-modules
ARG NPM_TOKEN
RUN echo '//registry.npmjs.org/:_authToken=${NPM_TOKEN}' >> /root/.npmrc

# install node modules using a docker cache layer (obs: must run before COPY)
# http://bitjudo.com/blog/2014/03/13/building-efficient-dockerfiles-node-dot-js/
RUN mkdir /tmp/npm
COPY package.json package-lock.json README.md /tmp/npm/
RUN cd /tmp/npm && \
    npm install --no-progress --loglevel error --registry "https://registry.npmjs.org"

# Set working dir
WORKDIR /usr/src/app
ADD . /usr/src/app

# Copy cached node_modules
RUN cp -a /tmp/npm/node_modules .

# Build and remove development dependencies
RUN npm run build
# RUN npm prune --production
RUN npm cache clean --force
# Cleanup .npmrc to avoid errors when NPM_TOKEN is not set in runtime
RUN rm -f /root/.npmrc

CMD ["npm", "start"]

EXPOSE 8090
