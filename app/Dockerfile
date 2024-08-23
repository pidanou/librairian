FROM ghcr.io/cirruslabs/flutter:3.22.3 AS build-env


WORKDIR /app/

COPY . /app/

RUN flutter build web --dart-define-from-file dotenv --web-renderer html



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

