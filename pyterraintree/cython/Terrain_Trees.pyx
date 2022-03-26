#cython: language_level=3
from os import PathLike
from typing import List

from cpython.object cimport Py_EQ, Py_GE, Py_GT, Py_LE, Py_LT, Py_NE
from cython.operator cimport dereference
from libcpp cimport bool as c_bool
from libcpp.vector cimport vector

cimport c_Terrain_Trees


cdef class Point:
    cdef c_Terrain_Trees.Point _c_point

    def __cinit__(self, c_Terrain_Trees.coord_type x, c_Terrain_Trees.coord_type y):
        self._c_point = dereference(new c_Terrain_Trees.Point())
        self._c_point.set(<c_Terrain_Trees.coord_type> x, <c_Terrain_Trees.coord_type> y)

    def __copy__(self) -> 'Point':
        return self.__class__(*self.coords)

    @property
    def coords(self) -> List[float]:
        return [self._c_point.get_c(index) for index in range(self._c_point.get_dimension())]

    def distance(self, Point other) -> float:
        cdef c_Terrain_Trees.Point this_point = <c_Terrain_Trees.Point> self._c_point
        cdef c_Terrain_Trees.Point other_point = <c_Terrain_Trees.Point> other._c_point
        return this_point.distance(other_point)

    def __richcmp__(self, Point other, int operation):
        cdef c_Terrain_Trees.Point this_point = <c_Terrain_Trees.Point> self._c_point
        cdef c_Terrain_Trees.Point other_point = <c_Terrain_Trees.Point> other._c_point
        if operation == Py_LT:
            return this_point < other_point
        elif operation == Py_LE:
            return this_point < other_point or this_point == other_point
        elif operation == Py_EQ:
            return this_point == other_point
        elif operation == Py_NE:
            return this_point != other_point
        elif operation == Py_GT:
            return this_point > other_point
        elif operation == Py_GE:
            return this_point > other_point or this_point == other_point
        else:
            raise NotImplementedError(
                f'comparison operation {operation} not implemented for class {self.__class__.__name__}')

    # def __add__(self, Point other):
    #     cdef c_Terrain_Trees.Point other_point = other._c_point
    #     return self._c_point.add(<c_Terrain_Trees.Point> other_point)
    #
    # def __sub__(self, Point other):
    #     cdef c_Terrain_Trees.Point other_point = other._c_point
    #     return self._c_point.sub(<c_Terrain_Trees.Point> other_point)
    #
    # def __mul__(self, c_Terrain_Trees.coord_type factor):
    #     return self._c_point.mul(<c_Terrain_Trees.coord_type> factor)

cdef class Vertex:
    cdef c_Terrain_Trees.Vertex _c_vertex

    def __cinit__(self, c_Terrain_Trees.coord_type x, c_Terrain_Trees.coord_type y, c_Terrain_Trees.dvect fields):
        if len(fields) == 0:
            self._c_vertex = c_Terrain_Trees.Vertex(x, y)
        else:
            self._c_vertex = c_Terrain_Trees.Vertex(x, y, fields)

    @property
    def coords(self) -> List[float]:
        return [self._c_vertex.get_c(index) for index in range(2)]

    def __getitem__(self, int position) -> c_Terrain_Trees.coord_type:
        return self._c_vertex.get_field(position)

    def append(self, c_Terrain_Trees.coord_type value):
        self._c_vertex.add_field(<c_Terrain_Trees.coord_type> value)

    def __len__(self) -> int:
        return self._c_vertex.get_fields_num()

    @property
    def fields(self) -> List[float]:
        return list(self)

    def __iter__(self):
        yield from (self[index] for index in range(len(self)))

cdef class Vertices:
    cdef Mesh mesh

    def __cinit__(self, Mesh mesh):
        self.mesh = mesh

    def __getitem__(self, c_Terrain_Trees.itype position) -> Vertex:
        cdef Vertex vertex = Vertex()
        vertex._c_vertex = self.mesh._c_mesh.get_vertex(position)
        return vertex

    def append(self, Vertex vertex):
        self.mesh._c_mesh.add_vertex(vertex._c_vertex)

    def __delitem__(self, c_Terrain_Trees.itype position):
        if not self.mesh._c_mesh.is_vertex_removed(position):
            self.mesh._c_mesh.remove_vertex(position)
        else:
            raise KeyError(f'no vertex exists at position {position}')

    def __len__(self) -> int:
        return self.mesh._c_mesh.get_vertices_num()

cdef class Triangle:
    cdef c_Terrain_Trees.Triangle _c_triangle

    def __cinit__(self):
        self._c_triangle = c_Terrain_Trees.Triangle()

    def vertex(self, int position) -> c_Terrain_Trees.itype:
        return self._c_triangle.TV(position)

    def edge(self, int position) -> List[int]:
        cdef vector[int] edge
        self._c_triangle.TE(position, edge)
        return edge

    def __richcmp__(self, Triangle other, int operation):
        cdef c_Terrain_Trees.Triangle this_triangle = <c_Terrain_Trees.Triangle> self._c_triangle
        cdef c_Terrain_Trees.Triangle other_triangle = <c_Terrain_Trees.Triangle> other._c_triangle
        if operation == Py_EQ:
            return this_triangle == other_triangle
        elif operation == Py_NE:
            return this_triangle != other_triangle
        else:
            raise NotImplementedError(
                f'comparison operation {operation} not implemented for class {self.__class__.__name__}')

cdef class Triangles:
    cdef Mesh mesh

    def __cinit__(self, Mesh mesh):
        self.mesh = mesh

    def __getitem__(self, c_Terrain_Trees.itype position) -> Triangle:
        cdef Triangle triangle = Triangle()
        triangle._c_triangle = self.mesh._c_mesh.get_triangle(position)
        return triangle

    def append(self, Triangle triangle):
        self.mesh._c_mesh.add_triangle(triangle._c_triangle)

    def __delitem__(self, c_Terrain_Trees.itype position):
        if not self.mesh._c_mesh.is_triangle_removed(position):
            self.mesh._c_mesh.remove_triangle(position)
        else:
            raise KeyError(f'no triangle exists at position {position}')

    def __len__(self) -> int:
        return self.mesh._c_mesh.get_triangles_num()

cdef class Node_V:
    cdef c_Terrain_Trees.Node_V _c_node_v
    cdef Vertices vertices

    def __cinit__(self):
        self._c_node_v = dereference(new c_Terrain_Trees.Node_V())

    @property
    def v_start(self) -> int:
        return self._c_node_v.get_v_start()

    @property
    def v_end(self) -> int:
        return self._c_node_v.get_v_end()

    def vertex_triangle_relations(self, Mesh mesh) -> List[List[int]]:
        cdef vector[vector[int]] vertex_triangle_relations
        self._c_node_v.get_VT(vertex_triangle_relations, dereference(mesh._c_mesh))
        return vertex_triangle_relations

    @property
    def is_leaf(self) -> bool:
        return self._c_node_v.is_leaf()

    def child(self, int index) -> Node_V:
        cdef Node_V node_v = Node_V()
        if self._c_node_v.get_son(index) is NULL:
            return None
        else:
            node_v._c_node_v = dereference(self._c_node_v.get_son(index))
            return node_v

    @property
    def is_indexing_vertices(self) -> bool:
        return self._c_node_v.indexes_vertices()

cdef c_Terrain_Trees.Reader * _c_reader

cdef class Mesh:
    cdef c_Terrain_Trees.Mesh * _c_mesh
    cdef Vertices vertices
    cdef Triangles triangles

    def __cinit__(self):
        self._c_mesh = new c_Terrain_Trees.Mesh()
        self.vertices = Vertices(self)
        self.triangles = Triangles(self)

    @classmethod
    def from_file(cls, str path: PathLike):
        cdef Mesh instance = cls()
        _c_reader.read_mesh(dereference(instance._c_mesh), bytes(path, encoding='utf8'))
        return instance

cdef class PRT_Tree:
    cdef c_Terrain_Trees.PRT_Tree _c_tree
    cdef Mesh mesh

    def __cinit__(self, int vertices_per_leaf, int division_type, build: bool = True):
        self._c_tree = dereference(new c_Terrain_Trees.PRT_Tree(vertices_per_leaf, division_type))
        if build:
            self._c_tree.build_tree()
        self.mesh = Mesh()
        self.mesh._c_mesh = &self._c_tree.get_mesh()

    @classmethod
    def from_file(cls, str path: PathLike, int vertices_per_leaf, int division_type) -> PRT_Tree:
        cdef PRT_Tree tree = PRT_Tree(vertices_per_leaf, division_type, build=False)
        _c_reader.read_mesh(dereference(tree.mesh._c_mesh), bytes(path, encoding='utf8'))
        tree._c_tree.build_tree()
        return tree

    @property
    def mesh(self) -> Mesh:
        mesh = Mesh()
        mesh._c_mesh = &self._c_tree.get_mesh()
        return mesh

    @property
    def root(self) -> Node_V:
        node = Node_V()
        node._c_node_v = self._c_tree.get_root()
        return node

    @property
    def leaf_blocks(self) -> int:
        return self._c_tree.get_leaves_number()

    def reindex(self, c_bool save_vertex_indices, c_bool save_triangle_indices):
        cdef c_Terrain_Trees.Reindexer _c_reindexer = c_Terrain_Trees.Reindexer()
        cdef vector[int] original_vertex_indices
        cdef vector[int] original_triangle_indices

        _c_reindexer.reindex_tree_and_mesh(
            self._c_tree,
            save_vertex_indices,
            original_vertex_indices,
            save_vertex_indices,
            original_triangle_indices
        )
