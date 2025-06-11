pkgname="movshrink"
pkgver="0.3.0"
pkgrel="2"
pkgdesc="Wrapper shell script that uses ffmpeg to compress MOV files"
#arch=("x86_64")
arch=("any")
depends=(
'ffmpeg'
'bash'
'grep'
'bc'
)
license=("GPL-3.0-or-later")
source=("movshrink-one.sh" 
	"movshrink.sh")

sha512sums=("SKIP"
	    "SKIP")

package() {
    mkdir -p "${pkgdir}/usr/bin"
    cp "${srcdir}/movshrink-one.sh"    "${pkgdir}/usr/bin/movshrink-one"
    cp "${srcdir}/movshrink.sh"        "${pkgdir}/usr/bin/movshrink"
    chmod +x "${pkgdir}/usr/bin/movshrink-one"
    chmod +x "${pkgdir}/usr/bin/movshrink"
}