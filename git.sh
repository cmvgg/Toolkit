#!/bin/bash

function selector {
  echo -e "Introduce el número de la elección:\n 1) Introducir commit manualmente\n 2) Commit automático basado en cambios"
  read ELEC

git add .

  CAMBIOS=$(git diff --name-only --cached | grep -v "CHANGELOG.md" | tr '\n' ' ')

  DIA=$(date +"%d/%m/%Y")
  HORA=$(date +"%H:%M")

  if [[ $ELEC == 1 ]]; then
    echo "Introduce el mensaje del commit:"
    read COMMIT
    git commit -m "$COMMIT [$DIA $HORA]"
    git push
  elif [[ $ELEC == 2 ]]; then
    if [[ -z "$CAMBIOS" ]]; then
      COMMIT_MSG="Pequeñas actualizaciones [$DIA $HORA]"
    else
      COMMIT_MSG="Actualización de: $CAMBIOS [$DIA $HORA]"
    fi

    git commit -m "$COMMIT_MSG"
    git push
  else
    echo "Opción inválida"
  fi
}

selector
