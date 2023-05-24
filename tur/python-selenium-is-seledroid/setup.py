from setuptools import setup
import os

def assert_getenv(varname):
  var = os.getenv(varname)
  assert var is not None, "can't find %r environment variable" % varname
  return var

SELENIUM_PKG_VERSION = assert_getenv("SELENIUM_PKG_VERSION")
SELENIUM_PKG_DESCRIPTION = assert_getenv("SELENIUM_PKG_DESCRIPTION")

setup(
    name="selenium",
    version=SELENIUM_PKG_VERSION,
    description=SELENIUM_PKG_DESCRIPTION,
    author="termux-user-repository",
    url="https://github.com/termux-user-repository/tur",
    py_modules=["selenium"],
    python_requires="~=3.7",
)
