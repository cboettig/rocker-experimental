FROM rocker/r-ver

RUN date

RUN apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libsqlite3-0 libtiff5 libcurl4 libcurl3-gnutls \
        wget ca-certificates

# Put this first as this is rarely changing
RUN \
    mkdir -p /usr/share/proj; \
    wget --no-verbose --mirror https://cdn.proj.org/; \
    rm -f cdn.proj.org/*.js; \
    rm -f cdn.proj.org/*.css; \
    mv cdn.proj.org/* /usr/share/proj/; \
    rmdir cdn.proj.org

COPY --from=rocker/proj:builder  /build/usr/share/proj/ /usr/share/proj/
COPY --from=rocker/proj:builder  /build/usr/include/ /usr/include/
COPY --from=rocker/proj:builder  /build/usr/bin/ /usr/bin/
COPY --from=rocker/proj:builder  /build/usr/lib/ /usr/lib/

## OSGEO
COPY ./install_geos.sh install_geos.sh
RUN bash install_geos.sh


USER root
RUN date
ARG JAVA_VERSION=17
ARG ARROW_SOVERSION=1300

# Update distro
RUN apt-get update -y && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
# PROJ dependencies
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libsqlite3-0 libtiff5 libcurl4 \
        wget curl unzip ca-certificates \
# GDAL dependencies
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libopenjp2-7 libcairo2 python3-numpy \
        libpng16-16 libjpeg-turbo8 libgif7 liblzma5 libgeos3.10.2 libgeos-c1v5 \
        libxml2 libexpat1 \
        libxerces-c3.2 libnetcdf-c++4 netcdf-bin libpoppler118 libspatialite7 librasterlite2-1 gpsbabel \
        libhdf4-0-alt libhdf5-103 libhdf5-cpp-103 poppler-utils libfreexl1 unixodbc mdbtools libwebp7 \
        liblcms2-2 libpcre3 libcrypto++8 libfyba0 \
        libkmlbase1 libkmlconvenience1 libkmldom1 libkmlengine1 libkmlregionator1 libkmlxsd1 \
        libmysqlclient21 libogdi4.1 libcfitsio9 openjdk-"$JAVA_VERSION"-jre \
        libzstd1 bash bash-completion libpq5 libssl3 \
        libarmadillo10 libpython3.10 libopenexr25 libheif1 \
        libdeflate0 libblosc1 liblz4-1 \
        libbrotli1 \
        libarchive13 \
        libaec0 \
        libspdlog1 \
        python-is-python3 \
        # pil for antialias option of gdal2tiles
        python3-pil \
    # Workaround bug in ogdi packaging
    && ln -s /usr/lib/ogdi/libvrf.so /usr/lib \
    # Install Arrow C++
    && DEBIAN_FRONTEND=noninteractive apt-get install -y -V ca-certificates lsb-release wget \
    && wget https://apache.jfrog.io/artifactory/arrow/$(lsb_release --id --short | tr 'A-Z' 'a-z')/apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y -V ./apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y -V libarrow${ARROW_SOVERSION} \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y -V libparquet${ARROW_SOVERSION} \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y -V libarrow-dataset${ARROW_SOVERSION} \
    && rm -rf /var/lib/apt/lists/*

# Attempt to order layers starting with less frequently varying ones

COPY --from=rocker/gdal:builder  /build_thirdparty/usr/ /usr/

ARG PROJ_INSTALL_PREFIX=/usr/local
COPY --from=rocker/gdal:builder  /tmp/proj_grids/* ${PROJ_INSTALL_PREFIX}/share/proj/

COPY --from=rocker/gdal:builder  /build${PROJ_INSTALL_PREFIX}/share/proj/ ${PROJ_INSTALL_PREFIX}/share/proj/
COPY --from=rocker/gdal:builder  /build${PROJ_INSTALL_PREFIX}/include/ ${PROJ_INSTALL_PREFIX}/include/
COPY --from=rocker/gdal:builder  /build${PROJ_INSTALL_PREFIX}/bin/ ${PROJ_INSTALL_PREFIX}/bin/
COPY --from=rocker/gdal:builder  /build${PROJ_INSTALL_PREFIX}/lib/ ${PROJ_INSTALL_PREFIX}/lib/

COPY --from=rocker/gdal:builder  /build/usr/share/java /usr/share/java
COPY --from=rocker/gdal:builder  /build/usr/share/gdal/ /usr/share/gdal/
COPY --from=rocker/gdal:builder  /build/usr/include/ /usr/include/
COPY --from=rocker/gdal:builder  /build_gdal_python/usr/ /usr/
COPY --from=rocker/gdal:builder  /build_gdal_version_changing/usr/ /usr/

RUN ldconfig

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libssl-dev libudunits2-dev libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages('sf', repos='https://cran.rstudio.com')"



