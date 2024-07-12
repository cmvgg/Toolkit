#!/bin/bash

function selector {
  echo -e "Introduce el numero de la eleccion:\n 1 introducir commit\n 2 commit por lintern"
  read ELEC

  echo "Generando documentación de cambios..."
  git log --pretty=format:"%h - %an, %ar : %s" > CHANGELOG.md

  git add .
  if [[ $ELEC == 1 ]]; then
    echo "Introduce el commit:"
    read COMMIT
    DIA=$(date +"%d/%m/%Y")
    HORA=$(date +"%H:%M")
    git commit -m "$COMMIT $DIA--$HORA"
    git push
  elif [[ $ELEC == 2 ]]; then
    echo "Revisando el código con ESLint..."
    eslint . --fix
    echo "Revisando el código con Prettier..."
    prettier --write .
    echo "Realizando commit de las correcciones..."
    DIA=$(date +"%d/%m/%Y")
    HORA=$(date +"%H:%M")
    git commit -m "Correcciones de linting $DIA--$HORA"
    git push
  else
    echo "Opcion invalida"
  fi
}

selector

