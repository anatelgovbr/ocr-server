FROM ubuntu

RUN apt-get -y update
RUN apt-get -y install libfile-find-rule-perl libfile-find-rule-perl-perl imagemagick gettext tesseract-ocr-por tesseract-ocr-eng pdftk poppler-utils unpaper

RUN apt-get -y install git
RUN git clone https://github.com/coherentgraphics/cpdf-binaries.git
RUN cp cpdf-binaries/Linux-Intel-64bit/cpdf /usr/bin

RUN useradd -m ocr

COPY usr/local/bin/ocr /usr/local/bin/ocr
RUN chmod +x /usr/local/bin/ocr
COPY etc/init.d/ocr-ubuntu /etc/init.d/ocr

RUN  chmod +x /etc/init.d/ocr; update-rc.d ocr defaults

RUN apt-get -y install build-essential
RUN perl -MCPAN -e 'install File::Touch'

RUN mkdir /var/ocr-server/
RUN mkdir -p /var/ocr-server/Entrada
RUN mkdir -p /var/ocr-server/Saida
RUN mkdir -p /var/ocr-server/Originais_Processados
RUN mkdir -p /var/ocr-server/Erro
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh

RUN perl -MCPAN -e 'install File::Find::Rule;'
RUN perl -MCPAN -e 'install File::Touch;'
RUN perl -MCPAN -e 'install Sys::Syslog;'
RUN perl -MCPAN -e 'install IPC::Open3;'
RUN perl -MCPAN -e 'install IO::Select;'

RUN apt-get -y install tesseract-ocr
RUN ln -s /usr/bin/pdftk /usr/local/bin/pdftk
RUN ln -s /usr/bin/pdfimages /usr/local/bin/pdfimages
RUN ln -s /usr/bin/tesseract /usr/local/bin/tesseract
RUN ln -s /usr/bin/pdfinfo /usr/local/bin/pdfinfo
RUN ln -s /usr/bin/pdffonts /usr/local/bin/pdffonts
RUN ln -s /usr/bin/pdftoppm /usr/local/bin/pdftoppm
RUN ln -s /usr/bin/cpdf /usr/local/bin/cpdf

VOLUME /var/ocr-server/
CMD ["bash", "entrypoint.sh"]

