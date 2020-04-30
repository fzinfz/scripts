import os

def main(**kwargs):
    '''
    kwargs e.g.: {'arg1': 'v1', 'verbose': False}
    '''
    print(os.linesep + "in main() Generating code")
    print(', '.join(list(kwargs.keys())))
    for k in kwargs.keys():
        print(f"{k} = kwargs['{k}']")
        print(f"print('{k} =', {k})")


def fun1(k1):
    print("k1", k1)


def main2(arg1, verbose, addional_kwargs):
    print(os.linesep + "in main2():")
    print(arg1)
    print(verbose)

    import json
    addional_kwargs = json.loads(addional_kwargs.replace("'",'"'))
    fun1(**addional_kwargs)


def parse_args():
    import argparse
    parser = argparse.ArgumentParser(description="argparse demo",
      formatter_class=argparse.ArgumentDefaultsHelpFormatter) # 'help' required in parser.add_argument()
    parser.add_argument('-a1','--arg1', type=str, required=False, default='v1', help="arg1")
    parser.add_argument("-v", "--verbose", action="store_true")
    parser.add_argument("-k", "--addional_kwargs", default="{'k1':1}", help='addional kwargs')
    return parser.parse_args()


if __name__ == '__main__':
    kwargs = vars(parse_args())
    main(**kwargs)
    main2(**kwargs)