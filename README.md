# movshrink

This program will attempt to compress any *.MOV* file in the current working directory.
And delete the original. Use at own risk!

## About

*movshrink* is a shell script that acts as a wrapper around the `ffmpeg` command line tool. All the
compression work is done by `ffmpeg`. The `movshrink` wrapper simply loops through any files it finds in the
CWD with `.MOV` suffixes, passing them to `ffmpeg` with options configured such that a compressed `mp4`
version of the original file will be created.  The wrapper will then delete the original `.MOV` file.

(ffmpeg)[https://ffmpeg.org/ffmpeg.html] is a universal media converter of [FFmpeg project](https://ffmpeg.org/)

## Usage

-  `$ movshrink`: Attempt to compress any files with .MOV suffix in the CWD. Original files will be deleted.
-  `$ movshrink -t`: Attempt to compress files with .MOV suffix in the CWD, stop after 5 files have been compressed. Original files will be deleted.
