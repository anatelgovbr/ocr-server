
FROM ubuntu:24.04

WORKDIR /tmp

ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN sed -i 's/^Components: main restricted$/Components: main restricted universe/' \
    /etc/apt/sources.list.d/ubuntu.sources

# Instalação dos pacotes pré-requisitos do ocr-server 2
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
    tesseract-ocr tesseract-ocr-por tesseract-ocr-eng tesseract-ocr-spa leptonica-progs \
    poppler-utils pdftk-java unpaper ghostscript imagemagick rsyslog \
    perl libfile-find-rule-perl libfile-touch-perl libunix-syslog-perl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/rights="none" pattern="PDF"/rights="read|write" pattern="PDF"/' /etc/ImageMagick-6/policy.xml

COPY cpdf /usr/local/bin/cpdf
RUN chmod 755 /usr/local/bin/cpdf

RUN groupadd -g 1007 ocr && \
    useradd -m -u 1005 -g 1007 ocr

# Cópia de arquivos do projeto OCR-SERVER
COPY usr/local/bin/ocr /usr/local/bin/ocr
COPY etc/init.d/ocr-ubuntu /etc/init.d/ocr
COPY entrypoint.sh /entrypoint.sh

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
