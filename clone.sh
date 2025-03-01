#!/bin/bash

echo "Introduce el url de descarga:"
read CLONE
echo -n ""
echo "Introduce el nombre de la carpeta:"
read CARPETA
echo -n ""
git clone "$CLONE" "$CARPETA"

