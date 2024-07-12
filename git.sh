#/bin/bash

git add .
echo "Introduce el commit:"
read COMMIT
echo -n ""
DIA=`date +"%d/%m/%Y"`
HORA=`date +"%H:%M"`
git commit -m "$COMMIT $DIA--$HORA "
git push --force
