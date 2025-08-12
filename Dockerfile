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
      # dev headers for building Python via python-build (pyenv)
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
      which && \
    dnf clean all && rm -rf /var/cache/dnf /tmp/*

# Install OpenJDK 11
RUN dnf -y install java-11-openjdk && \
    dnf clean all && rm -rf /var/cache/dnf /tmp/*

CMD [ "/bin/bash" ]

RUN git clone "https://github.com/pyenv/pyenv.git" ./pyenv && \
    (cd pyenv/plugins/python-build && ./install.sh) && \
    rm -rf pyenv

ARG VERSION_PYTHON=3.11.13
RUN python-build --no-warn-script-location ${VERSION_PYTHON} /opt/python

ENV PATH="/opt/python/bin:${PATH}"

RUN python -m pip install --upgrade pip setuptools wheel

COPY requirements.txt /
RUN python -m pip install --no-cache-dir -r requirements.txt latentmi \
    git+https://github.com/bckim92/language-evaluation.git && \
    python -m pip install natten==0.17.5+torch250cu124 -f https://shi-labs.com/natten/wheels/&& \
    python -c "import language_evaluation; language_evaluation.download('coco')" && \
    rm -rf /root/.cache/pip requirements.txt

# Final clean
RUN rm -rf /tmp/*

ENV PYTHONUNBUFFERED=1
ENTRYPOINT ["/bin/bash", "-c"]
