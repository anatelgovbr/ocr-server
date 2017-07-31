#!/usr/bin/env bash

# Inicializa serviço de log
/etc/init.d/rsyslog start

# Cria estrutura de pastas para monitoramento de arquivos
mkdir -p /var/ocr-server/
mkdir -p /var/ocr-server/Entrada
mkdir -p /var/ocr-server/Saida
mkdir -p /var/ocr-server/Originais_Processados
mkdir -p /var/ocr-server/Erro
chmod -R 777 /var/ocr-server

# Iniciar serviço do OCR-Server
service ocr start

tail -f /var/log/syslog