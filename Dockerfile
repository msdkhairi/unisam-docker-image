# FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04
FROM nvidia/cuda:13.0.1-cudnn-devel-ubuntu24.04

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
RUN curl -o /tmp/packages-microsoft-prod.deb https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb && \
    dpkg -i /tmp/packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends msopenjdk-11

# Install uv, the fast Python package manager
RUN curl -LsSf https://astral.sh/uv/install.sh -o /tmp/uv-install.sh && \
    sh /tmp/uv-install.sh

CMD [ "/bin/bash" ]

# Add uv to the PATH
ENV PATH="/root/.local/bin:${PATH}"

# Set the desired Python version
ARG VERSION_PYTHON=3.11.13

# Set the directory where Python versions will be installed
ENV UV_PYTHON_INSTALL_DIR="/opt/python"

# Create a virtual environment. uv will download the specified Python version.
RUN uv venv /opt/venv --python ${VERSION_PYTHON}

# Set VIRTUAL_ENV and prepend the venv's bin directory to the PATH.
ENV VIRTUAL_ENV="/opt/venv"
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY pyproject.toml
RUN uv sync --active && \
    uv pip install natten==0.17.5+torch250cu124 -f https://whl.natten.org && \
    uv pip install --no-build-isolation "git+https://github.com/facebookresearch/detectron2.git" && \
    uv run --active python -c "import language_evaluation; language_evaluation.download('coco')"

# uv clean up
RUN uv cache clean && \
    rm -rf /uv.lock /pyproject.toml

# Final clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

ENV PYTHONUNBUFFERED=1
ENTRYPOINT ["/bin/bash", "-c"]
