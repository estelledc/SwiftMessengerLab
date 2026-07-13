#!/bin/sh
set -eu

sample="${1:-property-access}"
mode="${2:-debug}"

case "$sample" in
  property-access) source_name="PropertyAccess"; symbol="propertyAccess"; module="PropertyAccessLab" ;;
  value-and-reference) source_name="ValueAndReference"; symbol="valueAndReference"; module="ValueAndReferenceLab" ;;
  method-dispatch) source_name="MethodDispatch"; symbol="methodDispatch"; module="MethodDispatchLab" ;;
  closure-capture) source_name="ClosureCapture"; symbol="closureCapture"; module="ClosureCaptureLab" ;;
  enum-state-machine) source_name="EnumStateMachine"; symbol="enumStateMachine"; module="EnumStateMachineLab" ;;
  *) echo "Unknown SAMPLE: $sample" >&2; exit 2 ;;
esac

case "$mode" in
  debug|optimized) ;;
  *) echo "MODE must be debug or optimized" >&2; exit 2 ;;
esac

root=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
source_file="$root/CompilerLab/Samples/$source_name.swift"
output="$root/.artifacts/compiler-lab/$sample"
sdk=$(xcrun --sdk iphonesimulator --show-sdk-path)
swiftc=$(xcrun --find swiftc)
demangle=$(xcrun --find swift-demangle)
target="arm64-apple-ios17.0-simulator"

mkdir -p "$output"
common="-parse-as-library -sdk $sdk -target $target -module-name $module"

# shellcheck disable=SC2086
"$swiftc" $common -Onone -emit-silgen "$source_file" -o "$output/silgen.sil"
# shellcheck disable=SC2086
"$swiftc" $common -Onone -emit-sil "$source_file" -o "$output/canonical.sil"
# shellcheck disable=SC2086
"$swiftc" $common -Onone -emit-ir "$source_file" -o "$output/llvm.ll"
# shellcheck disable=SC2086
"$swiftc" $common -Onone -emit-assembly "$source_file" -o "$output/debug.s"
# shellcheck disable=SC2086
"$swiftc" $common -O -emit-assembly "$source_file" -o "$output/optimized.s"

rg -o '\$s[A-Za-z0-9_]+' "$output/silgen.sil" "$output/canonical.sil" "$output/debug.s" "$output/optimized.s" \
  | sed 's/^[^:]*://' | sort -u | "$demangle" > "$output/symbols.txt"

for input in silgen.sil canonical.sil llvm.ll debug.s optimized.s; do
  rg -n -C 8 "$symbol|class_method|witness_method|strong_(retain|release)|swift_(retain|release)|switch_enum" \
    "$output/$input" | head -n 160 > "$output/$input.excerpt.txt" || true
done

focus="$output/debug.s.excerpt.txt"
if [ "$mode" = "optimized" ]; then focus="$output/optimized.s.excerpt.txt"; fi

printf '%s\n' \
  "Swift Compiler Lab: $sample" \
  "Target: $target" \
  "Focus: $mode" \
  "Source: CompilerLab/Samples/$source_name.swift" \
  "Outputs: SILGen, canonical SIL, LLVM IR, debug ARM64, optimized ARM64" \
  "Symbols: $output/symbols.txt" \
  "Focused excerpt: $focus" > "$output/README.txt"

echo "Generated $output"
echo "Read $focus"
