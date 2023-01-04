#!/usr/bin/env python3
# apply-chromium-patches.py - Apply patches for chromium based on versions.

import argparse
import json
import logging
import os
import subprocess
from subprocess import check_call

PATCHES_DIR = os.path.join(os.path.dirname(__file__), "chromium-patches")
MATADATA_FILE = os.path.join(PATCHES_DIR, "metadata.json")

logger = logging.getLogger(__name__)

def apply_patch(patch_file):
  try:
    subprocess.check_call(["patch", "-s", "--dry-run", "-t", "-p1", "-i", patch_file], stdin=subprocess.DEVNULL)
  except:
    return False
  subprocess.check_call(["patch", "-s", "-p1", "-t", "-i", patch_file])
  return True

def revert_patch(patch_file):
  try:
    check_call(["patch", "-s", "-R", "-f", "--dry-run", "-p1", "-i", patch_file], stdin=subprocess.DEVNULL)
  except:
    return False
  check_call(["patch", "-s", "-R", "-f", "-p1", "-i", patch_file])
  return True

def parse_chromium_version(version_str, p):
  res = version_str.split(".")
  try:
    assert len(res) == 4
    return tuple(map(int, res))
  except:
    p.error(f"Invalid verion format: expected a.b.c.d, got {version_str}")

def parse_metadata(filepath):
  try:
    with open(filepath, "r") as fp:
      res = json.load(fp)
      assert isinstance(res, dict)
      return res
  except:
    logger.error("Invalid json format on metadata.json")
    exit(1)

def execute(args, p):
  is_revert_mode = args.revert
  _, _, build_v, patch_v = parse_chromium_version(args.CHROMIUM_VERSION, p)
  logger.debug("Got chromium version %s", args.CHROMIUM_VERSION)
  metadata = parse_metadata(MATADATA_FILE)
  for patch_path, patch_info in metadata.items():
    excluded = patch_info.get("excluded", [])
    start_v = patch_info.get("start", 0)
    end_v = patch_info.get("end", float("+inf"))
    if f"{build_v}.{patch_v}" not in excluded and start_v <= build_v <= end_v:
      ope_func = revert_patch if is_revert_mode else apply_patch
      ope_str = "revert" if is_revert_mode else "apply"
      logger.info("%sing %s...", ope_str.capitalize(), patch_path)
      if not ope_func(os.path.join(PATCHES_DIR, patch_path)):
        logger.error("Failed to %s %s: ignoring", ope_str, patch_path)

def main():
  p = argparse.ArgumentParser(description="Apply/Revert patches for chromium based on versions.")
  p.add_argument(
    "-v",
    "--verbose",
    action="count",
    dest="verbose",
    default=0,
    help="Give more output. Option is additive",
  )
  p.add_argument(
    "-R",
    "--revert",
    action="store_true",
    dest="revert",
    default=False,
    help="Set to revert mode.",
  )
  p.add_argument(
    "-C",
    "--chdir",
    action="store",
    dest="workdir",
    default=None,
    help="Set to revert mode.",
  )
  p.add_argument(
    "CHROMIUM_VERSION",
    help="The chromium version.",
  )
  args = p.parse_args()
  logging.disable(logging.NOTSET)
  if args.verbose >= 1:
    logging.basicConfig(level=logging.DEBUG)
  else:
    logging.basicConfig(level=logging.INFO)
  if args.workdir:
    os.chdir(args.workdir)
  execute(args, p)

if __name__ == '__main__':
    main()
