#!/bin/sh
set -eu

root=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
samples="property-access value-and-reference method-dispatch closure-capture enum-state-machine"

contains() {
  pattern="$1"
  file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -q "$pattern" "$file"
  else
    grep -Eq "$pattern" "$file"
  fi
}

for sample in $samples; do
  "$root/scripts/compiler-lab.sh" "$sample" debug >/dev/null
  output="$root/.artifacts/compiler-lab/$sample"
  for file in silgen.sil canonical.sil llvm.ll debug.s optimized.s symbols.txt; do
    test -s "$output/$file"
  done
done

contains 'propertyAccess' "$root/.artifacts/compiler-lab/property-access/symbols.txt"
contains 'valueAndReference' "$root/.artifacts/compiler-lab/value-and-reference/symbols.txt"
contains 'methodDispatch' "$root/.artifacts/compiler-lab/method-dispatch/symbols.txt"
contains 'closureCapture' "$root/.artifacts/compiler-lab/closure-capture/symbols.txt"
contains 'enumStateMachine' "$root/.artifacts/compiler-lab/enum-state-machine/symbols.txt"
contains 'class_method' "$root/.artifacts/compiler-lab/method-dispatch/silgen.sil"
contains 'witness_method' "$root/.artifacts/compiler-lab/method-dispatch/canonical.sil"
contains 'switch_enum' "$root/.artifacts/compiler-lab/enum-state-machine/canonical.sil"
contains 'weak|strong_retain|strong_release' "$root/.artifacts/compiler-lab/closure-capture/canonical.sil"
contains 'didset|setter|getter' "$root/.artifacts/compiler-lab/property-access/canonical.sil"

echo "Compiler lab: 5 samples generated and validated"
