from pathlib import Path
import subprocess
import sys
from typing import List

from Cython.Build import cythonize
from setuptools import config, Extension, setup

try:
    from importlib import metadata as importlib_metadata
except ImportError:  # for Python<3.8
    subprocess.run(
        f'{sys.executable} -m pip install importlib_metadata',
        shell=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    import importlib_metadata


def installed_packages() -> List[str]:
    installed_distributions = importlib_metadata.distributions()
    return [
        distribution.metadata['Name'].lower()
        for distribution in installed_distributions
        if distribution.metadata['Name'] is not None
    ]


try:
    if 'dunamai' not in installed_packages():
        subprocess.run(
            f'{sys.executable} -m pip install dunamai',
            shell=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

    from dunamai import Version

    __version__ = Version.from_any_vcs().serialize()
except (ModuleNotFoundError, RuntimeError) as error:
    print(error)
    __version__ = '0.0.0'

print(f'using version {__version__}')

sources_directory = Path(__file__).parent / 'modules' / 'Terrain_Trees' / 'sources'
core_library_directory = sources_directory / 'core_library' / 'sources'
cython_directory = Path(__file__).parent / 'pyterraintree' / 'cython'

source_filenames = [cython_directory / 'py_terrain_trees.pyx']
source_filenames.extend(core_library_directory.glob('**/*.cpp'))
source_filenames.extend(sources_directory.glob('utilities/**/*.cpp'))

include_directories = [
    core_library_directory,
    *(
        core_library_directory / directory
        for directory in (
            'terrain_trees',
            'utilities',
            'basic_types',
            'curvature',
            'geometry',
            'io',
            'queries',
            'roughness',
            'statistics',
            'terrain_features',
        )
    ),
    '/usr/include/eigen3',
]

source_filenames = [str(filename) for filename in source_filenames]
include_directories = [str(filename) for filename in include_directories]

extensions = cythonize(
    [
        Extension(
            'Terrain_Tree',
            sources=source_filenames,
            language='c++',
            include_dirs=include_directories,
        )
    ]
)

metadata = config.read_configuration('setup.cfg')['metadata']

setup(
    name=metadata['name'],
    version=__version__,
    author=metadata['author'],
    author_email=metadata['author_email'],
    description=metadata['description'],
    long_description=metadata['long_description'],
    long_description_content_type='text/markdown',
    url=metadata['url'],
    setup_requires=['cython', 'dunamai', 'setuptools>=41.2'],
    ext_modules=extensions,
    python_requires='>=3.10',
    extras_require={
        'testing': ['pytest', 'pytest-cov', 'pytest-xdist'],
        'development': ['flake8', 'isort', 'oitnb'],
        'documentation': ['m2r2', 'sphinx', 'sphinx-rtd-theme'],
    },
)
