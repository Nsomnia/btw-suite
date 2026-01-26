# Maintainer: Nsomnia <nsomnia@users.noreply.github.com>
pkgname=btw-suite
pkgver=0.1.0
pkgrel=1
pkgdesc="The ultimate Arch Linux tweak suite for the absolute Chad. I use Arch, btw."
arch=('any')
url="https://github.com/Nsomnia/btw-suite"
license=('MIT')
depends=('rate-mirrors' 'bash')
optdepends=('gum: for future interactive features'
            'dialog: for future interactive features')
source=("git+https://github.com/Nsomnia/btw-suite.git")
sha256sums=('SKIP')

package() {
  cd "$srcdir/$pkgname"

  # Install the main mirror ranking script
  install -Dm755 scripts/rank-mirrors.sh "$pkgdir/usr/bin/btw-rank-mirrors"

  # Install the Chad library
  install -Dm644 lib/chad.sh "$pkgdir/usr/lib/btw-suite/chad.sh"

  # Install systemd units
  install -Dm644 systemd/btw-mirror-rank.service "$pkgdir/usr/lib/systemd/system/btw-mirror-rank.service"
  install -Dm644 systemd/btw-mirror-rank.timer "$pkgdir/usr/lib/systemd/system/btw-mirror-rank.timer"

  # Install assets
  install -Dm644 assets/logo.svg "$pkgdir/usr/share/btw-suite/logo.svg"

  # Install documentation and license
  install -Dm644 README.md "$pkgdir/usr/share/doc/$pkgname/README.md"
  install -Dm644 CHANGELOG.md "$pkgdir/usr/share/doc/$pkgname/CHANGELOG.md"
  install -Dm644 CONTRIBUTING.md "$pkgdir/usr/share/doc/$pkgname/CONTRIBUTING.md"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
