Import('env')

sources = [
    './src/jump.S',
]

obj = env.Object(
    source=sources,
)

bin = env.Command(
    'jump-nocheck.bin',
    obj,
    '$LINK -Ttext 0 --oformat binary -o $TARGET $SOURCE'
 )

# TODO: make a scons tool
fixed_bin = env.Command(
    'jump.bin',
    bin,
    '$PYTHON ./tools/checksum.py --out $TARGET $SOURCE',
)

Return('fixed_bin')

