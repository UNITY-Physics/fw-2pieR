FROM nialljb/fw-ants-vbm:latest as base

ENV HOME=/root/
ENV FLYWHEEL="/flywheel/v0"
WORKDIR $FLYWHEEL
RUN mkdir -p $FLYWHEEL/input

# Installing the current project (most likely to change, above layer can be cached)
COPY ./ $FLYWHEEL/

# Replace dead Buster sources with archived ones
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    apt-get update

RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8B48AD6246925553 && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7638D0442B90D010 && \
    apt-get update

# Dev dpendencies
RUN apt-get update && apt-get install --no-install-recommends -y software-properties-common=0.96.20.2-2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install antspyx scikit-image

# Configure entrypoint
RUN bash -c 'chmod +rx $FLYWHEEL/run.py' && \
    bash -c 'chmod +rx $FLYWHEEL/start.sh' && \
    bash -c 'chmod +rx $FLYWHEEL/app/' && \
    bash -c 'chmod +rx $FSLDIR/etc/fslconf/fsl.sh' &&\
    bash -c 'source $FSLDIR/etc/fslconf/fsl.sh'
    
ENTRYPOINT ["bash","/flywheel/v0/start.sh"] 
# Flywheel reads the config command over this entrypoint