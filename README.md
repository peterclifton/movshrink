# movshrink

Wrapper shell script that uses ffmpeg to compress MOV files

This program will attempt to compress any *.MOV* file in the current working directory.
And delete the original. Use at own risk!

## About

- `movshrink` is a shell script that acts as a wrapper around the `ffmpeg`[^1] command line tool.
- All the compression work is done by `ffmpeg`.

## Usage

### Synopsis

**`movshrink [-htux]`**

### Description

The `movshrink` utility loops through any files it finds in the current working dir with `.MOV` suffixes, passing them to `ffmpeg` with options configured such that a compressed `mp4` version of the original file will be created. The original `.MOV` file will then be deleted (if -x has been passed as a command line option).

The following options are available:

| Option | Description |
| ------ | ----------- |
|**-h**   | Print a brief help message |
|**-t**   | Stop after five iterations |
|**-u**   | Keep going until have looped through all MOV files in the current directory (or until a Ctrl-C interrupt)|
|**-x**   | After each compression, delete the original MOV file |

### Examples

```sh
$ movshrink
# Make compressed copies (mp4) of files with `.MOV` suffix in the current working directory
```      
```sh
$ movshrink -u
# Same as above
```
```sh
$ movshrink -t
# Same as above but stop after 5 files have been compressed
```
```sh
$ movshrink -ux
# Make compressed copies (mp4) files with `.MOV` suffix in the current working dir
# Original (MOV) files will be deleted
```
```sh
$ movshrink -tx
Same as above, but stops after 5 files have been compressed
```
```sh
$ movshrink -h
# print help string
```

### Caveats

Only this programme if all the following apply:

- You are happy to accept the risk of something going wrong that could result in the loss of your MOV files
- You understand that the quality of the compressed mp4 files will be lower than you original MOV files
- You have reviewed the source code and PKGBUILD to make sure you understand and are happy with what they are going to do! 

## Install

### Method 1: Installing on Arch Linux as a package

- `$ mkdir buildfolder`
- `$ cd buildfolder`
- `$ git clone https://github.com/peterclifton/movshrink.git`
- `$ cd movshrink`
- Review [PKGBUILD](PKGBUILD) and all other files in *buildfolder* to make sure you understand and are happy with what they are going to do! (If not modify them until you are happy with them!)
- `$ sudo pacman -S --needed base-devel` (install base-devel if not already installed)`
- `$ makepkg -src`
- `$ sudo pacman -U movshrink-<version>.pkg.tat.zst`

### Method 2

- Make sure your system has all the dependencies installed (e.g. such as `ffmpeg` and any others listed under _depends_ in [PKGBUILD](PKGBUILD))
- Review _movshrink-one.sh_ and _movshrink.sh_ to make sure you understand and are happy with what they are doing! (If not modify them until you are happy with them!)
- Download them and place them in a directory in your [PATH](https://wiki.archlinux.org/title/environment_variables#Globally) (you might have a [~/bin](https://stackoverflow.com/questions/20054538/add-a-bash-script-to-path) for example)
- Rename them to _movshrink-one_ and _movshrink_
- Make them executable


## License

> movshrink
>
> Copyright (c) 2025 Peter Clifton
>
> movshrink is an Open Source project and it is licensed
> under the GNU Public License v3 (GPLv3)
> See the full [LICENSE](LICENSE) here

[^1]: [ffmpeg](https://ffmpeg.org/ffmpeg.html), is a universal media converter of the [FFmpeg project](https://ffmpeg.org/)

