#	OCR Server 2.0 - (c) Agencia Nacional de Telecomunicacoees

This script monitors a set of input directories for PDF files once a new file is detected, it is processes through tesseract OCR in order to generate a new file with a hidden searchable text layer

It may be distributed under the conditions of the LGPL v2.1 license.

Author: Guilherme Chehab 

##	Version History:
 - 0.1
 	- Initial single server version
 - 0.2
 	- Check if page already has the html hidden layer, if so, ignore it
 - 0.3
 	- Solved issues about various image enconding types
 - 0.4
 	- Added a postnormalization step to ensure all output pdf pages have the same size and orientations as the original files
 - 0.5
 	- Used input file renaming as a way to sync multiple parallel instances, that way, it is minimized the risk of same file being OCRed multiple times.
 - 0.6
 	- Added a default handler for unknown image encoding using jpeg encoding
 - 0.7
 	- Solved an issue with files with more than 1000 pages
 - 1.0
 	- First release version
 	- 1.0.1   Solving error when file has no images
 	- 1.0.2   Fix bug when counting cores for AMD processors
 	- 1.0.3   Added better image type detection
 	- 1.0.4   Fix: added ubuntu init script
 	- 1.0.4b  Add Centos 6.9 install instructions
 - 2.0
 	- PDF/A output, and better compression with ghostscript
	- Rewritten image extration, processing and transformations process
	- Check if input file is signed, in this case, does not change the file contents
	- Added '-oem 0' option to tesseract (force legacy mode on tesseract 4)
	- Use operating system packges by default
	- Changed paths from external programs, instead of using full paths, uses first match from $PATH
	- Check existence of external programs on path before running
	- Add support for stencil type and image encoding scans, changed default extraction method for unknown types/encodings
	- Fix: create subpaths on error folder
	- Fix: trying to reduce overhead on temporary folder
	 
##	TODO:
 - Changes get_imgs and OCR processing to enable pages with more than one image -- it would not work on previous versions that assumed #pages = #imgs. Version 1.0.1 counts them diferently but does not treat it adequately -- shall require better pdf´s internal structure handling
 - Review poppler and cpdf install instructions
 - Add better handling of vectorized and non scanned pdf files
 - Add option to generate multi-page tiff files to reduce overhead (one for each CPU core) -- harder with current scalling, cropping and rotation handlers
 - Check mean saturation for additional colored images detection and automatically convert to B&W if possible -- added function to analyse image color histogram -> just need to add option to convert it to B&W.
 - Move all parameters to config file
 - Add some job control web interface
 - Add end user interface to submit files through web
 - Add check external programs version requirements before running
  
##	BUGS:
 - When image is of type stencil or encoding image, cropping information is lost, and page is shown different than original, this is due to using pdftoppm instead of pdfimages
 
##	Requirements: 
 - Perl 5.10.1, com seguintes módulos:
	- File::Find::Rule
	- File::Basename
	- File::Copy
	- File::Path
	- File::Touch
	- Sys::Syslog
	- Sys::Hostname
	- IPC::Open3
	- IO::Select
	- POSIX
 - Tesseract-ocr 3.05, com dicionários inglês e português
 - Pdftk 2.02
 - Poppler-utils 0.42.0
 - Cpdf 2.1
 - ImageMagick 6.7.2-7
 - Ghostcript 9.18

Na ausência deles na distribuição do sistema operacional, o uso de versões antigas desses componentes podem comprometer o correto funcionamento do sistema

Dessa forma, pode ser necessário compilar os componentes faltantes, assim como as bibliotecas necessárias para o seu correto funcionamento.

Esse arquivo contem informações quanto aos procedimentos para instalar e configurar o sistema pressupondo o pior caso, qual seja, a necessidade de compilação dos componentes.

ATENÇÃO: se algum componente abaixo não estiver disponível no repositório padrão para o Linux utilizado, deve-se proceder com a compilação da versão mais recente do componente disponibilizado em outros repositórios para que seja instalado no Linux a ser utilizado.

### Configure o script, alterando as variáveis no arquivo '/usr/local/bin/ocr':

- @BASE_DIRS:	Lista de diretórios base para a busca de arquivos --> cada diretório base irá ter sua própria instância do script 
- @SUB_DIRS:		Subdiretórios de entrada, saída, backup do arquivos originais, temporário e de arquivos com erro
- $MAX_FILES:	Número máximo de arquivos a serem processados simultaneamente por diretório de entrada (default: 2)
- $MAX_PGS:		Número máximo de páginas que podem ser processadas simultanemante por arquivo de entrada (default: no. de CPUs)

Essas variáveis controlam o número máximo de instâncias de processos simultâneas = Num. de diretorios X MAX_FILES X MAX_PGS.

Recomenda-se que o equipamento tenha em torno de 1,5 GB de RAM para cada core de CPU de forma a evitar swap. Se isso não for possível, pode ser reduzido o número de processos ou arquivos simultâneos.

A configuração do servidor pode ser dimensionada com base no tempo desejado para processamento de grandes arquivos (> 100 páginas). Cada página tem sua própria thread de processamento, até o limite de $MAX_PGS, cujo default é o no. de cores de CPU. Em média cada página demora em torno de 18 segundos em uma CPU Xeon E5 4670@2.6GHz. Assim, com 16 CPUs, o desempenho agregado é em torno de 1,2 segundos por página.

Para operação multi instância, basta instalar quantos servidores forem necessários e eles podem ter acesso aos mesmos diretórios de entrada que podem ser compartilhamentos SAMBA/CIFS/Windows ou NFS.

# COMPILAÇÃO dos pré requisitos (obs.: os comandos devem ser executados como root)

Em servidor Ubuntu 16.04, os pacotes padrão (com exceção do CPDF, que não tem no repositório oficial) 
são suficientes para executar o aplicativo, não havendo necessidade de compilar todos, assim é a arquitetura recomendada

Quanto ao CPDF, é possível baixar a versão binária em: https://github.com/coherentgraphics/cpdf-binaries

## Compilando os pré-requisitos: máquina de COMPILAÇÃO APENAS 

    # RedHat 6.7 e Centos 6.9:
	yum -y install autoconf make gcc-java gcc gcc-c++ subversion pkg-config automake libtool yasm cmake git libgcj unzip
	yum -y install libtiff-devel libpng-devel openjpeg-devel libjpeg-turbo-devel giflib-devel libwebp-devel zlib-devel libicu-devel pango-devel cairo-devel fontconfig-devel gettext-devel libcurl-devel nss-devel
	cd /tmp
	wget http://www.itzgeek.com/msttcore-fonts-2.0-3.noarch.rpm
	rpm -Uvh msttcore-fonts-2.0-3.noarch.rpm
	rm -f msttcore-fonts-2.0-3.noarch.rpm

    # Centos 6.9
    #   \_ autoconf-archive
	wget ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/pelliott11:/autoconf-archive/CentOS_CentOS-6/noarch/autoconf-archive-2012.04.07-7.3.noarch.rpm
	rpm -i autoconf-archive-2012.04.07-7.3.noarch.rpm
	rm autoconf-archive-2012.04.07-7.3.noarch.rpm
    #   \_ GCC 4.8
	wget http://people.centos.org/tru/devtools-2/devtools-2.repo -O /etc/yum.repos.d/devtools-2.repo
	yum install devtoolset-2-gcc devtoolset-2-binutils devtoolset-2-gcc-c++ devtoolset-2-gcj

    # Ubuntu 14.04 Server:
	apt-get install build-essential cmake libtool yasm pkg-config subversion git libgcj14 
	apt-get install libtiff-dev libpng-dev libopenjpeg-dev libjpeg8-dev libjpeg-turbo8-dev libjpeg-dev libgif-dev zlib1g-dev libicu-dev libpango1.0-dev libcairo2-dev libfontconfig1-dev libgettextpo-dev libcurl-dev  libnss3-dev
	apt-get install ttf-mscorefonts-installer

    # Ambas plataformas:
	cd /usr/local/src

	for i in \
		https://github.com/tesseract-ocr/langdata.git \
		https://github.com/DanBloomberg/leptonica.git \
		https://github.com/libav/libav.git  \
		https://github.com/tesseract-ocr/tessdata.git \
		https://github.com/tesseract-ocr/tesseract.git \
		git://git.freedesktop.org/git/poppler/poppler.git \
		git://git.freedesktop.org/git/poppler/test.git \
		https://github.com/Flameeyes/unpaper.git \
		https://github.com/ocaml/ocaml.git \
		https://gitlab.camlcity.org/gerd/lib-findlib.git \
		https://github.com/johnwhitington/camlpdf.git \
		https://github.com/johnwhitington/cpdf-source.git \
		http://git.ghostscript.com/ghostpdl.git \
	; do git clone $i; done

	wget https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk-2.02-src.zip
	unzip pdftk-2.02-src.zip
	rm -f pdftk-2.02-src.zip

    # pdftk, versão 2.02 ou superior
    cd pdftk-2.02-dist/pdftk && make -f Makefile.Redhat all install && cd ../..

    # Ghostscript 9.18 ou superior
    #wget http://downloads.ghostscript.com/public/old-gs-releases/ghostscript-9.21.tar.gz
    #tar xvozf ghostscript-9.21.tar.gz
    #rm -f ghostscript-9.21.tar.gz
    #cd ghostscript-9.21
    cd ghostpdl
    ./autogen.sh; ./configure
    make all install
    cd ..

    # Centos 6.9
    #   \_ Cria um novo shell usando o GCC 4.8 por default
    scl enable devtoolset-2 bash  

    # Tesseract, versão 3.05-dev ou superior
    # Bibliotecas para o Tesseract: Leptonica e Libav
    cd leptonica && ./autobuild && ./configure && make all install && cd ..

    # Para compilação do Tesseract após a compilação do leptonica
    export PKG_CONFIG_PATH=/usr/lib:/usr/local/lib:/usr/local/src/leptonica/

    cd libav && ./configure --enable-sram && make all install && cd ..

    # Tesseract
    cd tesseract && ./autogen.sh && ./configure && make all install && cd ..
    cp -avR tessdata/* /usr/local/share/tessdata/

    # cpdf, versão 2.1 ou superior
    cd ocaml && ./configure && make world.opt && make install && cd ..
    mkdir -p /usr/local/man/man5
    # lib-findlib -- pode dar erro na instalação de páginas de man... é seguro ignorar, ou basta criar os diretórios faltantes e tentar novamente 
    cd lib-findlib  && ./configure && make all && make install && cd ..
    cd camlpdf && sed -i.bak s/\(uint32\)/\(uint32_t\)/g flatestubs.c && make && make install && cd ..
    cd cpdf-source && make all && make install && cp cpdf /usr/local/bin && cd ..

    # poppler-utils, versão 0.42.0 ou superior
    cd poppler && ./autogen.sh && ./configure --enable-cmyk --enable-libcurl && make  all install && cd ..

    # Centos 6.9
    #   \_ Termina o shell usando o GCC 4.8 por default
    exit


## Comandos adicionais para configuração do módulo:
	
    # Criação do usuário
    adduser ocr

    # Copie os arquivos ocr ocr-* para os diretórios corretos, conforme o sistema operacional
    cp ./usr/local/bin/ocr /usr/local/bin

    # Auto start (RedHat 6.7 e CentOs 6.9)
    cp ./usr/local/etc/init.d/ocr-redhat /etc/init.d/ocr 
    mv /etc
    chkconfig --add ocr
    chkconfig --level 2345 ocr on
    
    # Auto start (Ubuntu 14.04)
    cp ./usr/local/etc/init.d/ocr-ubuntu /etc/init.d/ocr
    update-rd.d ocr defaults
    
    # Create pkg -- para instalação em outras máquinas sem a necessidade de novas compilações
    cd /home/ocr
    tar cvozf pkg-ocr.tgz /usr/local/bin /usr/local/lib* /usr/local/man/ /usr/local/sbin/ /usr/local/share/ /usr/local/etc /usr/local/include/ /home/ocr/ocr* /etc/init.d/ocr /etc/rc*.d/*ocr
    su

# INSTALAÇÃO (obs.: os comandos devem ser executados como root)
    # Criação do usuário
    adduser ocr

    # Copie o pacote para os outros servidores e extraia com:
    cd /
    tar xovzf pkg-ocr.tgz

    # Instalando pré-requisitos RUNTIME em servidores adicionais

    # Redhat 6.7 e CentOS 6.9
    yum -y install perl-File-Find-Rule-Perl perl-File-Touch libtiff libpng openjpeg-libs libjpeg-turbo giflib zlib libicu pango cairo fontconfig ImageMagick gettext libwebp ghostscript
    yum -y install libtiff libpng openjpeg libjpeg-turbo giflib libwebp zlib libicu pango cairo fontconfig gettext 

    # Ubuntu 14.04
    apt-get install  libfile-find-rule-perl libfile-find-rule-perl-perl libtiff5 libpng12-0 libopenjpeg2 libjpeg-turbo8 libgif4 zlib1g libicu52 libpango1.0-0 libcairo2 fontconfig imagemagick gettext libwebp5 # libgcj14 
    apt-get install libtiff5 libpng12-0 libopenjpeg2 libjpeg8 libjpeg-turbo8 libjpeg8 zlib1g libpango1.0-0 libcairo2 libfontconfig1 libgettextpo0 ghostscript

# Inicie o serviço com
    service ocr start
