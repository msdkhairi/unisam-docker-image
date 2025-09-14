# FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04
# FROM nvidia/cuda:13.0.0-cudnn-devel-rockylinux9
FROM nvidia/cuda:13.0.1-cudnn-devel-rockylinux10

# Install necessary packages
# Enable CRB, EPEL, and RPM Fusion (needed for ffmpeg and some extras)
RUN dnf -y update && dnf -y install dnf-plugins-core && \
    dnf config-manager --set-enabled crb && \
    dnf -y install epel-release && \
    dnf -y install \
      https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-10.noarch.rpm \
      https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-10.noarch.rpm && \
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
    dnf clean all && rm -rf /var/cache/dnf /tmp/*

CMD [ "/bin/bash" ]

# Install uv, the fast Python package manager
RUN curl -LsSf https://astral.sh/uv/install.sh -o /tmp/uv-install.sh && \
  sh /tmp/uv-install.sh && \
  rm -f /tmp/uv-install.sh

# Add uv to the PATH
ENV PATH="/root/.local/bin:${PATH}"

# Final clean up
RUN uv cache clean && \
    rm -rf /tmp/* /uv.lock /pyproject.toml

ENV PYTHONUNBUFFERED=1
ENTRYPOINT ["/bin/bash", "-c"]
