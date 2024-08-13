[![Docker Image CI](https://github.com/mattgalbraith/cellranger-docker-singularity/actions/workflows/docker-image.yml/badge.svg)](https://github.com/mattgalbraith/cellranger-docker-singularity/actions/workflows/docker-image.yml)

# cellranger-docker-singularity

## Build Docker container for Cell Ranger and (optionally) convert to Apptainer/Singularity.  

A set of analysis pipelines that perform sample demultiplexing, barcode processing, single cell 3' and 5' gene counting, V(D)J transcript sequence assembly and annotation, and Feature Barcode analysis from single cell data.  
  
#### Requirements:
You will need to agree to terms and obtain personal download link for Cell Ranger here:
https://www.10xgenomics.com/support/software/cell-ranger/downloads  
Running Cell Ranger requires at least 8 CPU cores, preferably 16, and at least 64 GB of RAM, preferably 128.  
Global File Limit: 10k per GB RAM. User Limit: 64 times the number of CPUs.  
See also: https://www.10xgenomics.com/support/software/cell-ranger/latest/tutorials/cr-tutorial-in#sitecheck  

### Reference data.  
See https://www.10xgenomics.com/support/software/cell-ranger/downloads  

Human reference (GRCh38) - 2024-A:
```
wget "https://cf.10xgenomics.com/supp/cell-exp/refdata-gex-GRCh38-2024-A.tar.gz"
```
Mouse reference (GRCm39) - 2024-A:
```
wget "https://cf.10xgenomics.com/supp/cell-exp/refdata-gex-GRCm39-2024-A.tar.gz"
```
Combined Human (GRCh38) and mouse (GRCm39) reference - 2024-A:
```
wget "https://cf.10xgenomics.com/supp/cell-exp/refdata-gex-GRCh38_and_GRCm39-2024-A.tar.gz"
```
**For purposes of reproducibility, the exact build steps are provided here:**  
https://www.10xgenomics.com/support/software/cell-ranger/downloads/cr-ref-build-steps  

### Probe Sets. 
The Single Cell Fixed RNA Profiling assays use probes targeting protein coding genes in the human or mouse transcriptomes. Each probe consists of a pair of oligonucleotides hybridized to the targeted transcript and are subsequently ligated.  

Probe Barcode Sequences:
```
wget https://cf.10xgenomics.com/supp/cell-exp/probeset/probe-barcodes-fixed-rna-profiling.txt
```

Human Transcriptome:
```
wget https://cf.10xgenomics.com/supp/cell-exp/probeset/Chromium_Human_Transcriptome_Probe_Set_v1.0.1_GRCh38-2020-A.csv
```
```
wget https://cf.10xgenomics.com/supp/cell-exp/probeset/Chromium_Human_Transcriptome_Probe_Set_v1.0_GRCh38-2020-A.bed
```
```
wget https://cf.10xgenomics.com/supp/cell-exp/probeset/Chromium_Human_Transcriptome_Probe_Set_v1.0.1_GRCh38-2020-A.probe_metadata.tsv
```
```
wget https://cf.10xgenomics.com/supp/cell-exp/probeset/Chromium_Human_Transcriptome_Probe_Set_v1.0_GRCh38-2020-A.offtarget.csv
```
  
Mouse Transcriptome:
```
wget https://cf.10xgenomics.com/supp/cell-exp/probeset/Chromium_Mouse_Transcriptome_Probe_Set_v1.0.1_mm10-2020-A.csv
```
```
wget https://cf.10xgenomics.com/supp/cell-exp/probeset/Chromium_Mouse_Transcriptome_Probe_Set_v1.0_mm10-2020-A.bed
```
```
wget https://cf.10xgenomics.com/supp/cell-exp/probeset/Chromium_Mouse_Transcriptome_Probe_Set_v1.0_mm10-2020-A.probe_metadata.tsv
```
```
wget https://cf.10xgenomics.com/supp/cell-exp/probeset/Chromium_Mouse_Transcriptome_Probe_Set_v1.0_mm10-2020-A.offtarget.csv
```

  
## Build docker container:  

### 1. For TOOL installation instructions:  
https://www.10xgenomics.com/support/software/cell-ranger/latest/tutorials/cr-tutorial-in    


### 2. Build the Docker Image

#### To build image from the command line:  
``` bash
# Assumes current working directory is the top-level cellranger-docker-singularity directory
docker build -t cellranger:8.0.1 . # tag should match software version
```
* Can do this on [Google shell](https://shell.cloud.google.com)

#### To test this tool from the command line:
``` bash
docker run --rm -it cellranger:8.0.1 cellranger --help # should print help information

# Optional: Run a sitecheck and perform a testrun
cellranger sitecheck > cellranger_sitecheck.txt # see Requirements section above
cellranger testrun --id=check_install # Pipestance completed successfully!
```

## Optional: Conversion of Docker image to Singularity  

### 3. Build a Docker image to run Singularity  
(skip if this image is already on your system)  
https://github.com/mattgalbraith/singularity-docker

### 4. Save Docker image as tar and convert to sif (using singularity run from Docker container)  
``` bash
docker images
docker save <Image_ID> -o cellranger_8.0.1-docker.tar && gzip cellranger_8.0.1-docker.tar # = IMAGE_ID of <tool> image
docker run -v "$PWD":/data --rm -it singularity:1.3.2 bash -c "singularity build /data/cellranger_8.0.1.sif docker-archive:///data/cellranger_8.0.1-docker.tar.gz"
```
NB: On Apple M1/M2 machines ensure Singularity image is built with x86_64 architecture or sif may get built with arm64  

Next, transfer the cellranger_8.0.1.sif file to the system on which you want to run Cell Ranger from the Singularity container  

### 5. Test singularity container on (HPC) system with Singularity/Apptainer available  
``` bash
# set up path to the Singularity container
CELLRANGER_SIF=path/to/cellranger_8.0.1.sif

# Test that Cell Ranger can run from Singularity container
singularity run $CELLRANGER_SIF cellranger --help # depending on system/version, singularity may be called apptainer
```