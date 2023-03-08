# FFMPEG converter

This is a tiny Zsh script to help convert a video file from any format to mp4.

## Prerequisites

You need to have ffmpeg installed on your machine. On a Mac, you may want to use
Brew to install it, like `brew install ffmpeg`.

## Usage

```
Usage: usage <quality> [-m] <input-file(s)> [<other-args>]
       usage copy      [-m] <input-file(s)> [<other-args>]

       If 'copy' is specified, the video stream is not re-encoded.
       if quality 0..51 is specified, the video strean is re-encoded.
       If -m is used, you can specify multiple files (but no other-args can be specified).

Examples:
       ffmpeg-convert.sh copy my_movie.mkv                    -- copies video stream (fast)
       ffmpeg-convert.sh copy -m file1.mkv file2.mkv          -- copies 2 files (fast)
       ffmpeg-convert.sh 20 my_movie.mov                      -- re-encodes video stream
       ffmpeg-convert.sh 25 my_movie.mov -vf "scale=640:480"  -- same, and resizes
       ffmpeg-convert.sh 25 my_movie.mov -vf "scale=640:-1"
       ffmpeg-convert.sh 25 my_movie.mov -vf "scale=-1:480"
       ffmpeg-convert.sh 25 my_movie.mov -vf "scale=iw/2:ih/2"
```

So, if you specify **copy** on the commandline as a first parameter, the video stream
is simply copied from the original file and put into the mp4 file. This is extremely fast.

If you specify a re-encoding quality (between 0 and 51), encoding may take quite a while,
depending on the length of the video and the processing power of your CPU.
