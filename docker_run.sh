#! /bin/bash

docker run -it --mount type=bind,source=/Users/jjlee/Docker/Gen/case-studies,target=/probcomp/Gen/case-studies --name gen_JJL20191222 -p 8080:8080 -p 8090:8090 -p 8091:8091 -p 8092:8092 gen:JJL20191222
