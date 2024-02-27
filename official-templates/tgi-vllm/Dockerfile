
FROM ghcr.io/huggingface/text-generation-inference as tgi

FROM nvidia/cuda:12.1.1-devel-ubuntu22.04
# https://github.com/huggingface/text-generation-inference/blob/main/Dockerfile

# https://github.com/huggingface/text-generation-inference/blob/bf700e7eef4771f280c19dbc7270c8c7c20efbbc/Dockerfile#L43
# they also have it on 3.10
ENV PYTHON_VERSION=3.10

# https://github.com/huggingface/text-generation-inference/blob/bf700e7eef4771f280c19dbc7270c8c7c20efbbc/Dockerfile#L242C1-L254C22
# we replace sagemaker

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash

# Set the working directory
WORKDIR /

# Create workspace directory
RUN mkdir /workspace

####
####
####
# install mamba and TGI COPY

ARG PYTORCH_VERSION=2.1.1
ARG PYTHON_VERSION=3.10
# Keep in sync with `server/pyproject.toml
ARG CUDA_VERSION=12.1
ARG MAMBA_VERSION=23.3.1-1
ARG CUDA_CHANNEL=nvidia
ARG INSTALL_CHANNEL=pytorch
ARG MAMBA_VERSION=23.3.1-1
ARG TARGETPLATFORM=x86_64
RUN case ${TARGETPLATFORM} in \
         "linux/arm64")  MAMBA_ARCH=aarch64  ;; \
         *)              MAMBA_ARCH=x86_64   ;; \
    esac && \
    curl -fsSL -v -o ~/mambaforge.sh -O  "https://github.com/conda-forge/miniforge/releases/download/${MAMBA_VERSION}/Mambaforge-${MAMBA_VERSION}-Linux-${MAMBA_ARCH}.sh"
RUN chmod +x ~/mambaforge.sh && \
    bash ~/mambaforge.sh -b -p /opt/conda && \
    rm ~/mambaforge.sh

### Copy over TGI container

# Conda env
ENV PATH=/opt/conda/bin:$PATH \
    CONDA_PREFIX=/opt/conda

# Text Generation Inference base env
ENV HUGGINGFACE_HUB_CACHE=/data \
    HF_HUB_ENABLE_HF_TRANSFER=1 \
    PORT=80

COPY --from=tgi /opt/conda /opt/conda

COPY --from=tgi  /usr/local/bin/text-generation-benchmark /usr/local/bin/text-generation-benchmark
COPY --from=tgi  /usr/local/bin/text-generation-router /usr/local/bin/text-generation-router
COPY --from=tgi  /usr/local/bin/text-generation-launcher /usr/local/bin/text-generation-launcher
COPY --from=tgi  /usr/src /usr/src

### Install vllm
# should be installed into conda env
RUN pip install --upgrade --no-cache-dir git+https://github.com/joennlae/vllm@nice-logging accelerate

####
####
####


### From here it is runpod related stuff
###
###
# Update, upgrade, install packages and clean up
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt install --yes --no-install-recommends git wget curl bash libgl1 software-properties-common openssh-server nginx && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Remove existing SSH host keys
RUN rm -f /etc/ssh/ssh_host_*

# NGINX Proxy
COPY container-template/proxy/nginx.conf /etc/nginx/nginx.conf
COPY container-template/proxy/readme.html /usr/share/nginx/html/readme.html

# Copy the README.md
COPY README.md /usr/share/nginx/html/README.md

# Start Scripts
COPY container-template/start.sh /
RUN chmod +x /start.sh

# Welcome Message
COPY container-template/runpod.txt /etc/runpod.txt
RUN echo 'cat /etc/runpod.txt' >> /root/.bashrc
RUN echo 'echo -e "\nFor detailed documentation and guides, please visit:\n\033[1;34mhttps://docs.runpod.io/\033[0m and \033[1;34mhttps://blog.runpod.io/\033[0m\n\n"' >> /root/.bashrc

# Set the default command for the container
CMD [ "/start.sh" ]
