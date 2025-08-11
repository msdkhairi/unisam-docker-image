# FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04
# FROM nvidia/cuda:13.0.0-tensorrt-devel-ubuntu24.04
FROM nvidia/cuda:13.0.0-cudnn-devel-ubuntu22.04

# Install necessary packages
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    apt-transport-https \
    build-essential \
    bzip2 \
    ca-certificates \
    curl \
    ffmpeg \
    git \
    htop \
    libaio-dev \
    libbz2-dev \
    libc6-dev \
    libffi-dev \
    libgdbm-dev \
    libgl1-mesa-dev \
    libglib2.0-0 \
    liblzma-dev \
    libncursesw5-dev \
    libopenblas-dev \
    libpq-dev \
    libreadline-dev \
    libsm6 \
    libsqlite3-dev \
    libssl-dev \
    libxext6 \
    libxrender1 \
    lsb-release \
    mercurial \
    ninja-build \
    openssh-client \
    procps \
    software-properties-common \
    subversion \
    tk-dev \
    unzip \
    wget

# Install openjdk 11
RUN curl -o packages-microsoft-prod.deb https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    msopenjdk-11

CMD [ "/bin/bash" ]

RUN git clone "https://github.com/pyenv/pyenv.git" ./pyenv && \
    (cd pyenv/plugins/python-build && ./install.sh) && \
    rm -rf pyenv

ARG VERSION_PYTHON=3.11.11
RUN python-build --no-warn-script-location ${VERSION_PYTHON} /opt/python

ENV PATH="/opt/python/bin:${PATH}"

RUN python -m pip install --upgrade pip setuptools wheel

COPY requirements.txt /
RUN python -m pip install --no-cache-dir -r requirements.txt latentmi \
    git+https://github.com/bckim92/language-evaluation.git && \
    python -m pip install natten==0.17.5+torch250cu124 -f https://shi-labs.com/natten/wheels/&& \
    python -c "import language_evaluation; language_evaluation.download('coco')" && \
    rm -rf /root/.cache/pip requirements.txt

RUN apt-get clean && \
    rm packages-microsoft-prod.deb && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

ENV PYTHONUNBUFFERED=1
ENTRYPOINT ["/bin/bash", "-c"]
