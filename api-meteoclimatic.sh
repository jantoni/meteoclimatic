#!/bin/bash

### VARIABLES ###
API_KEY="TU_API_KEY"
DATAFILE="PATH_Y_NOMBRE_FICHERO_DATOS"
URL="https://api.m11c.net/v3/station/wxupdate"

# Comprobar fichero
if [ ! -f "$DATAFILE" ]; then
    echo "Error: no existe el fichero $DATAFILE"
    exit 1
fi

POST_DATA=""
STATION_CODE=""

# Leer fichero
while IFS= read -r linea; do
    linea=$(echo "$linea" | tr -d '\r\n')

    # Ignorar vacías o fin
    [[ -z "$linea" || "$linea" == "*EOT*" ]] && continue

    # Quitar *
    linea="${linea#\*}"

    # Separar clave=valor
    if [[ "$linea" == *"="* ]]; then
        clave="${linea%%=*}"
        valor="${linea#*=}"

        clave=$(echo "$clave" | xargs)
        valor=$(echo "$valor" | xargs)

        # Capturar COD
        if [[ "$clave" == "COD" ]]; then
            STATION_CODE="$valor"
            continue
        fi

        # Ignorar vacíos
        [[ -z "$valor" ]] && continue

        # (Opcional) ignorar N/A
        # [[ "$valor" == "N/A" ]] && continue

        POST_DATA="${POST_DATA}&${clave}=${valor}"
    fi

done < "$DATAFILE"

# Validar station code
if [ -z "$STATION_CODE" ]; then
    echo "Error: no se encontró COD"
    exit 1
fi

# Añadir stationCode al body
POST_DATA="stationcode=${STATION_CODE}${POST_DATA}"

# Enviar POST
curl -s -X POST "$URL" \
  -H "APIkey: $API_KEY" \
  -d "$POST_DATA"
