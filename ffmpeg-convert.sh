#!/usr/bin/env zsh

function usage() {
    echo "Usage: $(basename $0) <quality> [-m] <input-file(s)> [<other-args>]"
    echo "       $(basename $0) copy      [-m] <input-file(s)> [<other-args>]"
    echo ""
    echo "       If 'copy' is specified, the video stream is not re-encoded."
    echo "       if quality 0..51 is specified, the video strean is re-encoded."
    echo "       If -m is used, you can specify multiple files (but no other-args can be specified)."
    echo ""
    echo "Examples:"
    echo '       ffmpeg-convert.sh copy my_movie.mkv                    -- copies video stream (fast)'
    echo '       ffmpeg-convert.sh copy -m file1.mkv file2.mkv          -- copies 2 files (fast)'
    echo '       ffmpeg-convert.sh 20 my_movie.mov                      -- re-encodes video stream'
    echo '       ffmpeg-convert.sh 25 my_movie.mov -vf "scale=640:480"  -- same, and resizes'
    echo '       ffmpeg-convert.sh 25 my_movie.mov -vf "scale=640:-1"'
    echo '       ffmpeg-convert.sh 25 my_movie.mov -vf "scale=-1:480"'
    echo '       ffmpeg-convert.sh 25 my_movie.mov -vf "scale=iw/2:ih/2"'
}

function convert() {
    Q="$1"
    IN="$2"
    shift 2

    OUT="$IN"_$$.mp4
    IN_BAK="$IN"_original
    echo "Backup original file: $IN_BAK..."

    cp "$IN" "$IN_BAK"
    if [[ $? -ne 0 ]]
    then
        echo "Aborted..."
        rm -f "$IN_BAK"
        exit -1
    fi

    if [[ "$Q" == "copy" ]]
    then
        echo "Copying video stream (not re-encoding)..."
        echo "----------------"
        echo "ffmpeg -loglevel info -y -i \"$IN\" -codec copy $* \"$OUT\""
        echo "----------------"
        ffmpeg -loglevel info -y -i "$IN" -codec copy $* "$OUT"
    else
        echo "Re-encoding video stream (quality $Q)..."
        echo "----------------"
        echo "ffmpeg -loglevel info -y -i \"$IN\" -vcodec libx264 -crf $Q $* \"$OUT\""
        echo "----------------"
        ffmpeg -loglevel info -y -i "$IN" -vcodec libx264 -crf $Q $* "$OUT"
    fi
    if [[ $? -ne 0 ]]
    then
        echo "Aborted..."
        if [[ ! -z "$OUT" && -f "$OUT" ]]
        then
            rm -f "$OUT"
        fi
        if [[ ! -z "$IN_BAK" && -f "$IN_BAK" ]]
        then
            mv -f "$IN_BAK" "$IN"
        fi
        exit -1
    else
        FILENAME_ONLY=$(basename -- "$IN")
        EXT="${FILENAME_ONLY##*.}"
        FILENAME=$(basename $FILENAME_ONLY .$EXT)
        echo ""
        mv "$OUT" "$FILENAME.mp4"
        if [[ "$FILENAME.mp4" != "$IN" ]]
        then
            rm "$IN_BAK"
            echo "Original : $IN (from .$EXT to .mp4)"
            echo "Converted: $FILENAME.mp4"
        else
            echo "Original : $IN_BAK"
            echo "Converted: $IN"
        fi
    fi
}

if [[ $# -lt 2 ]]
then
    usage
    exit 1
fi
Q=23
if [[ -n "$1" && "$1" -eq "$1" ]] 2>/dev/null
then
    if [[ "$1" -lt 0 || "$1" -gt 51 ]]
    then
        usage
        echo ""
        echo "Error: quality out of range"
        exit 1
    fi
    Q="$1"
elif [[ "$1" != "copy" ]]
then
    usage
    echo ""
    echo "Error: specify 'copy' or 0-51 for quality"
    exit 1
fi

trap 'echo "\nInterrupted..."' INT

shift
if [[ "$1" == "-m" ]]
then
    shift
    echo "Converting multiple files ($Q)..."
    ERRORS=""
    while [[ $# -ne 0 ]]
    do
        if [[ ! -f "$1" ]]
        then
            echo "ERROR: $1 is not a file! skipping..."
            ERRORS="$ERRORS $1"
        else
            convert $Q "$1"
        fi
        shift
    done
    if [[ "$ERRORS" != "" ]]
    then
        echo "The following arguments were not files:"
        echo "$ERRORS"
    fi 
else
    if [[ -f $2 ]]
    then
        usage
        echo ""
        echo "Error: converting multiple files requires use of '-m' switch"
        exit 1
    fi
    echo "Converting a single file ($Q)..."
    convert $Q "$1"
fi
