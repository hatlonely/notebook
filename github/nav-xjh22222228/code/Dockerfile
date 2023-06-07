FROM node:lts-alpine3.12 AS build

RUN apk add git

RUN git clone --depth=1 https://github.com/xjh22222228/nav.git && \
    cd nav && yarn && \
    yarn build

FROM nginx:1.24
COPY --from=build /nav/dist /usr/share/nginx/html
