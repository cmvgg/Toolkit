## Toolkit

**Toolkit** es un conjunto de scripts de automatización para simplificar el uso de comandos comunes en **Git** y **Docker**, mediante la creación de alias.

## Instalación

Para configurar los alias correctamente, ejecuta el script alias.sh:
   ```sh
   chmod +x alias.sh && ./alias.sh
   ``

Esto establecerá los alias correspondientes para los demás scripts incluidos en este repositorio.

## Scripts incluidos

**alias.sh**

**Descripción:** Automatiza la creación de alias para los siguientes scripts.

**clone.sh**

**Descripción:** Automatiza el comando git clone. 
**Alias:** clone

**dockerclean.sh**

**Descripción:** Automatiza la limpieza de Docker. 
**Alias:** dockerc

**dockerpush.sh**

**Descripción:** Automatiza el docker push. 
**Alias:** dockerp

**git.sh**

**Descripción:** Automatiza git push. 
**Alias:** push

**rp_git.sh**

**Descripción:** Cambia el repositorio Git en una carpeta sustituyendo el archivo .git. 
**Alias:** rp_git

## Uso

Una vez ejecutado alias.sh, puedes utilizar los alias configurados en tu terminal:
   ```sh
   clone
   dockerc
   dockerp
   push
   rp_git

Estos comandos te permitirán ejecutar los scripts de manera más sencilla y rápida.

## Licencia

Este proyecto se distribuye bajo la licencia MIT.
