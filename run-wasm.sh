#!/usr/bin/env bash

wasm32-wasi-cabal build all
wasmtime --wasm exceptions $(find dist-newstyle/build/wasm32-wasi -name "minimal-example.wasm" -type f | head -n 1)
