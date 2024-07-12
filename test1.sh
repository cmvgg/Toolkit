#!/bin/bash

function mostrar_encabezado {
    echo "----------------------------------------------------"
    echo "ANÁLISIS ESTÁTICO DEL CÓDIGO - REPORTE DE VULNERABILIDADES"
    echo "----------------------------------------------------"
    echo ""
    echo "Fecha de análisis: $(date +"%Y-%m-%d %H:%M:%S")"
    echo ""
    echo "Proyecto: $1"
    echo ""
}

function mostrar_vulnerabilidad {
    local linea="$1"
    local num_vulnerabilidad="$2"
    local archivo="$3"
    local descripcion="$4"
    local recomendacion="$5"
    local gravedad="$6"

    echo "$num_vulnerabilidad. Vulnerabilidad en $archivo ($gravedad)"
    echo "   - Descripción: $descripcion"
    echo "   - Recomendación: $recomendacion"
    echo ""
}

function mostrar_resumen {
    echo "----------------------------------------------------"
    echo "RESUMEN"
    echo "----------------------------------------------------"
    echo ""
    echo "- Total de Vulnerabilidades Detectadas: $1"
    echo ""
    echo "----------------------------------------------------"
}

echo "Ingrese la ruta absoluta al directorio del proyecto:"
read PROYECTO_DIR

if [ ! -d "$PROYECTO_DIR" ]; then
    echo "¡Error! La ruta '$PROYECTO_DIR' no es un directorio válido."
    exit 1
fi

CPPCHECK_OPTS="--enable=all --inconclusive --force"

cppcheck $CPPCHECK_OPTS "$PROYECTO_DIR" 2> "$PROYECTO_DIR/tmp_reporte_cppcheck.txt"

if [ $? -ne 0 ]; then
    echo "Error al ejecutar cppcheck. Verifique la configuración y la ruta del proyecto."
    exit 1
fi

mostrar_encabezado "MiProyecto en C/C++"

total_vulnerabilidades=0

while IFS= read -r linea
do
    if [[ $linea == *"warning"* || $linea == *"error"* ]]; then
        archivo=$(echo "$linea" | cut -d':' -f1)
        descripcion=$(echo "$linea" | cut -d':' -f3-)
        recomendacion="Revisar y corregir el problema identificado."
        gravedad="Alta"  # Se puede determinar la gravedad según el tipo de mensaje (warning/error)

        mostrar_vulnerabilidad "$linea" "$(($total_vulnerabilidades + 1))" "$archivo" "$descripcion" "$recomendacion" "$gravedad"
        ((total_vulnerabilidades++))
    fi
done < "$PROYECTO_DIR/tmp_reporte_cppcheck.txt"

mostrar_resumen "$total_vulnerabilidades"

rm "$PROYECTO_DIR/tmp_reporte_cppcheck.txt"
