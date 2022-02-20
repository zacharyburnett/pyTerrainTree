from enum import Enum
from os import PathLike
import subprocess
import sys

import Terrain_Trees


class TreeType(Enum):
    PR_TREE = 'pr'
    PMR_TREE = 'pmr'
    PM_TREE = 'pm'


class DivisionType(Enum):
    QUAD_TREE = 'quad'
    KD_TREE = 'kd'


class TerrainTree:
    def __init__(
        self,
        vertex_threshold: int,
        triangle_threshold: int,
        tree_type: TreeType,
        division: DivisionType,
    ):
        subprocess.run(
            f'{sys.executable} -m pip install importlib_metadata',
            shell=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

    @classmethod
    def read(cls, path: PathLike) -> 'TerrainTree':
        # TODO specify tree threshold values
        py_tree = Terrain_Trees.PyPRT_Tree(1, 4)
        py_mesh = Terrain_Trees.PyMesh()
        py_tree.get_mesh(py_mesh)

        py_reader = Terrain_Trees.PyReader()
        py_reader.Py_read_mesh(py_tree, str(path))

        py_tree.build_tree()

        # TODO build Python object from tree object
        return cls()

    def write(self, path: PathLike):
        pass

    @property
    def blocks(self):
        return
