
FROM ubuntu:20.04

# Cópia de arquivos do projeto OCR-SERVER
COPY usr/local/bin/ocr /usr/local/bin/ocr
COPY etc/init.d/ocr-ubuntu /etc/init.d/ocr
COPY entrypoint.sh /entrypoint.sh

WORKDIR /tmp

ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Instalação dos pacotes pré-requisitos do ocr-server 2
RUN apt-get -y update && \
    apt-get install -y tesseract-ocr tesseract-ocr-por tesseract-ocr-eng tesseract-ocr-spa leptonica-progs \
    poppler-utils pdftk unpaper ocaml ghostscript imagemagick libcamlpdf-ocaml \
    wget perl libfile-find-rule-perl libfile-touch-perl libunix-syslog-perl

RUN wget \
    https://raw.githubusercontent.com/coherentgraphics/cpdf-binaries/master/Linux-Intel-64bit/cpdf \
    -o /usr/local/bin/cpdf && \
    chmod 755 /usr/local/bin/cpdf

RUN useradd -m ocr

RUN chmod +x /usr/local/bin/ocr && \
    chmod +x /etc/init.d/ocr && \
    update-rc.d ocr defaults

RUN mkdir /var/ocr-server/  && \
    mkdir -p /var/ocr-server/Entrada && \
    mkdir -p /var/ocr-server/Saida && \
    mkdir -p /var/ocr-server/Originais_Processados && \
    mkdir -p /var/ocr-server/Erro  && \
    chmod +x /entrypoint.sh

RUN mkdir -p /tmp/ocr_dev/ && \
    mkdir -p /tmp/ocr_dev/Entrada && \
    mkdir -p /tmp/ocr_dev/Saida && \
    mkdir -p /tmp/ocr_dev/Originais_Processados && \
    mkdir -p /tmp/ocr_dev/Erro && \
    chmod -R 777 /tmp/ocr_dev

WORKDIR /

VOLUME /var/ocr-server/

CMD ["bash", "/entrypoint.sh"]
