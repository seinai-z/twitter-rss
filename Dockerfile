FROM zenika/alpine-chrome:with-puppeteer-xvfb AS runner

USER root

# Install Node 22
RUN apk add --no-cache curl && \
    curl -fsSL https://unofficial-builds.nodejs.org/download/release/v22.14.0/node-v22.14.0-linux-x64-musl.tar.xz | tar -xJ -C /usr/local --strip-components=1 && \
    apk del curl

# Make sure the correct node is used
ENV PATH="/usr/local/bin:$PATH"

RUN node -v && yarn -v

WORKDIR /app

COPY package.json yarn.lock ./

RUN echo "network-timeout 600000" > .yarnrc && \
    yarn install --frozen-lockfile && \
    yarn cache clean

COPY src/ src/
COPY tsconfig.json .
COPY entrypoint.sh .
COPY template.html .

RUN chmod +x entrypoint.sh

ENV NODE_ENV=production
ENV TZ=Asia/Tokyo
ENV DISPLAY=:99
ENV CHROMIUM_PATH=/usr/bin/chromium-browser
ENV API_PORT=80
ENV SEARCH_WORD_PATH=/data/searches.json
ENV LOG_DIR=/data/logs/
ENV USER_DATA_DIRECTORY=/data/userdata/
ENV DEBUG_RESPONSE_DIRECTORY=/data/responses/

ENTRYPOINT ["tini", "--"]
CMD ["/app/entrypoint.sh"]
