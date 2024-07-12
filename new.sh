#!/bin/bash
echo "Introduce el nombre del nuevo repositorio:"
read REPO
mkdir $REPO
cd $REPO
echo "Introduce el primer commit:"
read COMMIT
git init
touch README.md
echo "# $REPO" >> README.md
git add README.md
git commit -m "$COMMIT"
git remote add origin git@github.com:cmvgg/$REPO.git
git push -u origin master

