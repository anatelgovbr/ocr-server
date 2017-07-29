#!/usr/bin/env bash

mkdir -p /var/ocr-server/
mkdir -p /var/ocr-server/Entrada
mkdir -p /var/ocr-server/Saida
mkdir -p /var/ocr-server/Originais_Processados
mkdir -p /var/ocr-server/Erro
chmod -R 777 /var/ocr-server

service ocr start

tail -f /var/log/dmesg
