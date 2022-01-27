FROM ubuntu:20.04

# Setup
RUN apt-get update && apt-get install -y unzip xz-utils git openssh-client curl python3 && apt-get upgrade -y && rm -rf /var/cache/apt

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter channel master
RUN flutter upgrade
RUN flutter config --enable-web
RUN flutter doctor -v

# Copy files to container and get all the dependencies
COPY . /usr/local/bin/app
WORKDIR /usr/local/bin/app
RUN flutter pub get
RUN flutter build web

# Document the exposed port and start server
EXPOSE 8080
RUN apt-get install dos2unix
RUN dos2unix /usr/local/bin/app/server/server.sh

# Set the server startup script as executable
RUN  ["chmod", "+x", "/usr/local/bin/app/server/server.sh"]
ENTRYPOINT [ "/usr/local/bin/app/server/server.sh" ]
