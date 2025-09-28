# FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04
FROM nvidia/cuda:13.0.0-cudnn-devel-rockylinux9

# Install necessary packages
# Enable CRB, EPEL, and RPM Fusion (needed for ffmpeg and some extras)
RUN dnf -y update && dnf -y install dnf-plugins-core && \
    dnf config-manager --set-enabled crb && \
    dnf -y install epel-release && \
    dnf -y install \
      https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm \
      https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-9.noarch.rpm && \
    dnf -y groupinstall "Development Tools" && \
    dnf -y install --allowerasing \
      ca-certificates \
      curl \
      ffmpeg \
      git \
      htop \
      mercurial \
      ninja-build \
      openssh-clients \
      procps-ng \
      subversion \
      unzip \
      wget \
      bzip2 \
      libaio-devel \
      bzip2-devel \
      glibc-devel \
      libffi-devel \
      gdbm-devel \
      mesa-libGL-devel \
      libglvnd-opengl \
      glib2 \
      xz-devel \
      ncurses-devel \
      openblas-devel \
      libpq-devel \
      readline-devel \
      libSM \
      libXext \
      libXrender \
      sqlite-devel \
      openssl-devel \
      tk-devel \
      openal-soft \
      which \
      java-11-openjdk && \
    dnf clean all && rm -rf /var/cache/dnf /tmp/*

CMD [ "/bin/bash" ]

# Install uv, the fast Python package manager
RUN curl -LsSf https://astral.sh/uv/install.sh -o /tmp/uv-install.sh && \
  sh /tmp/uv-install.sh && \
  rm -f /tmp/uv-install.sh

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

COPY pyproject.toml /
RUN uv sync --active && \
    uv pip install natten==0.17.5+torch250cu124 -f https://whl.natten.org && \
    uv pip install --no-build-isolation "git+https://github.com/facebookresearch/detectron2.git" && \
    uv run --active python -c "import language_evaluation; language_evaluation.download('coco')"

# Final clean up
RUN uv cache clean && \
    rm -rf /tmp/* /uv.lock /pyproject.toml

ENV PYTHONUNBUFFERED=1
ENTRYPOINT ["/bin/bash", "-c"]
