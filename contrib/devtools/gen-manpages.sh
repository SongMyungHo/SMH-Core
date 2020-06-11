#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

SONGMYUNGHOD=${SONGMYUNGHOD:-$SRCDIR/songmyunghod}
SONGMYUNGHOCLI=${SONGMYUNGHOCLI:-$SRCDIR/songmyungho-cli}
SONGMYUNGHOTX=${SONGMYUNGHOTX:-$SRCDIR/songmyungho-tx}
SONGMYUNGHOQT=${SONGMYUNGHOQT:-$SRCDIR/qt/songmyungho-qt}

[ ! -x $SONGMYUNGHOD ] && echo "$SONGMYUNGHOD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
LTCVER=($($SONGMYUNGHOCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$SONGMYUNGHOD --version | sed -n '1!p' >> footer.h2m

for cmd in $SONGMYUNGHOD $SONGMYUNGHOCLI $SONGMYUNGHOTX $SONGMYUNGHOQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${LTCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${LTCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m