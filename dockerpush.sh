#!/bin/bash

	docker ps

	echo "escribe el nombre de la imagen:"
	read imagen
	docker build -t $imagen .

	docker tag $imagen:tag cmvgg/$imagen:tag
	docker push cmvgg/$imagen:tag
