from enum import Enum
from os import PathLike
import subprocess
import sys


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
        return cls()

    def write(self, path: PathLike):
        pass

    @property
    def blocks(self):
        return
