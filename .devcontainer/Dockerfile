ARG UBUNTU_VERSION=20.04

ARG ARCH=
ARG CUDA=11.4
FROM nvidia/cuda${ARCH:+-$ARCH}:${CUDA}.3-base-ubuntu${UBUNTU_VERSION} as base
# ARCH and CUDA are specified again because the FROM directive resets ARGs
# (but their default value is retained if set previously)
ARG ARCH
ARG CUDA
ARG CUDNN=8.2.4.15-1
ARG CUDNN_MAJOR_VERSION=8
ARG LIB_DIR_PREFIX=x86_64
ARG LIBNVINFER=8.0.0-1
ARG LIBNVINFER_MAJOR_VERSION=8

# Let us install tzdata painlessly
ENV DEBIAN_FRONTEND=noninteractive

# Needed for string substitution
SHELL ["/bin/bash", "-c"]
# Pick up some TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ffmpeg \
        git \
        git-core \
        g++ \
        vim \
        zip \
        zlib1g-dev \
        cuda-command-line-tools-${CUDA/./-} \
        libcublas-${CUDA/./-} \
        cuda-nvrtc-${CUDA/./-} \
        libcufft-${CUDA/./-} \
        libcurand-${CUDA/./-} \
        libcusolver-${CUDA/./-} \
        libcusparse-${CUDA/./-} \
        curl \
        libcudnn8=${CUDNN}+cuda${CUDA} \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libzmq3-dev \
        libcairo2-dev \
        pkg-config \
        software-properties-common \
        unzip \
        wget \
        zsh

RUN sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# Install TensorRT if not building for PowerPC
# NOTE: libnvinfer uses cuda11.1 versions
RUN [[ "${ARCH}" = "ppc64le" ]] || { apt-get update && \
       apt-get install -y --no-install-recommends libnvinfer${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER}+cuda11.0 \
       libnvinfer-plugin${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER}+cuda11.0 \
       && apt-get clean \
       && rm -rf /var/lib/apt/lists/*; }

# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/lib64:$LD_LIBRARY_PATH
ENV PATH=/usr/local/cuda-${CUDA}/bin${PATH:+:${PATH}}
ENV LD_LIBRARY_PATH=/usr/local/cuda-${CUDA}/lib64:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda-${CUDA}/include:$LD_LIBRARY_PATH

# Link the libcuda stub to the location where tensorflow is searching for it and reconfigure
# dynamic linker run-+time bindings
RUN ln -s /usr/local/cuda-${CUDA}/compat/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1 \
    && echo "/usr/local/cuda/lib64/stubs" > /etc/ld.so.conf.d/z-cuda-stubs.conf \
    && ldconfig

# See http://bugs.python.org/issue19846
ENV LANG C.UTF-8

RUN apt update -y && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt install -y python3.9 python3.9-venv python3.9-dev

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.9 1
RUN python --version

RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.9

RUN python -m pip install --upgrade pip && \
    pip install tensorflow==2.11.0 \
    tf-models-official==2.11.0 \
    matplotlib==3.6.1 \
    protobuf==3.19.6 \
    tensorflow_io \
    numpy==1.21.5 \
    pyparsing \
    pycairo \
    Cython \
    jupyter \
    Pillow \
    ray \
    waymo-open-dataset-tf-2-11-0
    

WORKDIR /app

RUN python -m pip install pycocotools==2.0.8 opencv-python==4.5.5.64 

ENV TF_CPP_MIN_LOG_LEVEL=2

RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v3.13.0/protoc-3.13.0-linux-x86_64.zip && \
    unzip protoc-3.13.0-linux-x86_64.zip -d /app/protobuf/

ENV PATH "$PATH:/app/protobuf/bin"

RUN git clone https://github.com/tensorflow/models.git && \
    cd /app/models/research/ && \
    protoc object_detection/protos/*.proto --python_out=. && \
    cp object_detection/packages/tf2/setup.py . && \
    python -m pip install .

# Install google cloud SDK
RUN curl -sSL https://sdk.cloud.google.com > /tmp/gcl && bash /tmp/gcl --install-dir=~/gcloud --disable-prompts
ENV PATH="$PATH:/root/gcloud/google-cloud-sdk/bin"
