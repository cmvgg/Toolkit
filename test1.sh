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
    local total_vulnerabilidades="$1"
    local total_graves="$2"
    local total_medias="$3"

    echo "----------------------------------------------------"
    echo "RESUMEN"
    echo "----------------------------------------------------"
    echo ""
    echo "- Total de Vulnerabilidades Detectadas: $total_vulnerabilidades"
    echo "  - Vulnerabilidades Graves: $total_graves"
    echo "  - Vulnerabilidades Medias: $total_medias"
    echo ""
    echo "----------------------------------------------------"
}


echo "Ingrese la ruta absoluta al directorio del proyecto:"
read PROYECTO_DIR

if [ ! -d "$PROYECTO_DIR" ]; then
    echo "¡Error! La ruta '$PROYECTO_DIR' no es un directorio válido."
    exit 1
fi

rm "$PROYECTO_DIR/tmp_reporte_cppcheck.txt"

CPPCHECK_OPTS="--enable=all --inconclusive --force"

cppcheck $CPPCHECK_OPTS "$PROYECTO_DIR" 2> "$PROYECTO_DIR/tmp_reporte_cppcheck.txt"

if [ $? -ne 0 ]; then
    echo "Error al ejecutar cppcheck. Verifique la configuración y la ruta del proyecto."
    exit 1
fi

mostrar_encabezado "MiProyecto en C/C++"

total_vulnerabilidades=0
total_graves=0
total_medias=0

while IFS= read -r linea
do
    if [[ $linea == *"error"* ]]; then
        archivo=$(echo "$linea" | cut -d':' -f1)
        descripcion=$(echo "$linea" | cut -d':' -f3-)
        recomendacion="Revisar y corregir el problema identificado."
        gravedad="Alta"

        mostrar_vulnerabilidad "$linea" "$(($total_vulnerabilidades + 1))" "$archivo" "$descripcion" "$recomendacion" "$gravedad"
        ((total_vulnerabilidades++))
        ((total_graves++))

     elif [[ $linea == *"warning"* ]]; then
	archivo=$(echo "$linea" | cut -d':' -f1)
	descripcion=$(echo "$linea" | cut -d':' -f3-)
	recomendacion="Revisar y si es posible y coherente corregir el problema identificado"
	gravedad="Media o baja" 

        mostrar_vulnerabilidad "$linea" "$(($total_vulnerabilidades + 1))" "$archivo" "$descripcion" "$recomendacion" "$gravedad"
        ((total_vulnerabilidades++))
        ((total_medias++))

    fi
done < "$PROYECTO_DIR/tmp_reporte_cppcheck.txt"

mostrar_resumen "$total_vulnerabilidades" "$total_graves" "$total_medias"

echo "Debo mostrar el archivo con la definicion de las vulnerabilidaes: Y/N"
read -r vuln
    if [[ $vuln == "Y" || $vuln == "y" ]]; then
	cat "$PROYECTO_DIR/tmp_reporte_cppcheck.txt"
    elif [[ $vuln == "N" || $vuln == "n" ]]; then
	echo ""
    elif [[ $vuln != "Y" || $vuln != "n" || $vuln != "N" || $vuln != "n" ]]; then
	echo "Eleccion erronea"

fi
