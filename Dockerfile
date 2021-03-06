############################
# Get ANTs from DockerHub
# Pick a specific version, once they starting versioning
FROM pennbbl/ants:0.0.1
ENV ANTs_VERSION 0.0.1

############################
# Install basic dependencies
RUN apt-get update && apt-get -y install \
    jq \
    tar \
    zip \
    build-essential

# Prepare environment
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    python2.7 \
                    curl \
                    bzip2 \
                    ca-certificates \
                    xvfb \
                    build-essential \
                    autoconf \
                    libtool \
                    pkg-config \
                    git && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -y --no-install-recommends \
                    nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN curl -sSLO https://repo.continuum.io/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh && \
    bash Miniconda3-4.5.11-Linux-x86_64.sh -b -p /usr/local/miniconda && \
    rm Miniconda3-4.5.11-Linux-x86_64.sh

ENV PATH=/usr/local/miniconda/bin:$PATH \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONNOUSERSITE=1

# Install python, pandas, os, and nibabel
RUN conda install -y python=3.7.1 \
                      pip=19.1 \
    chmod -R a+rX /usr/local/miniconda; sync && \
    chmod +x /usr/local/miniconda/bin/*; sync && \
    conda build purge-all; sync && \
    conda clean -tipsy && sync

RUN pip install pandas==1.1.4
RUN pip install nibabel==3.2.0
RUN pip install scipy==1.6.1

############################

RUN mkdir /data/input
RUN mkdir /data/output
RUN mkdir /data/input/dataverse_files
RUN mkdir /data/input/templates
RUN mkdir /data/input/antssst
RUN mkdir /data/input/fmriprep
RUN mkdir /scripts

COPY MNI-1x1x1Head.nii.gz /data/input/templates/MNI-1x1x1Head.nii.gz
COPY run.sh /scripts/run.sh
COPY minc-toolkit-extras /scripts/minc-toolkit-extras
COPY OASIS_PAC /data/input/OASIS_PAC
COPY tissueClasses.csv /data/input/tissueClasses.csv

COPY antsMultivariateTemplateConstruction2.sh /scripts/antsMultivariateTemplateConstruction2.sh
COPY minMax.py /scripts/minMax.py
COPY masks.py /scripts/masks.py
COPY scaleMasks.py /scripts/scaleMasks.py
COPY cleanWarpedMasks.py /scripts/cleanWarpedMasks.py

RUN chmod -R go+rX /data/*
RUN chmod +x /scripts/*

#USER antsuser
#WORKDIR /home/antsuser

# Set the entrypoint using exec format
ENTRYPOINT ["/scripts/run.sh"]
