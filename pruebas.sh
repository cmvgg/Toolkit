#!/bin/bash

# Crear los archivos de informe si no existen
touch cppcheck_report.txt lizard_report.txt

# Asegurarse de que las herramientas necesarias estén instaladas
if ! command -v cppcheck &> /dev/null; then
    echo "Cppcheck no está instalado. Instálalo primero."
    
fi

if ! command -v lizard &> /dev/null; then
    echo "Lizard no está instalado. Instálalo primero."
    
fi

# Asegurarse de que jq esté instalado para procesar JSON
if ! command -v jq &> /dev/null; then
    echo "jq no está instalado. Instálalo primero."
    
fi

# Definir el endpoint de la API de OpenAI
API_URL="https://api-inference.huggingface.co/models/openai-community/gpt2" 
API_KEY="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"

# Generar el archivo de análisis con Cppcheck
cppcheck --enable=all --quiet --output-file=cppcheck_report.txt $(git diff --name-only --staged)

# Generar el archivo de análisis con Lizard
lizard $(git diff --name-only --staged) --output=lizard_report.txt

# Verificar si los informes generados no están vacíos
if [ ! -s cppcheck_report.txt ] || [ ! -s lizard_report.txt ]; then
    echo "Uno o más informes están vacíos. Asegúrate de que cppcheck y lizard generen informes válidos."
    
fi

# Combinar los informes de Cppcheck y Lizard en un solo archivo
cat cppcheck_report.txt lizard_report.txt >> changes_report.txt

# Verificar que el archivo final tenga contenido
REPORT=$(cat changes_report.txt)
if [ -z "$REPORT" ]; then
    echo "El archivo de informes está vacío. No se puede generar un commit."
    
fi

REPORT=$(cat changes_report.txt | tr -d '\000-\011\013\014\016-\037\u0000-\u001F')

# Enviar los informes a la IA para generar un mensaje de commit
RESPONSE=$(curl -s -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d '{
        "model": "gpt-3.5-turbo",
        "messages": [{"role": "system", "content": "Actúa como un experto en programación. Recibe informes de herramientas de análisis estático y genera un mensaje de commit detallado basado en los cambios de código detectados."}, 
        {"role": "user", "content": "'"$REPORT"'"}],
        "max_tokens": 150
    }')

# Verificar la respuesta de la API
echo "Respuesta de la API: $RESPONSE"

# Extraer el mensaje del commit de la respuesta de la API
COMMIT_MSG=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')

# Si no se generó un mensaje, usamos uno predeterminado
if [ -z "$COMMIT_MSG" ]; then
    COMMIT_MSG="chore: Actualización general del código"
fi

# Realizar el commit con el mensaje generado por la IA
echo "Generando commit con el siguiente mensaje:"
echo "$COMMIT_MSG"

# Finalmente, realizar el commit con el mensaje generado
git commit -m "$COMMIT_MSG"

