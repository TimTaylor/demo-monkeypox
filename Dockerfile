# this modifies a version from https://github.com/Enchufa2/cran2copr
# by Iñaki Ucar
# GPL-2.0

ARG VERSION=36
ARG GIT_COMMIT=unspecified

FROM registry.fedoraproject.org/fedora:$VERSION

LABEL org.label-schema.license="GPL-2.0" \
      org.label-schema.vcs-url="https://github.com/TimTaylor/demo-monkeypox" \
      maintainer="Tim Taylor <timothy.taylor@ukhsa.gov.uk>" \
      git_commit=$GIT_COMMIT

RUN echo "install_weak_deps=False" >> /etc/dnf/dnf.conf \
    && dnf -y upgrade && dnf -y install R wget libreoffice-calc && dnf -y clean all

RUN dnf -y install 'dnf-command(copr)' \
    && dnf -y copr enable iucar/cran \
    && sed -ie '/nodocs/d' /etc/dnf/dnf.conf \
    && dnf -y install sudo R-CoprManager && dnf -y clean all \
    && echo "options(CoprManager.sudo=TRUE)" > \
        /usr/lib64/R/etc/Rprofile.site.d/51-CoprManager-sudo.site \
    && echo "options(repos='https://cloud.r-project.org')" > \
        /usr/lib64/R/etc/Rprofile.site.d/00-repos.site

RUN useradd -m docker \
    && echo "docker ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/docker-user \
    && chmod 0440 /etc/sudoers.d/docker-user \
    && mkdir -p /usr/local/lib/R/site-library \
    && chown 1000:1000 /usr/local/lib/R/site-library

RUN dnf -y install \
    R-CRAN-ggplot2 \
    R-CRAN-readxl \
    R-CRAN-svglite \
    R-CRAN-data.table \
    R-CRAN-patchwork \
    R-CRAN-rmarkdown \
    && dnf -y clean all

RUN wget -q https://github.com/quarto-dev/quarto-cli/releases/download/v1.0.38/quarto-1.0.38-linux-amd64.tar.gz \
    && tar -xf quarto-1.0.38-linux-amd64.tar.gz \
    && mv quarto-1.0.38 /opt/ \
    && rm quarto-1.0.38-linux-amd64.tar.gz \
    && ln -s /opt/quarto-1.0.38/bin/quarto /usr/local/bin/quarto

WORKDIR /monkeypox

CMD ["bash"]
