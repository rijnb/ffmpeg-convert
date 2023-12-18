#!/bin/bash
if [ $# -ne 1 -o ! -f "$1" ]
then
    echo "Usage: $(basename -- $0) <filename>"
    echo "       e.g. $(basename -- $0) somefile.mp4"
    exit -1
fi
INFILE="$1"

ffmpeg-convert.sh 23 "$INFILE"
if [ $? -eq 0 ]
then
    if [ -f "${INFILE}_original" ]
    then
        eval $(stat -s "$INFILE")
        SIZE1=$st_size
        eval $(stat -s "${INFILE}_original")
        SIZE2=$st_size
        if [[ $SIZE1 -ge $SIZE2 ]]
        then
            echo "$INFILE NOT RECOMPRESSED: reconverted file was $(($SIZE2 - $SIZE1)) bytes larger"
            mv "${INFILE}_original" "$INFILE"
        else
            echo "$INFILE COMPRESSED: saves $((($SIZE2 - $SIZE1) / (1024 * 1024))) Mb ($(($SIZE2 - $SIZE1)) bytes)"
            rm "${INFILE}_original"
        fi
    else
        echo "$INFILE SKIPPED: no original found (${INFILE}_original)"
    fi
else
    exit 1
fi
