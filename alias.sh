#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ZSHRC="$HOME/.zshrc"

ALIAS="
alias clone='$DIR/clone.sh'
alias dockerc='$DIR/dockerclean.sh'
alias dockerp='$DIR/dockerpush.sh'
alias test1='docker run -it --rm -v \$(pwd):/proyecto cmvgg/vuln_analisis_tool'
alias push='$DIR/git.sh'
alias rp_git='$DIR/rp_git.sh'
"

if grep -q "alias clone=" "$ZSHRC"; then
    echo "Los alias ya están configurados en $ZSHRC"
else
    echo -e "\n# Alias de Git automáticos\n$ALIAS" >> "$ZSHRC"
    echo "Alias añadidos a $ZSHRC"
fi

chmod +x clone.sh
chmod +x dockerclean.sh
chmod +x dockerpush.sh
chmod +x git.sh
chmod +x rp_git.sh

