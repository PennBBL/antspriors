### This script finds the minimum of a list of command line values
###
### Ellyn Butler
### January 20, 2021

import argparse

parser = argparse.ArgumentParser(description='Process some integers.')

parser.add_argument('integers', metavar='N', type=int, nargs='+',
                    help='an integer for the accumulator')
parser.add_argument('--min', dest='accumulate', action='store_const',
                    const=min, default=max,
                    help='max of numbers (default: find the max)')

args = parser.parse_args()

print(args.accumulate(args.integers))
