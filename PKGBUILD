# Maintainer: Marius Knaust <marius.knaust@gmail.com>
# Contributor: dpellegr

pkgname=spotlight
pkgver=32.64dc1db
pkgrel=1
pkgdesc="Displays a new background image daily"
arch=('any')
license=('GPL')
url="https://github.com/dpellegr/spotlight"
install=spotlight.install
depends=('wget'
         'jq'
         'gnome-settings-daemon'
         'libsystemd')
source=('git+https://github.com/dpellegr/spotlight.git')
md5sums=('SKIP')

pkgver() {
  cd "$pkgname"
  printf "%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}
 
package()
{
	install -m755 -D ${srcdir}/spotlight/spotlight.sh ${pkgdir}/usr/bin/spotlight.sh
	install -m644 -D ${srcdir}/spotlight/spotlight.service ${pkgdir}/usr/lib/systemd/user/spotlight.service
	install -m644 -D ${srcdir}/spotlight/spotlight.timer ${pkgdir}/usr/lib/systemd/user/spotlight.timer
	install -m644 -D ${srcdir}/spotlight/spotlight.desktop ${pkgdir}/usr/share/applications/spotlight.desktop
	install -m644 -D ${srcdir}/spotlight/spotlight.conf ${pkgdir}/etc/spotlight.conf
}

