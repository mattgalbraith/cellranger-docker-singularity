################# BASE IMAGE ######################
FROM --platform=linux/amd64 ubuntu:24.04 as base

################## METADATA ######################
LABEL base_image="ubuntu:24.04"
LABEL version="1.0.0"
LABEL software="Cell Ranger"
LABEL software.version="8.0.1"
LABEL about.summary="Cell Ranger is a set of analysis pipelines that perform sample demultiplexing, barcode processing, single cell 3' and 5' gene counting, V(D)J transcript sequence assembly and annotation, and Feature Barcode analysis from 10x Genomics Chromium Single Cell data."
LABEL about.home="https://www.10xgenomics.com/support/software/cell-ranger/latest/getting-started"
LABEL about.documentation="https://www.10xgenomics.com/support/software/cell-ranger"
LABEL about.license_file="https://github.com/10XGenomics/cellranger/blob/main/LICENSE"
LABEL about.license="support.10xgenomics.com/license"

################## MAINTAINER ######################
MAINTAINER Matthew Galbraith <matthew.galbraith@cuanschutz.edu>

################## INSTALLATION ######################
ENV DEBIAN_FRONTEND noninteractive
ENV PACKAGES tar wget ca-certificates

RUN apt-get update && \
    apt-get install -y --no-install-recommends ${PACKAGES} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# File size: 702 MB
# md5sum: 1d08d8005b026fc1ca3c867bc67b2dbd

# NOT USED:
# RUN wget wget -O cellranger-8.0.1.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-8.0.1.tar.gz?Expires=1723610563&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA&Signature=U6zxnMjiCZEAB0io3TLdHxgzZ0SWwiDw7C9oUPmw3kN4tdsVWAzLAlF9rEwpG7j8tdqmhk5uMakMjGgCLSIYJOiFgaYa-M7064gWNxr4UNjX63SNo4vhyIflGsxLIAMXKAkjmQVL~RYWdgGsi7g-m5XugTaBCaGrloroi1X5NFIfR5MiKJ2k0~ajTZZHSdM5K-Mc6KSyKASyhq3gc3JPyCvaAM-KEDDLL42~5u9OHZM~9Cj6CQue~ru4VdsrpFgI0inIFAAqNFjQkSwHUDGUHX6HthNF6AJfl2eY1tcEPeX8ptH4IMXbTUy7CiedmXE3qXcbqoZPi1OCbIm9v32Ykw__" && \
# 	tar -xzvf BBMap_38.90.tar.gz

# Copy from parent dir and unpack downloaded CellRanger archive:
COPY cellranger-8.0.1.tar.gz /
RUN tar -xzvf cellranger-8.0.1.tar.gz


################## 2ND STAGE ######################
FROM --platform=linux/amd64 ubuntu:24.04
ENV DEBIAN_FRONTEND noninteractive
#ENV PACKAGES 

# RUN apt-get update && \
#     apt-get install -y --no-install-recommends ${PACKAGES} && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=base /cellranger-8.0.1/ /opt/cellranger-8.0.1

ENV PATH=/opt/cellranger-8.0.1:$PATH