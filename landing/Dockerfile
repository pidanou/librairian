FROM node:iron-alpine AS build


WORKDIR /landing

COPY package.json ./
COPY package-lock.json ./
RUN npm install
COPY . ./
RUN npm run build



# Use a lightweight web server image
FROM nginx:stable-alpine
COPY --from=build /landing/build /usr/share/nginx/html

