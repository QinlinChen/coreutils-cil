#! /bin/bash
project_dir=$HOME/workspace/coreutils-8.32
merge_dir=`pwd`

function help() {
    echo "Usage: $0 COMMANDS [OPTIONS]...

COMMANDS
    configure
    patch-makefile <src> <dst>
    patch-inline
    patch-static-assert
    patch-all
    export-comb
    export-bin"
}

function do_configure() {
    cd $project_dir && $project_dir/configure CC="musl-gcc -std=gnu99" --prefix=$HOME/local/coreutils
}

function do_patch_makefile() {
    tmpfile=$(mktemp)
    sed "s/^AR =.*$/AR = cilly --merge --mode=AR/" $project_dir/$1 | 
        sed "s/^CC =.*$/CC = cilly --merge --gcc=\"musl-gcc -std=gnu99\" --save-temps=\/tmp\/coreutils-cil/" |
        sed "s/^CPP =.*$/CPP = cilly --merge --gcc=\"musl-gcc -std=gnu99\" --save-temps=\/tmp\/coreutils-cil -E/" |
        sed "s/^LDFLAGS =.*$/LDFLAGS = --keepmerged/" |
        sed "s/^RANLIB =.*$/RANLIB = echo #ranlib/" > tmpfile
    mv tmpfile $project_dir/$2
}

function do_patch_inline() {
    config_file=$project_dir/lib/config.h
    last_line=$(grep -v "^$" $config_file | tail -n 1)
    if [ "$last_line" == "#define _GL_EXTERN_INLINE static inline" ]; then
        echo inline already patched && return 0
    fi
    cat >> $config_file <<EOF
#ifdef _GL_INLINE
#undef _GL_INLINE
#endif

#ifdef _GL_EXTERN_INLINE
#undef _GL_EXTERN_INLINE
#endif

#define _GL_INLINE static inline
#define _GL_EXTERN_INLINE static inline
EOF
}

function do_patch_static_assert() {
    verify_file=$project_dir/lib/verify.h
    if [ -n "$(grep 'FIXME(QinlinChen)' $verify_file)" ]; then
        echo static assert already patched && return 0
    fi
    patch_line="#define _Static_assert(EXP, MSG) /* FIXME(QinlinChen): Delete this hack. */"
    sed -i "/define _GL_HAVE__STATIC_ASSERT 1/a$patch_line" $verify_file
}

function do_export_comb() {
    mkdir -p $merge_dir/src
    find $project_dir/src -name "*_comb.c" | xargs cp -t $merge_dir/src
}

function do_export_bin() {
    mkdir -p $merge_dir/bin
    find $project_dir/src -executable -type f \! -name "dcgen" \! -name "*.so" | xargs cp -t $merge_dir/bin
}

if [ $# -lt 1 ]; then
    help && exit 1
fi

case $1 in
  configure)
    do_configure
    ;;
  patch-makefile)
    if [ $# -lt 3 ]; then
       help && exit 1
    fi
    do_patch_makefile $2 $3
    ;;
  patch-inline)
    do_patch_inline
    ;;
  patch-static-assert)
    do_patch_static_assert
    ;;
  patch-all)
    do_patch_makefile Makefile Makefile && do_patch_inline && do_patch_static_assert
    ;;
  export_comb)
    do_export_comb
    ;;
  export_bin)
    do_export_bin
    ;;
  *)
    help
    ;;
esac
