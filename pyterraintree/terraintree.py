from abc import abstractmethod
from enum import Enum
from os import PathLike

import Terrain_Trees


class TreeType(Enum):
    PR_TREE = 'pr'
    PMR_TREE = 'pmr'
    PM_TREE = 'pm'


class DivisionType(Enum):
    QUAD_TREE = 4
    KD_TREE = 2


class TerrainTree:
    def __init__(
        self, vertices_per_leaf: int, division: DivisionType,
    ):
        self.__vertices_per_leaf = vertices_per_leaf
        self.__division = division
        self.__tree = None

    @property
    def vertices_per_leaf(self) -> int:
        return self.__vertices_per_leaf

    @property
    def division(self) -> DivisionType:
        return self.__division

    @classmethod
    def from_file(
        cls, path: PathLike, vertices_per_leaf: int, division: DivisionType
    ) -> 'TerrainTree':
        instance = cls(vertices_per_leaf, division)
        instance.__tree.read_file(path)
        return instance

    @abstractmethod
    def to_file(self, path: PathLike):
        raise NotImplementedError()


class PointRegionTree(TerrainTree):
    def __init__(self, vertices_per_leaf: int, division: DivisionType):
        super().__init__(vertices_per_leaf, division)
        self.__tree = Terrain_Trees.PRT_Tree(self.vertices_per_leaf, self.division)

    def to_file(self, path: PathLike):
        pass


class PointMatrixTree(TerrainTree):
    def __init__(self, vertices_per_leaf: int, division: DivisionType):
        super().__init__(vertices_per_leaf, division)
        raise NotImplementedError()

    def to_file(self, path: PathLike):
        raise NotImplementedError()


class PointMatrixRegionTree(TerrainTree):
    def __init__(self, vertices_per_leaf: int, division: DivisionType):
        super().__init__(vertices_per_leaf, division)
        raise NotImplementedError()

    def to_file(self, path: PathLike):
        raise NotImplementedError()
