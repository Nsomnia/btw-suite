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
source=("scripts/rank-mirrors.sh"
        "lib/chad.sh"
        "systemd/btw-mirror-rank.service"
        "systemd/btw-mirror-rank.timer"
        "assets/logo.svg"
        "README.md"
        "CHANGELOG.md"
        "CONTRIBUTING.md"
        "LICENSE")
sha256sums=('SKIP'
            'SKIP'
            'SKIP'
            'SKIP'
            'SKIP'
            'SKIP'
            'SKIP'
            'SKIP'
            'SKIP')

package() {
  # Install the main mirror ranking script
  install -Dm755 "$srcdir/rank-mirrors.sh" "$pkgdir/usr/bin/btw-rank-mirrors"

  # Install the Chad library
  install -Dm644 "$srcdir/chad.sh" "$pkgdir/usr/lib/btw-suite/chad.sh"

  # Install systemd units
  install -Dm644 "$srcdir/btw-mirror-rank.service" "$pkgdir/usr/lib/systemd/system/btw-mirror-rank.service"
  install -Dm644 "$srcdir/btw-mirror-rank.timer" "$pkgdir/usr/lib/systemd/system/btw-mirror-rank.timer"

  # Install assets
  install -Dm644 "$srcdir/logo.svg" "$pkgdir/usr/share/btw-suite/logo.svg"

  # Install documentation and license
  install -Dm644 "$srcdir/README.md" "$pkgdir/usr/share/doc/$pkgname/README.md"
  install -Dm644 "$srcdir/CHANGELOG.md" "$pkgdir/usr/share/doc/$pkgname/CHANGELOG.md"
  install -Dm644 "$srcdir/CONTRIBUTING.md" "$pkgdir/usr/share/doc/$pkgname/CONTRIBUTING.md"
  install -Dm644 "$srcdir/LICENSE" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
