#!/bin/bash

#Eliminar si existe la 
rm -rf .git

#Clone repo de salida
echo "Introduce el url de descarga:"
read CLONE
echo -n ""
git clone "$CLONE" "borrar"

#Copia del .git al directorio de salida
cp -r borrar/.git .

#Borrar directorio vacio
rm -rf borrar
