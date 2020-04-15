import io
import os
import re

from setuptools import find_packages
from setuptools import setup


def read(filename):
    filename = os.path.join(os.path.dirname(__file__), filename)
    text_type = type(u"")
    with io.open(filename, mode="r", encoding="utf-8") as fd:
        return re.sub(text_type(r":[a-z]+:`~?(.*?)`"), text_type(r"``\1``"), fd.read())


setup(
    name="MiTepid",
    version="0.0.3",
    url="https://github.com/vahid-sb/MiTepid_sim",
    license="GNU Version 3",
    author="Vahid Samadi Bokharaie",
    author_email="vahid.bokharaie@tuebingen.mpg.de",
    description="MiTepid_sim: Simulating a stratified model for the spread of COVID19 in any population with known age structure, Made in Tübingen. ",
    long_description=read("README.rst"),
    packages=find_packages(exclude=("tests", "venv")),
    test_suite="nose.collector",
    tests_require=["nose"],
    package_data={"mitepid": ["Optimised_B/*.*", "requirements.txt"]},
    include_package_data=True,
    install_requires=[
    "numpy",
    "scipy",
    "matplotlib",
    "pathlib",
    ],

    classifiers=[
        "Development Status :: 2 - Pre-Alpha",
        "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
        "Programming Language :: Python",
        "Programming Language :: Python :: 3.8",
    ],
)
