#/usr/bin/env python3
import sys
import json
from pyarn import lockfile

if __name__ == '__main__':
  package_name = sys.argv[1]
  lockfile_path = sys.argv[2]
  my_lockfile = lockfile.Lockfile.from_file(lockfile_path)
  for k, v in my_lockfile.data.items():
    if k.startswith(package_name + '@'):
      print(json.dumps({'version': v['version'], 'url': v['resolved'].split('#')[0]}))
      break
