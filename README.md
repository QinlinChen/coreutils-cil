# coreutils-merge

We provide a bash script to help you merge and simplify coreutils source code using [CIL](https://people.eecs.berkeley.edu/~necula/cil/)(C Intermediate Language).

## Prerequest

- cil-1.7.3 (installed by `opam`)
- gcc-4.8 (installed by `apt` on Ubuntu 20.04)
- musl-1.2.1 (compiled from the source code)
- coreutils source code (v8.32 is what we use).

## Usage

1. modify the `coreutils_dir` variable in `merge-utils.sh` to indicate where is the directory of the coreutils project.
2. use `./merge-utils.sh configure` to configure coreutils.
3. use `./merge-utils.sh patch-all` to patch coreutils so that `cilly` (CIL driver) is used during compilation.
4. `cd` to your coreutils project and use `make` to compile. It is ok to fail on the target `gnulib-tests`. Once completed, you should find the merged and simplified `*_comb.c` files and corresponding binary files in the coreutils `src` directory.

## Test
1. use `./merge-utils.sh save-all` to save `*_comb.c` and binaries in coreutils to this directory. You can find them in the new created `bin` and `src` directory.
2. use `./merge-utils.sh unpatch-makefile Makefile` to turn coreutils makefile back as to compile without CIL.
3. `cd` to your coreutils project and use `make` to compile. It should success.
4. use `./merge-utils.sh replace-bin` to replace the new binaries with our previous compiled ones that we want to test.
5. `cd` to your coreutils project and use `make check` to test.