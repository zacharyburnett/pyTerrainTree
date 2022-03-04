from pathlib import Path
import warnings

from Cython.Build import cythonize
from dunamai import Version
from setuptools import Extension, find_packages, setup

cpp_sources_directory = Path.cwd() / 'modules' / 'Terrain_Trees' / 'sources'
cpp_core_library_directory = cpp_sources_directory / 'core_library' / 'sources'
cython_sources_directory = Path.cwd() / 'pyterraintree' / 'cython'

source_filenames = []
source_filenames.extend(cython_sources_directory.glob('**/*.pyx'))
source_filenames.extend(cpp_core_library_directory.glob('**/*.cpp'))
source_filenames.extend(cpp_sources_directory.glob('utilities/**/*.cpp'))

include_directories = [
    cpp_core_library_directory,
    *(
        cpp_core_library_directory / directory
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
            'Terrain_Trees',
            sources=source_filenames,
            libraries=source_filenames,
            language='c++',
            include_dirs=include_directories,
        )
    ]
)

try:
    __version__ = Version.from_any_vcs().serialize()
except RuntimeError as error:
    warnings.warn(f'{error.__class__.__name__} - {error}')
    __version__ = '0.0.0'

setup(
    version=__version__,
    packages=find_packages(exclude=('tests',)),
    test_suite='tests',
    ext_modules=extensions,
)
