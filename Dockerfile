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


############################

RUN mkdir /data/input
RUN mkdir /data/output
RUN mkdir /data/input/dataverse_files
RUN mkdir /scripts
COPY run.sh /scripts/run.sh
COPY masks.py /scripts/masks.py
COPY averageMasks.py /scripts/averageMasks.py
RUN chmod +x /scripts/*

# Set the entrypoint
ENTRYPOINT /scripts/run.sh
