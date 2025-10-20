FROM nvidia/cuda:12.8.1-cudnn-runtime-ubuntu20.04

# Ensure unbuffered output (logs are flushed immediately)
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

ARG CONDA_DIR=/opt/conda
ENV PATH=${CONDA_DIR}/bin:${PATH}

# --- Install system dependencies ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# --- Install Miniconda ---
RUN wget --content-disposition https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p ${CONDA_DIR} && \
    rm /tmp/miniconda.sh

# (Optional) Accept Conda Terms of Service
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# --- Configure Conda to use Tsinghua mirrors (if Conda is available) ---
RUN if command -v conda >/dev/null 2>&1; then \
    echo "🔧 Conda detected, configuring Tsinghua TUNA mirrors..." && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r && \
    conda config --set show_channel_urls yes && \
    conda config --set channel_priority flexible; \
    fi

# --- Create Conda environment ---
# RUN conda create -y -n ${ENV_NAME} python=${PYTHON_VERSION} && \
#     conda clean -afy

# --- Activate environment and configure pip mirrors ---
# SHELL ["conda", "run", "-n", "searchr1", "/bin/bash", "-c"]

RUN mkdir -p /etc && \
    echo "[global]" > /etc/pip.conf && \
    echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> /etc/pip.conf && \
    echo "trusted-host = pypi.tuna.tsinghua.edu.cn" >> /etc/pip.conf

# --- Configure APT to use Tsinghua mirrors ---
RUN sed -i 's|http://archive.ubuntu.com/ubuntu|https://mirrors.tuna.tsinghua.edu.cn/ubuntu|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com/ubuntu|https://mirrors.tuna.tsinghua.edu.cn/ubuntu|g' /etc/apt/sources.list

# --- Copy project files ---
WORKDIR /app
COPY . /app

# --- Configure proxy environment variables ---
ENV http_proxy=http://172.16.200.37:8888
ENV https_proxy=http://172.16.200.37:8888
ENV HTTP_PROXY=http://172.16.200.37:8888
ENV HTTPS_PROXY=http://172.16.200.37:8888

CMD ["bash"]