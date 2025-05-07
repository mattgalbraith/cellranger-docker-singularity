################# BASE IMAGE ######################
FROM --platform=linux/amd64 ubuntu:24.04 as base

################## METADATA ######################
LABEL base_image="ubuntu:24.04"
LABEL version="1.0.1"
LABEL software="Cell Ranger"
LABEL software.version="9.0.1"
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



# NOT USED:
# Copy from parent dir and unpack downloaded CellRanger archive:
# COPY cellranger-8.0.1.tar.gz /
# RUN tar -xzvf cellranger-8.0.1.tar.gz

RUN wget -O cellranger-9.0.1.tar.gz "https://cf.10xgenomics.com/releases/cell-exp/cellranger-9.0.1.tar.gz?Expires=1746688909&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA&Signature=I7mWgY4dsQOQFvFKGkFyR6BaM7FGiib9Gl-vu7Y6HI~5F8SMIKpNe2RmEVNqcvceSdGKcRmpUi0PPY7j3aYFnEi6d~KrxXA4LjRkWyT4wRwxA1rCYpaRHjT0zH0XlElyIQudErj0Adq9NLA-SamU-SgN3uB0NxAa-QIDAJaMhThZMvLSgndkGeA9Opr3VA5D6ZDFOfiIMl59Gy85pOdTIIh8d0bNA9ARplts62hukbE-YbrlwWDDgyItkGviXKca9eA-94PmtQBrQRNc~YtEoUCAI0TDZD03w40nKuWI3RG8VljwLgdoFnsaBf332FOa3pGlvmoGiZlaQCuEQ7o6Pw__"

RUN tar -xzvf cellranger-9.0.1.tar.gz


################## 2ND STAGE ######################
FROM --platform=linux/amd64 ubuntu:24.04
ENV DEBIAN_FRONTEND noninteractive
#ENV PACKAGES 

# RUN apt-get update && \
#     apt-get install -y --no-install-recommends ${PACKAGES} && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=base /cellranger-9.0.1/ /opt/cellranger-9.0.1

ENV PATH=/opt/cellranger-9.0.1:$PATH