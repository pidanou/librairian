FROM debian:latest AS build-env

RUN apt-get update

RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 sed

RUN apt-get clean

RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

ENV PATH="${PATH}:/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin"

RUN flutter doctor -v

RUN flutter channel master

RUN flutter upgrade

RUN mkdir /app/

COPY . /app/

WORKDIR /app/
RUN flutter build web



# Use a lightweight web server image
FROM nginx:alpine

# Remove the default Nginx configuration file
RUN rm /etc/nginx/conf.d/default.conf

# Copy the custom Nginx configuration file
COPY ./nginx.conf /etc/nginx/conf.d/

# Copy the built files from the Flutter build output
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose port 80 to the outside world
EXPOSE 80

# Start Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]

