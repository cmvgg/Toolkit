#!/bin/bash

# Comprobar si jq está instalado
if ! command -v jq &> /dev/null; then
    echo "jq no está instalado. Instálalo con 'sudo apt-get install jq' o 'brew install jq'."
    exit 1
fi

# Verifica si la clave API está configurada
if [ -z "$OPENAI_API_KEY" ]; then
    echo "La variable OPENAI_API_KEY no está configurada."
    exit 1
fi

# Función para analizar archivos y extraer nombres de funciones
analizar_archivo() {
    local file="$1"
    local funciones
    funciones=$(grep -E '^[a-zA-Z_][a-zA-Z0-9_]*[ \t]*\(' "$file" | sed -E 's/[ \t]*\([^)]*\)[ \t]*\{//g')
    echo "$funciones"
}

# Función para generar una descripción en inglés usando la API de OpenAI
generar_descripcion_ia() {
    local prompt="$1"
    echo "Generando descripción con prompt: $prompt"
    local response=$(curl -s -X POST https://api.openai.com/v1/engines/davinci-codex/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d '{
          "prompt": "'"${prompt}"'",
          "max_tokens": 150,
          "temperature": 0.5
        }')
    echo "Respuesta de la API: $response"
    local text=$(echo $response | jq -r '.choices[0].text')
    if [ -z "$text" ] || [ "$text" = "null" ]; then
        echo "Error: La descripción en inglés es nula o vacía."
        text="Descripción no disponible"
    fi
    echo "$text"
}

# Función para traducir texto al español usando la API de OpenAI
traducir_texto_ia() {
    local texto="$1"
    echo "Traduciendo texto: $texto"
    local response=$(curl -s -X POST https://api.openai.com/v1/engines/davinci-codex/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d '{
          "prompt": "Translate the following text to Spanish:\n\n'"${texto}"'\n\nTranslation:",
          "max_tokens": 200,
          "temperature": 0.5
        }')
    echo "Respuesta de la API: $response"
    local text=$(echo $response | jq -r '.choices[0].text')
    if [ -z "$text" ] || [ "$text" = "null" ]; then
        echo "Error: La descripción en español es nula o vacía."
        text="Descripción no disponible"
    fi
    echo "$text"
}

# Generar el contenido para README
generar_readme() {
    local file_list=$(find . -type f -name '*.c' -o -name '*.sh')

    echo "Generando README.md..."
    
    local contenido=""
    for file in $file_list; do
        echo "Analizando $file..."
        local funciones=$(analizar_archivo "$file")
        if [ -n "$funciones" ]; then
            local prompt="Describe the following functions concisely in Markdown:\n\n${funciones}"
            local descripcion_en=$(generar_descripcion_ia "$prompt")
            local descripcion_es=$(traducir_texto_ia "$descripcion_en")
            
            contenido+="### $(basename "$file")\n\n"
            contenido+="**Descripción en inglés:**\n$descripcion_en\n\n"
            contenido+="**Descripción en español:**\n$descripcion_es\n\n"
        else
            contenido+="### $(basename "$file")\n\nNo se encontraron funciones.\n\n"
        fi
    done
    
    local readme_file="README.md"
    local readme_en_file="README_en.md"
    local readme_es_file="README_es.md"

    # Comprobar si se necesita actualizar el README
    if [ -e "$readme_file" ]; then
        echo "Comprobando si se necesita actualizar el README.md..."
        local hash_actual=$(sha256sum "$readme_file" | awk '{ print $1 }')
        local hash_nuevo=$(echo "$contenido" | sha256sum | awk '{ print $1 }')

        if [ "$hash_actual" == "$hash_nuevo" ]; then
            echo "El README.md ya está actualizado."
            exit 0
        fi
    fi

    # Crear o actualizar el README.md
    echo -e "$contenido" > "$readme_file"
    echo "README.md generado."

    # Crear README_en.md y README_es.md
    echo -e "$contenido" | grep -E '^### ' | sed 's/### //g' | while read -r file; do
        local prompt="Describe the following functions concisely in Markdown:\n\n${funciones}"
        local descripcion_en=$(generar_descripcion_ia "$prompt")
        local descripcion_es=$(traducir_texto_ia "$descripcion_en")
        
        echo "### $file" > "$readme_en_file"
        echo -e "**Descripción en inglés:**\n$descripcion_en\n" >> "$readme_en_file"
        
        echo "### $file" > "$readme_es_file"
        echo -e "**Descripción en español:**\n$descripcion_es\n" >> "$readme_es_file"
    done

    echo "README_en.md y README_es.md generados."
}

# Ejecutar la función para generar el README
generar_readme

