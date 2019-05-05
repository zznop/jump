# genflag.py
#
# This script is part of jump, a project released under a 
# [MIT](https://github.com/zznop/jump/LICENSE.md) license.

import argparse
import struct

BASE_TILE_ID = 0x0002

def parse_args():
    '''Parse command line arguments
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--fkey1', type=int, default=0x4553,
        help='Flag key 1')
    parser.add_argument('-F', '--fkey2', type=int, default=0x4147,
        help='Flag key 2')
    parser.add_argument('-t', '--text', required=True,
        help='Flag text')
    parser.add_argument('-o', '--out', default='flag.bin',
        help='File to export flag to')
    return parser.parse_args()

def xor_flag(key1, key2, data):
    '''XOR flag with key1 and key2
    '''
    new_data = bytearray()
    for i in range(0, len(data), 2):
        tid = struct.unpack('>H', data[i:i+2])[0]
        new_data += struct.pack('>H', tid^key1^key2)

    return new_data

def do_work():
    '''Parse args and generate a flag blob
    '''
    args = parse_args()
    lut = list('0123456789$-=→→YZABCDEFGHIJKLMNOPQRSTUVWX_{}')
    flag = 'flag{' + args.text + '}'
    data = bytearray('ZZNP', 'utf8')
    for c in list(flag):
        c = c.upper()
        if c not in lut:
            print('! character is not supported: {}'.format(c))
            return False

        index = lut.index(c) + BASE_TILE_ID
        data += struct.pack('>H', index)

    data = xor_flag(args.fkey1, args.fkey2, data)

    f = open(args.out, 'w+b')
    f.write(data)

if __name__ == '__main__':
    do_work()
