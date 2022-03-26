#cython: language_level=3
from os import PathLike
from typing import List

from cpython.object cimport Py_EQ, Py_GE, Py_GT, Py_LE, Py_LT, Py_NE
from cython.operator cimport dereference
from libcpp cimport bool as c_bool
from libcpp.vector cimport vector

cimport c_Terrain_Trees


cdef class Point:
    cdef c_Terrain_Trees.Point* _c_point

    def __cinit__(self, c_Terrain_Trees.coord_type x, c_Terrain_Trees.coord_type y):
        self._c_point = new c_Terrain_Trees.Point()
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
    cdef c_Terrain_Trees.Vertex* _c_vertex

    def __cinit__(self, x: c_Terrain_Trees.coord_type, y: c_Terrain_Trees.coord_type,
                  fields: c_Terrain_Trees.dvect = ()):
        if x is None or y is None:
            self._c_vertex = new c_Terrain_Trees.Vertex()
        elif len(fields) == 0:
            self._c_vertex = new c_Terrain_Trees.Vertex(x, y)
        elif len(fields) == 1:
            self._c_vertex = new c_Terrain_Trees.Vertex(x, y, fields[0])
        else:
            self._c_vertex = new c_Terrain_Trees.Vertex(x, y, fields)

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

cdef class TriangleVertices:
    cdef c_Terrain_Trees.Triangle* _c_triangle

    def __cinit__(self, Triangle triangle):
        self._c_triangle = triangle._c_triangle

    def __getitem__(self, int position) -> vector[int]:
        return self._c_triangle.TV(position)

    def __len__(self) -> int:
        return self._c_triangle.vertices_num()

cdef class TriangleEdges:
    cdef c_Terrain_Trees.Triangle* _c_triangle

    def __cinit__(self, Triangle triangle):
        self._c_triangle = triangle._c_triangle

    def __getitem__(self, int position) -> vector[int]:
        cdef vector[int] edge
        self._c_triangle.TE(position, edge)
        return edge

    def __len__(self) -> int:
        # TODO make this more flexible
        return 3

cdef class Triangle:
    cdef c_Terrain_Trees.Triangle* _c_triangle
    cdef TriangleVertices __vertices
    cdef TriangleEdges __edges

    def __cinit__(self, vertex_1: c_Terrain_Trees.itype, vertex_2: c_Terrain_Trees.itype,
                  vertex_3: c_Terrain_Trees.itype):
        if vertex_1 is None or vertex_2 is None or vertex_3 is None:
            self._c_triangle = new c_Terrain_Trees.Triangle()
        else:
            self._c_triangle = new c_Terrain_Trees.Triangle(vertex_1, vertex_2, vertex_3)

        self.__vertices = TriangleVertices(self)
        self.__edges = TriangleEdges(self)

    @property
    def vertices(self) -> TriangleVertices:
        return self.__vertices

    @property
    def edges(self) -> TriangleEdges:
        return self.__edges

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

    def __len__(self) -> int:
        return self._c_triangle.vertices_num()

    def __contains__(self, item) -> bool:
        if isinstance(item, int):
            return self._c_triangle.has_vertex(item)
        else:
            return self._c_triangle.has_simplex(item)

cdef class Node_V:
    cdef c_Terrain_Trees.Node_V* _c_node_v

    def __cinit__(self):
        self._c_node_v = new c_Terrain_Trees.Node_V()

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
            node_v._c_node_v = self._c_node_v.get_son(index)
            return node_v

    @property
    def is_indexing_vertices(self) -> bool:
        return self._c_node_v.indexes_vertices()

cdef c_Terrain_Trees.Reader * _c_reader

cdef class MeshVertices:
    cdef c_Terrain_Trees.Mesh * _c_mesh

    def __cinit__(self, Mesh mesh):
        self._c_mesh = mesh._c_mesh

    def __getitem__(self, c_Terrain_Trees.itype position) -> Vertex:
        cdef Vertex vertex = Vertex(0, 0)
        vertex._c_vertex = &self._c_mesh.get_vertex(position)
        return vertex

    def append(self, Vertex vertex):
        self._c_mesh.add_vertex(dereference(vertex._c_vertex))

    def __delitem__(self, c_Terrain_Trees.itype position):
        if not self._c_mesh.is_vertex_removed(position):
            self._c_mesh.remove_vertex(position)
        else:
            raise KeyError(f'no vertex exists at position {position}')

    def __len__(self) -> int:
        return self._c_mesh.get_vertices_num()

cdef class MeshTriangles:
    cdef c_Terrain_Trees.Mesh * _c_mesh

    def __cinit__(self, Mesh mesh):
        self._c_mesh = mesh._c_mesh

    def __getitem__(self, c_Terrain_Trees.itype position) -> Triangle:
        cdef Triangle triangle = Triangle(0, 0, 0)
        triangle._c_triangle = &self._c_mesh.get_triangle(position)
        return triangle

    def append(self, Triangle triangle):
        self._c_mesh.add_triangle(dereference(triangle._c_triangle))

    def __delitem__(self, c_Terrain_Trees.itype position):
        if not self._c_mesh.is_triangle_removed(position):
            self._c_mesh.remove_triangle(position)
        else:
            raise KeyError(f'no triangle exists at position {position}')

    def __len__(self) -> int:
        return self._c_mesh.get_triangles_num()

cdef class Mesh:
    cdef c_Terrain_Trees.Mesh * _c_mesh
    cdef MeshVertices __vertices
    cdef MeshTriangles __triangles

    def __cinit__(self):
        self._c_mesh = new c_Terrain_Trees.Mesh()
        self.__vertices = MeshVertices(self)
        self.__triangles = MeshTriangles(self)

    @classmethod
    def from_file(cls, str path: PathLike):
        cdef Mesh instance = cls()
        _c_reader.read_mesh(dereference(instance._c_mesh), bytes(path, encoding='utf8'))
        return instance

    @property
    def vertices(self) -> MeshVertices:
        return self.__vertices

    @property
    def triangles(self) -> MeshTriangles:
        return self.__triangles

cdef class PRT_Tree:
    cdef c_Terrain_Trees.PRT_Tree* _c_tree
    cdef Mesh mesh

    def __cinit__(self, int vertices_per_leaf, int division_type, build: bool = True):
        self._c_tree = new c_Terrain_Trees.PRT_Tree(vertices_per_leaf, division_type)
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
        node._c_node_v = &self._c_tree.get_root()
        return node

    @property
    def leaf_blocks(self) -> int:
        return self._c_tree.get_leaves_number()

    def reindex(self, c_bool save_vertex_indices, c_bool save_triangle_indices):
        cdef c_Terrain_Trees.Reindexer _c_reindexer = c_Terrain_Trees.Reindexer()
        cdef vector[int] original_vertex_indices
        cdef vector[int] original_triangle_indices

        _c_reindexer.reindex_tree_and_mesh(
            dereference(self._c_tree),
            save_vertex_indices,
            original_vertex_indices,
            save_vertex_indices,
            original_triangle_indices
        )
