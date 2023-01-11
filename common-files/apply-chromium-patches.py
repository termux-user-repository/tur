#!/usr/bin/env python3
# apply-chromium-patches.py - Apply patches for chromium based on versions.

import argparse
from collections import defaultdict
import heapq
import json
import logging
import os
import subprocess

PATCHES_DIR = os.path.join(os.path.dirname(__file__), "chromium-patches")
METADATA_FILE = os.path.join(PATCHES_DIR, "metadata.json")

logger = logging.getLogger(__name__)

class MetadataRangeConflictError(Exception):
  def __init__(self, a, b):
    msg = (f"Conflict is detected between {a.path} and {b.path}. " +
                       f"{a.desc()}, but {b.desc()}.")
    super().__init__(msg)

class MetadataRangeGapError(Exception):
  def __init__(self, k, a, b):
    super().__init__(f"Gap is detected in {k}. {a.desc()}, but {b.desc()}.")

class MetadataRange:
  def __init__(self, path, start, end):
    self.path = path
    self.start = start
    self.end = end
    if start > end:
      raise IndexError(f"Invalid range in {path}, {start} > {end}.")

  def __eq__(self, other):
    return self.start == other.start and self.end == other.end

  def __lt__(self, other):
    if self.end < other.start:
      return True
    elif other.end < self.start:
      return False
    raise MetadataRangeConflictError(self, other)

  def desc(self):
    return f"`{self.path}` has range [{self.start}, {self.end}]"

  def __repr__(self):
    return f"MetadataRange(path={repr(self.path)}, start={self.start}, end={self.end})"

class UniqueMetadataRangeHeapQueue:
  def __init__(self):
    self._queue = []

  def push(self, value):
    for _v in self._queue:
      if _v == value:
        raise MetadataRangeConflictError(_v, value)
    heapq.heappush(self._queue, value)

  def pop(self):
    return heapq.heappop(self._queue)

  def __len__(self):
    return len(self._queue)

class MetadataChecker:
  def __init__(self):
    self._ranges = defaultdict(UniqueMetadataRangeHeapQueue)
  
  def set_range(self, path, start, end):
    name, _ = path.split("/")
    r = MetadataRange(path, start, end)
    self._ranges[name].push(r)

  def ranges_check(self):
    for k, v in self._ranges.items():
      if len(v) < 2: continue
      a = v.pop()
      while len(v) > 0:
        b = v.pop()
        if a.end + 1 != b.start:
          raise MetadataRangeGapError(k, a, b)
        a = b

def check_metadata(metadata_dict):
  checker = MetadataChecker()
  for k, v in metadata_dict.items():
    start = v.get("start", 0)
    end = v.get("end", float("+inf"))
    checker.set_range(k, start, end)
  checker.ranges_check()
  return metadata_dict

def apply_patch(patch_file, dry_run):
  try:
    subprocess.check_call(
      ["patch", "-s", "--dry-run", "-t", "-p1", "-i", patch_file],
      stdin=subprocess.DEVNULL
    )
  except:
    return False
  if dry_run: return True
  subprocess.check_call(["patch", "-s", "-p1", "-t", "-i", patch_file])
  return True

def revert_patch(patch_file, dry_run):
  try:
    subprocess.check_call(
      ["patch", "-s", "-R", "-f", "--dry-run", "-p1", "-i", patch_file],
      stdin=subprocess.DEVNULL
    )
  except:
    return False
  if dry_run: return True
  subprocess.check_call(["patch", "-s", "-R", "-f", "-p1", "-i", patch_file])
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
      return check_metadata(res)
  except Exception as e:
    logger.error("Invalid json format on metadata.json")
    raise e

def execute(args, p):
  is_revert_mode = args.revert
  is_dry_run_mode = args.dry_run
  is_electron_skipped_mode = args.electron
  _, _, build_v, patch_v = parse_chromium_version(args.CHROMIUM_VERSION, p)
  logger.debug("Got chromium version %s", args.CHROMIUM_VERSION)
  metadata = parse_metadata(METADATA_FILE)
  for patch_path, patch_info in metadata.items():
    excluded = patch_info.get("excluded", [])
    start_v = patch_info.get("start", 0)
    end_v = patch_info.get("end", float("+inf"))
    is_electron_broken = patch_info.get("electron_broken", False)
    if f"{build_v}.{patch_v}" in excluded:
      logger.info(f"Skip patch {patch_path} for {build_v}.{patch_v}.")
      continue
    if start_v <= build_v <= end_v:
      if is_electron_skipped_mode and is_electron_broken:
        logger.info(f"Skip patch {patch_path} for electron.")
        continue
      ope_func = revert_patch if is_revert_mode else apply_patch
      ope_str = "revert" if is_revert_mode else "apply"
      logger.info("%sing %s...", ope_str.capitalize(), patch_path)
      if not ope_func(os.path.join(PATCHES_DIR, patch_path), is_dry_run_mode):
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
    "--dry-run",
    action="store_true",
    dest="dry_run",
    default=False,
    help="Set to dry-run mode.",
  )
  p.add_argument(
    "--electron",
    action="store_true",
    dest="electron",
    default=False,
    help="Whether to skip electron-broken patches.",
  )
  p.add_argument(
    "-C",
    "--chdir",
    action="store",
    dest="workdir",
    default=None,
    help="Change workdir.",
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
