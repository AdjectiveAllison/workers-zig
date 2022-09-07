import fs from 'fs'
import path from 'path'
import esbuild from 'esbuild'

esbuild
  .buildSync({
    entryPoints: [
      './test/wasm.ts'
    ],
    format: 'esm',
    sourcemap: true,
    treeShaking: true,
    bundle: true,
    minify: true,
    outfile: './dist/worker.mjs',
    external: ['*.wasm']
  })
