#!/usr/bin/env bash

# Inicializa serviço de log (requer root)
rsyslogd 2>/dev/null || true
sleep 1

# Cria estrutura de pastas como uid=1005 (forceuid do CIFS)
runuser -u ocr -- bash -c 'mkdir -p /var/ocr-server/{Entrada,Saida,Originais_Processados,Erro}'

# Inicia o daemon OCR como uid=1005/gid=1007
runuser -u ocr -- /usr/local/bin/ocr &

# Aguarda criação do syslog e exibe logs
while [ ! -f /var/log/syslog ]; do sleep 1; done

while true; do
	tail -f /var/log/syslog
	sleep 1
done
