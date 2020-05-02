# adapted from https://www.bjoern-bos.de/post/learn-how-to-dockerize-a-shinyapp-in-7-steps/
# Install R version 3.6.3
FROM r-base:3.6.3

# Install Ubuntu packages
RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev/unstable \
    libxt-dev \
    libssl-dev

# Download and install ShinyServer (latest version)
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb

RUN sudo apt-get -y install libudunits2-dev libv8-dev libgdal-dev gdal-bin libproj-dev proj-data proj-bin libgeos-dev libjq-dev libprotobuf-dev protobuf-compiler python3-geojson

# provide write access to library folder
RUN chmod a+rwx -R usr/local/lib/R/site-library #make library directory writable

# Copy configuration files into the Docker image
COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY /app /srv/shiny-server/

# install all required packages
RUN Rscript /srv/shiny-server/installs.R

# Make the ShinyApp available at port 80
EXPOSE 80

# Copy further configuration files into the Docker image
COPY shiny-server.sh /usr/bin/shiny-server.sh
RUN chmod +x /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]
