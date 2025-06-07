# movshrink

Wrapper shell script that uses ffmpeg to compress MOV files

This program will attempt to compress any *.MOV* file in the current working directory.
And delete the original. Use at own risk!

## About

- `movshrink` is a shell script that acts as a wrapper around the `ffmpeg`[^1] command line tool.
- All the compression work is done by `ffmpeg`.
- The `movshrink` wrapper simply loops through any files it finds in the current working directory with `.MOV` suffixes, passing them to `ffmpeg` with options configured such that a compressed `mp4` version of the original file will be created.
- The wrapper will then delete the original `.MOV` file (if -x has been passed as the second command line argument)

## Usage

-  `$ movshrink`: Attempt to make compressed copies (mp4) of any files with .MOV suffix in the CWD
-  `$ movshrink -u`: The same as above
-  `$ movshrink -t`: The same as above but stop after 5 files have been compressed
-  `$ movshrink -h`: print the help string
-  `$ movshrink -u -x`: Attempt to make compressed copies (mp4) of any files with .MOV suffix in the CWD. Original (MOV) files will be *deleted*
-  `$ movshrink -t -x`: Attempt to make compressed copies (mp4) of any files with .MOV suffix in the CWD. Original (MOV) files will be *deleted*. Stop after 5 iterations.

## Caveats

Only this programme if all the following apply:

- You are happy to accept the risk of something going wrong that results in loss of your MOV files
- You understand that the quality of the compressed mp4 files will be lower than you original MOV files
- You have Reviewed the source code and PKGBUILD to make sure you understand and are happy with what they are going to do! 

## TODO List

- Improve interface output appearance
- Add capability to tidy up after itself
- Add arch build files
- Improve handling of command line options
- Add capability to tidy up and exit gracefully upon receiving CTRL-C interrupts
- Change the result message to be more readable
- Change default operation to not delete original (must be specified by option flag)

### License

> movshrink
> Copyright (c) 2025 Peter Clifton
> Movshrink is an Open Source project and it is licensed
> under the GNU Public License v3 (GPLv3)
> See the full [LICENSE](LICENSE) here

[^1]: [ffmpeg](https://ffmpeg.org/ffmpeg.html), is a universal media converter of the [FFmpeg project](https://ffmpeg.org/)

