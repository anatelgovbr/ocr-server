#!/usr/bin/env bash

mkdir /var/ocr-server/
mkdir /var/ocr-server/Entrada
mkdir /var/ocr-server/Saida
mkdir /var/ocr-server/Originais_Processados
mkdir /var/ocr-server/Erro
chmod -R 777 /var/ocr-server

service ocr start

tail -f /var/log/dmesg
