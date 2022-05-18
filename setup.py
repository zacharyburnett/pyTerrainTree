import os
from pathlib import Path

from Cython.Build import cythonize
from setuptools import Extension, setup

DIRECTORY = Path(__file__).parent

cpp_sources_directory = DIRECTORY / 'modules' / 'Terrain_Trees' / 'sources'
cpp_core_library_directory = cpp_sources_directory / 'core_library' / 'sources'
cython_sources_directory = DIRECTORY / 'pyterraintree' / 'cython'

source_filenames = [
    *cython_sources_directory.glob('**/*.pyx'),
    *cpp_core_library_directory.glob('**/*.cpp'),
    *cpp_sources_directory.glob('utilities/**/*.cpp'),
]

include_directories = [
    cpp_core_library_directory,
    *(
        directory
        for directory in cpp_core_library_directory.iterdir()
        if directory.name
        in (
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

os.environ['CFLAGS'] = '-O3'

setup(
    ext_modules=cythonize(
        extensions, language_level=3, compiler_directives={'linetrace': True},
    ),
)
