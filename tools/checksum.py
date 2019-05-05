# checksum.py
#
# This script is part of jump, a project released under a 
# [MIT](https://github.com/zznop/jump/LICENSE.md) license.

import argparse
import struct
import sys
import shutil

def parse_args():
    '''Parse command line arguments
    '''
    parser = argparse.ArgumentParser()
    parser.add_argument('infile', metavar='<ROM>',
        help='Filepath to ROM binary')
    parser.add_argument('--start', type=int, default=0x200,
        help='Start of ROM (after the header)    DEFAULT=0x200')
    parser.add_argument('--size', type=int, default=0x80000,
        help='Size of ROM    DEFAULT=0x80000')
    parser.add_argument('--checkoff', type=int, default=0x18e,
        help='Checksum offset    DEFAULT=0x18e')
    parser.add_argument('--out', type=str,
        help='File to write fixed ROM')
    return parser.parse_args()

def open_rom(filepath):
    '''Open the ROM file
    '''
    try:
        file = open(filepath, 'r+b')
        return file
    except Exception as ex:
        print('Failed to open the ROM file: {}'.format(filepath))
        sys.exit(1)

def get_current_checksum(file, checkoff):
    '''Seek to current checksum, read it, and return it as an word
    '''
    file.seek(checkoff)
    return struct.unpack('>H', file.read(2))[0]

def overwrite_checksum(file, checkoff, checksum):
    '''Seek to current checksum and overwrite it
    '''
    file.seek(checkoff)
    file.write(struct.pack('>H', checksum))

def do_work():
    '''Run the script
    '''
    args = parse_args()
    if args.out:
        shutil.copyfile(args.infile, args.out)
        file = open_rom(args.out)
    else:
        file = open_rom(args.infile)

    file.seek(args.start)
    calcd_checksum = 0
    i = args.start
    while i < args.size:
        chunk = file.read(2)
        if chunk is None or len(chunk) < 2:
            break
        word = struct.unpack('>H', chunk)[0]
        calcd_checksum = calcd_checksum + word & 0x0000ffff
        i += 2

    existing_checksum = get_current_checksum(file, args.checkoff)
    if existing_checksum != calcd_checksum:
        overwrite_checksum(file, args.checkoff, calcd_checksum)

if __name__ == '__main__':
    do_work()

