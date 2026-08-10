<!-- NO LONGER tracking CI for this repo
[![Docker Image CI](https://github.com/mattgalbraith/cellranger-docker-singularity/actions/workflows/docker-image.yml/badge.svg)](https://github.com/mattgalbraith/cellranger-docker-singularity/actions/workflows/docker-image.yml)
-->

# cellranger-docker-singularity

## Build Docker container for Cell Ranger and (optionally) convert to Apptainer/Singularity.

A set of analysis pipelines that perform sample demultiplexing, barcode processing, single cell 3' and 5' gene counting, V(D)J transcript sequence assembly and annotation, and Feature Barcode analysis from single cell data.

#### Requirements:
You will need to agree to terms and obtain personal download link for Cell Ranger here:
https://www.10xgenomics.com/support/software/cell-ranger/downloads  
Running Cell Ranger requires at least 8 CPU cores, preferably 16, and at least 64 GB of RAM, preferably 128.  
Global File Limit: 10k per GB RAM. User Limit: 64 times the number of CPUs.  
See also: https://www.10xgenomics.com/support/software/cell-ranger/latest/tutorials/cr-tutorial-in#sitecheck

#### Build platform note:
This image is intended to be built on a MacBook Pro (Apple Silicon, arm64) but run on a Linux HPC (x86_64). Cell Ranger does not ship arm64 binaries, so the image must be built and tagged explicitly for `linux/amd64` — otherwise Docker Desktop will build natively for arm64 and the binaries will fail (or silently fall back to slow emulation) on the HPC. Pass `--platform=linux/amd64` on every `docker build` command below; the Dockerfile itself also pins `--platform=linux/amd64` on its `FROM` lines as a second safeguard.

### Reference data.
See https://www.10xgenomics.com/support/software/cell-ranger/downloads for latest  
https://www.10xgenomics.com/support/software/cell-ranger/latest/release-notes/cr-reference-release-notes for older  
Transcriptome reference is optional for Flex analysis in Cell Ranger v9.0+

Human GRCh38 (GENCODE v44/Ensembl110) - 2024-A:
```
wget https://cf.10xgenomics.com/supp/cell-exp/refdata-gex-GRCh38-2024-A.tar.gz
```
Mouse GRCm39 (GENCODE vM33/Ensembl110) - 2024-A:
```
wget https://cf.10xgenomics.com/supp/cell-exp/refdata-gex-GRCm39-2024-A.tar.gz
```
Human GRCh38 (GENCODE v32/Ensembl98) - 2020-A:
```
wget https://cf.10xgenomics.com/supp/cell-exp/refdata-gex-GRCh38-2020-A.tar.gz
```
Mouse mm10 (GENCODE vM23/Ensembl98) - 2020-A:
```
wget https://cf.10xgenomics.com/supp/cell-exp/refdata-gex-mm10-2020-A.tar.gz
```

**For purposes of reproducibility, the exact build steps are provided here:**  
https://www.10xgenomics.com/support/software/cell-ranger/downloads/cr-ref-build-steps

### Probe Sets.
The Single Cell Flex Fixed RNA Profiling assays use probes targeting protein coding genes in the human or mouse transcriptomes. Each probe consists of a pair of oligonucleotides hybridized to the targeted transcript and are subsequently ligated.  
Not all probe sets are compatible with every transcriptome reference. Compatibility depends on the version of Cell Ranger you are using.  
See compatibility table [here](https://www.10xgenomics.com/support/flex-gene-expression/documentation/steps/probe-sets/chromium-frp-probe-sets-overview).

Probe Barcode Sequences:
```
wget https://cf.10xgenomics.com/supp/cell-exp/probeset/probe-barcodes-fixed-rna-profiling.txt
```

Human Transcriptome Probe Sets v1.1 (compatible with Cell Ranger Version v9.0+):  
https://www.10xgenomics.com/support/flex-gene-expression/documentation/steps/probe-sets/chromium-frp-human-transcriptome-probe-set-1-1  
https://www.10xgenomics.com/support/flex-gene-expression/documentation/steps/probe-sets/chromium-frp-probe-set-files#download-probe-files
```
wget https://cf.10xgenomics.com/supp/cell-exp/probeset/Chromium_Human_Transcriptome_Probe_Set_v1.1.0_GRCh38-2024-A.csv
wget https://cf.10xgenomics.com/supp/cell-exp/probeset/Chromium_Human_Transcriptome_Probe_Set_v1.1.0_GRCh38-2024-A.probe_metadata.tsv
wget https://cf.10xgenomics.com/supp/cell-exp/probeset/Chromium_Human_Transcriptome_Probe_Set_v1.1.0_GRCh38-2024-A.bed
wget https://cf.10xgenomics.com/supp/cell-exp/probeset/Chromium_Human_Transcriptome_Probe_Set_v1.1.0_GRCh38-2024-A.offtarget.csv
```

Mouse Transcriptome Probe Sets v1.1.1 (compatible with Cell Ranger Version v9.0+):  
https://www.10xgenomics.com/support/flex-gene-expression/documentation/steps/probe-sets/chromium-frp-mouse-transcriptome-probe-set-1-1  
https://www.10xgenomics.com/support/flex-gene-expression/documentation/steps/probe-sets/chromium-frp-probe-set-files#download-probe-files
```
wget https://cf.10xgenomics.com/supp/cell-exp/probeset/Chromium_Mouse_Transcriptome_Probe_Set_v1.1.1_GRCm39-2024-A.csv
wget https://cf.10xgenomics.com/supp/cell-exp/probeset/Chromium_Mouse_Transcriptome_Probe_Set_v1.1.1_GRCm39-2024-A.probe_metadata.tsv
wget https://cf.10xgenomics.com/supp/cell-exp/probeset/Chromium_Mouse_Transcriptome_Probe_Set_v1.1.1_GRCm39-2024-A.bed
wget https://cf.10xgenomics.com/supp/cell-exp/probeset/Chromium_Mouse_Transcriptome_Probe_Set_v1.1.1_GRCm39-2024-A.offtarget.csv
```

### A note on automated cell type annotation
Starting in Cell Ranger v10.1, `cellranger count`/`cellranger multi` runs the **Pan-Human Azimuth** cell type annotation model **locally by default** for human datasets — no 10x Cloud account, cloud auth token, or outbound network access required. The older cloud-based model (`--cell-annotation-model`) still requires `--tenx-cloud-token-path` and sends data to 10x Cloud Analysis; stick with the local Azimuth default unless you specifically need that. Use `--disable-cell-annotation` to skip annotation entirely.  
Note: as of v10.1, t-SNE plots are no longer generated by default (UMAP remains default) — use `--enable-tsne` if you need them.


## Build docker container:

### 1. For Cellranger installation instructions:
https://www.10xgenomics.com/support/software/cell-ranger/latest/tutorials/cr-tutorial-in


### 2. Build the Docker Image

#### To build image from the command line:
``` bash
# Assumes current working directory is the top-level cellranger-docker-singularity directory
# --platform=linux/amd64 forces an x86_64 build even when building on Apple Silicon,
# since Cell Ranger has no arm64 binaries and this image needs to run on a Linux HPC
docker build --platform=linux/amd64 \
  --build-arg CRANGER_URL="<your signed download URL from 10x>" \
  -t cellranger:10.1.0 . # tag should match software version
```

#### To test this tool from the command line:
``` bash
docker run --platform=linux/amd64 --rm -it cellranger:10.1.0 cellranger --help # should print help information

# Optional: Run a sitecheck and perform a testrun (these will only run on amd64 system)
cellranger sitecheck > cellranger_sitecheck.txt # see Requirements section above
cellranger testrun --id=check_install # Pipestance completed successfully!
```
NB: `sitecheck`/`testrun` require a genuine AVX-capable x86_64 CPU — they will fail with a SIGILL-style error (`telemetry collector terminated by signal: 4`) if run under QEMU emulation on Apple Silicon. Save these checks for the HPC.

## Optional: Conversion of Docker image to Singularity

### 3. Build a Docker image to run Singularity
(skip if this image is already on your system)  
https://github.com/mattgalbraith/singularity-docker

### 4. Save Docker image as tar and convert to sif (using singularity run from Docker container)
``` bash
docker images
docker save <Image_ID> -o cellranger_10.1.0-docker.tar && gzip cellranger_10.1.0-docker.tar # = IMAGE_ID of <tool> image
docker run -v "$PWD":/data --rm -it singularity:1.3.4 bash -c "singularity build /data/cellranger_10.1.0.sif docker-archive:///data/cellranger_10.1.0-docker.tar.gz"
```
NB: On Apple M1/M2/M3/M4 machines, always pass `--platform=linux/amd64` (as above) when building and saving the image — otherwise the sif may get built with arm64 and will fail to run on the (x86_64) HPC. The `singularity build` conversion step itself does not need to run under `--platform=linux/amd64` — it only repackages the amd64 image's layers from the tar, it doesn't execute them — so a local arm64 `singularity` image can still be used to produce a valid amd64 sif.

Next, transfer the cellranger_10.1.0.sif file to the system on which you want to run Cell Ranger from the Singularity container

### 5. Test singularity container on (HPC) system with Singularity/Apptainer available
``` bash
# set up path to the Singularity container
CELLRANGER_SIF=path/to/cellranger_10.1.0.sif

# Test that Cell Ranger can run from Singularity container
singularity run $CELLRANGER_SIF cellranger --help # depending on system/version, singularity may be called apptainer
```