################# BASE IMAGE ######################
FROM --platform=linux/amd64 ubuntu:24.04 AS base

################## METADATA ######################
LABEL base_image="ubuntu:24.04"
LABEL version="1.0.2"
LABEL software="Cell Ranger"
LABEL software.version="10.1.0"
LABEL about.summary="Cell Ranger is a set of analysis pipelines that perform sample demultiplexing, barcode processing, single cell 3' and 5' gene counting, V(D)J transcript sequence assembly and annotation, and Feature Barcode analysis from 10x Genomics Chromium Single Cell data."
LABEL about.home="https://www.10xgenomics.com/support/software/cell-ranger/latest/getting-started"
LABEL about.documentation="https://www.10xgenomics.com/support/software/cell-ranger"
LABEL about.license_file="https://github.com/10XGenomics/cellranger/blob/main/LICENSE"
LABEL about.license="support.10xgenomics.com/license"
LABEL about.maintainer="Matthew Galbraith <matthew.galbraith@cuanschutz.edu>"

################## INSTALLATION ######################
ENV DEBIAN_FRONTEND="noninteractive"
ENV PACKAGES="tar wget ca-certificates"

RUN apt-get update && \
    apt-get install -y --no-install-recommends ${PACKAGES} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Signed download URL expires (see Expires=/Signature= params) and is tied to
# accepting the 10x EULA. Get a fresh link from:
# https://www.10xgenomics.com/support/software/cell-ranger/downloads
# then pass it at build time, e.g.:
#   docker build --build-arg CRANGER_URL="https://cf.10xgenomics.com/releases/cell-exp/cellranger-10.1.0.tar.xz?Expires=...&Signature=..." .
ARG CRANGER_URL

# NOT USED:
# Copy from parent dir and unpack downloaded Cell Ranger archive:
# COPY cellranger-10.1.0.tar.xz /
# RUN tar -xvf cellranger-10.1.0.tar.xz

RUN wget -O cellranger-10.1.0.tar.xz "${CRANGER_URL}"

RUN tar -xvf cellranger-10.1.0.tar.xz


################## 2ND STAGE ######################
FROM --platform=linux/amd64 ubuntu:24.04
ENV DEBIAN_FRONTEND="noninteractive"

# RUN apt-get update && \
#     apt-get install -y --no-install-recommends ${PACKAGES} && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=base /cellranger-10.1.0/ /opt/cellranger-10.1.0

ENV PATH=/opt/cellranger-10.1.0:$PATH