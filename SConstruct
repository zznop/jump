env = Environment(
    CC='m68k-linux-gnu-gcc',
    AS='m68k-linux-gnu-as',
    LINK='m68k-linux-gnu-ld',
    BUILD_DIR='build',
    CCFLAGS=['-m68000'],
    PYTHON='/usr/bin/python',
)

rom = env.SConscript(
    './SConscript',
    variant_dir='$BUILD_DIR',
    duplicate=False,
    exports=dict(env=env),
)

