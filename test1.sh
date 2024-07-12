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
    echo "$1. Vulnerabilidad: $2 ($3)"
    echo "   - Descripción: $4"
    echo "   - Recomendación: $5"
    echo "   - Gravedad: $6"
    echo ""
}

function mostrar_resumen {
    echo "----------------------------------------------------"
    echo "RESUMEN"
    echo "----------------------------------------------------"
    echo ""
    echo "- Total de Vulnerabilidades Críticas: $1"
    echo "- Total de Vulnerabilidades Altas: $2"
    echo "- Total de Vulnerabilidades Medias: $3"
    echo "- Total de Vulnerabilidades Bajas: $4"
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

cppcheck $CPPCHECK_OPTS "$PROYECTO_DIR" >> $PROYECTO_DIR/tmp_reporte_cppcheck.txt

mostrar_encabezado "MiProyecto en C/C++"

total_criticas=0
total_altas=0
total_medias=0
total_bajas=0

while IFS= read -r linea
do
    if [[ $linea == *"CRITICAL"* ]]; then
        mostrar_vulnerabilidad 1 "Desbordamiento de búfer" "(CRITICAL)" "Se encontró un posible desbordamiento de búfer en la función 'process_data' en 'file.c'." "Validar las entradas de usuario y asegurarse de que los límites de los búferes se respeten." "Alta"
        ((total_criticas++))
    elif [[ $linea == *"HIGH"* ]]; then
        mostrar_vulnerabilidad 2 "Uso de memoria no inicializada" "(HIGH)" "Uso de variables no inicializadas en la función 'initialize_data' en 'data.cpp'." "Inicializar todas las variables antes de utilizarlas para evitar comportamientos indefinidos." "Alta"
        ((total_altas++))
    elif [[ $linea == *"MEDIUM"* ]]; then
        mostrar_vulnerabilidad 3 "Uso inseguro de funciones de cadena" "(MEDIUM)" "Uso de funciones de cadena inseguras como 'strcpy' en 'util.c'." "Utilizar funciones seguras como 'strncpy' con un tamaño de búfer especificado." "Media"
        ((total_medias++))
    elif [[ $linea == *"LOW"* ]]; then
        mostrar_vulnerabilidad 4 "Uso de punteros no validados" "(LOW)" "Uso de punteros no validados en la función 'process_data' en 'file.cpp'." "Validar los punteros y asegurar que apunten a memoria válida antes de su uso." "Baja"
        ((total_bajas++))
    fi
done < $PROYECTO_DIR/tmp_reporte_cppcheck.txt

mostrar_resumen $total_criticas $total_altas $total_medias $total_bajas


