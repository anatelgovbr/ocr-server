
FROM ubuntu:14.04

# Cópia de arquivos do projeto OCR-SERVER
COPY usr/local/bin/ocr /usr/local/bin/ocr
COPY etc/init.d/ocr-ubuntu /etc/init.d/ocr
COPY entrypoint.sh /entrypoint.sh

RUN useradd -m ocr

RUN apt-get -y update
RUN apt-get -y install build-essential cmake libtool yasm pkg-config subversion git libgcj14 apt-utils
RUN apt-get -y install curl
RUN apt-get -y install libtiff-dev libpng-dev libopenjpeg-dev libjpeg8-dev libjpeg-turbo8-dev libjpeg-dev libgif-dev zlib1g-dev libicu-dev libpango1.0-dev libcairo2-dev libfontconfig1-dev libgettextpo-dev libnss3-dev
#RUN apt-get -y install ttf-mscorefonts-installer

RUN apt-get -y install wget cabextract xfonts-utils
RUN wget -O mscorefonts.deb http://ftp.us.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.4+nmu1_all.deb && \
    dpkg -i mscorefonts.deb

# Instalação do Perl 5.1 e demais módulos
RUN apt-get -y install perl
RUN perl -MCPAN -e 'install File::Touch'
RUN perl -MCPAN -e 'install File::Find::Rule;'
RUN perl -MCPAN -e 'install File::Touch;'
RUN perl -MCPAN -e 'install Sys::Syslog;'
RUN perl -MCPAN -e 'install IPC::Open3;'
RUN perl -MCPAN -e 'install IO::Select;'

# Tesseract-ocr 3.05, com dicionários inglês e português
# Bibliotecas para o Tesseract: Leptonica
RUN git clone https://github.com/DanBloomberg/leptonica.git
RUN apt-get -y install automake
RUN cd leptonica && ./autobuild && ./configure && make all install

# Bibliotecas para o Tesseract: Libav
RUN git clone https://github.com/libav/libav.git
RUN export PKG_CONFIG_PATH=/usr/lib:/usr/local/lib:/usr/local/src/leptonica/ && \
    cd libav && ./configure --enable-sram && make all install -w

# Tesseract
RUN git clone https://github.com/tesseract-ocr/tesseract.git
RUN apt-get -y install autoconf-archive
RUN cd tesseract && ./autogen.sh && ./configure && make all install

#RUN git clone https://github.com/tesseract-ocr/tessdata.git
#RUN cp -avR tessdata/* /usr/local/share/tessdata/
RUN wget https://github.com/tesseract-ocr/tessdata/blob/master/eng.traineddata?raw=true -O /usr/local/share/tessdata/eng.traineddata && \
    wget https://github.com/tesseract-ocr/tessdata/blob/master/por.traineddata?raw=true -O /usr/local/share/tessdata/por.traineddata && \
    wget https://github.com/tesseract-ocr/tessdata/blob/master/osd.traineddata?raw=true -O /usr/local/share/tessdata/osd.traineddata

#    export LIBCURL_LIBS=/usr/lib/x86_64-linux-gnu/ && \
RUN apt-get -y install libcurl4-gnutls-dev
RUN git clone https://anongit.freedesktop.org/git/poppler/poppler.git && \
    cd poppler && ./autogen.sh && ./configure --enable-cmyk --enable-libcurl && make  all install && cd ..

# pdftk, versão 2.02 ou superior
RUN wget https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk-2.02-src.zip
RUN apt-get -y install unzip libgcj14
RUN unzip pdftk-2.02-src.zip && rm -f pdftk-2.02-src.zip

RUN apt-get -y update 
RUN apt-get -y install build-essential libfile-find-rule-perl libfile-find-rule-perl-perl imagemagick 
RUN apt-get -y install gettext unpaper git 
RUN apt-get -y install libtiff5 libpng12-0 libjpeg-turbo8 zlib1g libpango1.0-0 libcairo2 fontconfig libwebp5 
RUN apt-get -y install libpango1.0-0 libcairo2 libfontconfig1 libgettextpo0 
RUN apt-get -y install pkg-config libgcj14 libtiff-dev libpng-dev libopenjpeg-dev libjpeg8-dev libjpeg-turbo8-dev libjpeg-dev libgif-dev 
RUN apt-get -y install zlib1g-dev libicu-dev libpango1.0-dev libcairo2-dev libfontconfig1-dev libgettextpo-dev  libnss3-dev

RUN apt-get install -y gcc
RUN apt-get install -y gcj-jdk
RUN cd pdftk-2.02-dist/pdftk && make -f Makefile.Redhat all install

# Ghostscript 9.18 ou superior
RUN wget http://downloads.ghostscript.com/public/old-gs-releases/ghostscript-9.18.tar.gz
RUN tar xvozf ghostscript-9.18.tar.gz && rm -f ghostscript-9.18.tar.gz
RUN cd ghostscript-9.18 && ls && ./autogen.sh; ./configure && make all install

RUN git clone https://github.com/coherentgraphics/cpdf-binaries.git && \
    cp cpdf-binaries/Linux-Intel-64bit/cpdf /usr/bin

RUN chmod +x /usr/local/bin/ocr && \
    chmod +x /etc/init.d/ocr && \
    update-rc.d ocr defaults

RUN mkdir /var/ocr-server/  && \
    mkdir -p /var/ocr-server/Entrada && \
    mkdir -p /var/ocr-server/Saida && \
    mkdir -p /var/ocr-server/Originais_Processados && \
    mkdir -p /var/ocr-server/Erro  && \
    chmod +x entrypoint.sh

RUN mkdir -p /tmp/ocr_dev/ && \
    mkdir -p /tmp/ocr_dev/Entrada && \
    mkdir -p /tmp/ocr_dev/Saida && \
    mkdir -p /tmp/ocr_dev/Originais_Processados && \
    mkdir -p /tmp/ocr_dev/Erro && \
    chmod -R 777 /tmp/ocr_dev

VOLUME /var/ocr-server/

CMD ["bash", "entrypoint.sh"]