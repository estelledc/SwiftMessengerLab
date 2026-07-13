#!/bin/sh
set -eu

root=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
samples="property-access value-and-reference method-dispatch closure-capture enum-state-machine"

for sample in $samples; do
  "$root/scripts/compiler-lab.sh" "$sample" debug >/dev/null
  output="$root/.artifacts/compiler-lab/$sample"
  for file in silgen.sil canonical.sil llvm.ll debug.s optimized.s symbols.txt; do
    test -s "$output/$file"
  done
done

rg -q 'propertyAccess' "$root/.artifacts/compiler-lab/property-access/symbols.txt"
rg -q 'valueAndReference' "$root/.artifacts/compiler-lab/value-and-reference/symbols.txt"
rg -q 'methodDispatch' "$root/.artifacts/compiler-lab/method-dispatch/symbols.txt"
rg -q 'closureCapture' "$root/.artifacts/compiler-lab/closure-capture/symbols.txt"
rg -q 'enumStateMachine' "$root/.artifacts/compiler-lab/enum-state-machine/symbols.txt"
rg -q 'class_method' "$root/.artifacts/compiler-lab/method-dispatch/silgen.sil"
rg -q 'witness_method' "$root/.artifacts/compiler-lab/method-dispatch/canonical.sil"
rg -q 'switch_enum' "$root/.artifacts/compiler-lab/enum-state-machine/canonical.sil"
rg -q 'weak|strong_retain|strong_release' "$root/.artifacts/compiler-lab/closure-capture/canonical.sil"
rg -q 'didset|setter|getter' "$root/.artifacts/compiler-lab/property-access/canonical.sil"

echo "Compiler lab: 5 samples generated and validated"
