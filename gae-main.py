import os
import sys

sys.path.insert(1, os.path.join(os.path.abspath('.'), 'env/lib/python2.7/site-packages/'))

import wsgiref.handlers

from main import app

def main():
    wsgiref.handlers.CGIHandler().run(app)

if __name__ == '__main__':
    main()