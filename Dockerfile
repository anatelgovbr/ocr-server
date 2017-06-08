FROM ubuntu

COPY usr/local/bin/ocr /usr/local/bin/ocr
COPY etc/init.d/ocr-ubuntu /etc/init.d/ocr
COPY entrypoint.sh /entrypoint.sh

RUN useradd -m ocr

RUN apt-get -y update && \
    apt-get -y install libfile-find-rule-perl libfile-find-rule-perl-perl imagemagick tesseract-ocr \
    gettext tesseract-ocr-por tesseract-ocr-eng pdftk poppler-utils unpaper git build-essential

RUN git clone https://github.com/coherentgraphics/cpdf-binaries.git && \
    cp cpdf-binaries/Linux-Intel-64bit/cpdf /usr/bin

RUN perl -MCPAN -e 'install File::Touch' && \
    perl -MCPAN -e 'install File::Find::Rule;' && \
    perl -MCPAN -e 'install File::Touch;' && \
    perl -MCPAN -e 'install Sys::Syslog;' && \
    perl -MCPAN -e 'install IPC::Open3;' && \
    perl -MCPAN -e 'install IO::Select;'

RUN chmod +x /usr/local/bin/ocr && \
    chmod +x /etc/init.d/ocr && \
    update-rc.d ocr defaults

RUN mkdir /var/ocr-server/  && \
    mkdir -p /var/ocr-server/Entrada && \
    mkdir -p /var/ocr-server/Saida && \
    mkdir -p /var/ocr-server/Originais_Processados && \
    mkdir -p /var/ocr-server/Erro
RUN chmod +x entrypoint.sh

RUN ln -s /usr/bin/pdftk /usr/local/bin/pdftk && \
    ln -s /usr/bin/pdfimages /usr/local/bin/pdfimages && \
    ln -s /usr/bin/tesseract /usr/local/bin/tesseract && \
    ln -s /usr/bin/pdfinfo /usr/local/bin/pdfinfo && \
    ln -s /usr/bin/pdffonts /usr/local/bin/pdffonts && \
    ln -s /usr/bin/pdftoppm /usr/local/bin/pdftoppm && \
    ln -s /usr/bin/cpdf /usr/local/bin/cpdf

VOLUME /var/ocr-server/

CMD ["bash", "entrypoint.sh"]

