#!/bin/bash
source ./error.sh
export PARENT_DIR="$(dirname `pwd`)"
export OUTPUT_DIR="$PARENT_DIR/out/golang_all"
mkdir -p $OUTPUT_DIR || error_exit "$LINENO: An error has occurred."
protoc --go_out=plugins=grpc:$OUTPUT_DIR \
                 --proto_path=$PARENT_DIR \
                $PARENT_DIR/*.proto || error_exit "$LINENO: An error has occurred when generating the client"