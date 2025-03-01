#!/bin/bash

function selector {
  echo -e "Introduce el número de la elección:\n 1) Introducir commit manualmente\n 2) Commit automático basado en cambios"
  read ELEC

  # Verifica si hay cambios en el repositorio
  if ! git diff --quiet || ! git diff --staged --quiet; then
    echo "Generando documentación de cambios..."
    git log --pretty=format:"%h - %an, %ar : %s" > CHANGELOG.md
    git add CHANGELOG.md
  fi

  git add .

  DIA=$(date +"%d/%m/%Y")
  HORA=$(date +"%H:%M")

  if [[ $ELEC == 1 ]]; then
    echo "Introduce el mensaje del commit:"
    read COMMIT
    git commit -m "$COMMIT [$DIA $HORA]"
    git push
  elif [[ $ELEC == 2 ]]; then
    # Generar un commit basado en los archivos modificados
    CAMBIOS=$(git diff --name-only --staged)

    if [[ -z "$CAMBIOS" ]]; then
      echo "No hay cambios para commitear."
      exit 0
    fi

    COMMIT_MSG="Actualización de: $(echo $CAMBIOS | tr '\n' ' ') [$DIA $HORA]"
    git commit -m "$COMMIT_MSG"
    git push
  else
    echo "Opción inválida"
  fi
}

selector
