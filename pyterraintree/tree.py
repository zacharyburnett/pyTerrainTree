from abc import abstractmethod
from enum import Enum
from os import PathLike

import Terrain_Trees
import typepigeon


class TreeType(Enum):
    PR_TREE = 'pr'
    PMR_TREE = 'pmr'
    PM_TREE = 'pm'


class DivisionType(Enum):
    QUAD_TREE = 4
    KD_TREE = 2


class TerrainTree:
    def __init__(self, vertices_per_leaf: int, division: DivisionType):
        if not isinstance(vertices_per_leaf, int):
            vertices_per_leaf = int(vertices_per_leaf)

        if not isinstance(division, DivisionType):
            division = typepigeon.convert_value(division, DivisionType)

        self.__vertices_per_leaf = vertices_per_leaf
        self.__division = division

        self.__tree = None

    @classmethod
    @abstractmethod
    def from_file(
        cls, path: PathLike, vertices_per_leaf: int, division: DivisionType
    ) -> 'TerrainTree':
        raise NotImplementedError()

    @property
    def vertices_per_leaf(self) -> int:
        return self.__vertices_per_leaf

    @property
    def division(self) -> DivisionType:
        return self.__division

    @abstractmethod
    def to_file(self, path: PathLike):
        raise NotImplementedError()


class PointRegionTree(TerrainTree):
    def __init__(self, vertices_per_leaf: int, division: DivisionType):
        super().__init__(vertices_per_leaf, division)
        self.__tree = Terrain_Trees.PointRegionTree(self.vertices_per_leaf, self.division)

    @classmethod
    def from_file(
        cls, path: PathLike, vertices_per_leaf: int, division: DivisionType
    ) -> 'TerrainTree':
        pass

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
