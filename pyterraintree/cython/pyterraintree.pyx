#cython: language_level=3
from os import PathLike
from typing import List

# @formatter:off
cimport c_Terrain_Trees
from cpython.object cimport Py_EQ, Py_GE, Py_GT, Py_LE, Py_LT, Py_NE
from cython.operator cimport dereference
from libcpp.vector cimport vector
# @formatter:on

cdef class Point:
    cdef c_Terrain_Trees.Point* _c_point

    def __cinit__(self, x: c_Terrain_Trees.coord_type, y: c_Terrain_Trees.coord_type):
        self._c_point = new c_Terrain_Trees.Point()
        self._c_point.set(x, y)

    def __copy__(self) -> Point:
        return self.__class__(*self.coords)

    @property
    def coords(self) -> List[float]:
        return [self._c_point.get_c(index) for index in range(self._c_point.get_dimension())]

    cpdef float distance(self, other: Point):
        return self._c_point.distance(dereference(other._c_point))

    def __richcmp__(self, other: Point, operation: int) -> bool:
        cdef c_Terrain_Trees.Point this_point = dereference(self._c_point)
        cdef c_Terrain_Trees.Point other_point = dereference(other._c_point)
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

    def __add__(self, other: Point) -> Point:
        # TODO fix compiler error - Cannot convert 'Point' to Python object
        # cdef c_Terrain_Trees.Point point = self._c_point.add(dereference(other._c_point))
        # cdef Point output_point = Point(*(point.get_c(index) for index in range(point.get_dimension())))
        # return output_point
        raise NotImplementedError()

    def __sub__(self, other: Point) -> Point:
        # TODO fix compiler error - Cannot convert 'Point' to Python object
        # cdef c_Terrain_Trees.Point point = self._c_point.sub(dereference(other._c_point))
        # cdef Point output_point = Point(*(point.get_c(index) for index in range(point.get_dimension())))
        # return output_point
        raise NotImplementedError()

    def __mul__(self, factor: c_Terrain_Trees.coord_type) -> Point:
        # TODO fix compiler error - Cannot convert 'Point' to Python object
        # cdef c_Terrain_Trees.Point point = self._c_point.mul(factor)
        # cdef Point output_point = Point(*(point.get_c(index) for index in range(point.get_dimension())))
        # return output_point
        raise NotImplementedError()

cdef class VertexFields:
    cdef c_Terrain_Trees.Vertex* _c_vertex

    def __cinit__(self, vertex: Vertex):
        self._c_vertex = vertex._c_vertex

    def __getitem__(self, position: int) -> float:
        return self._c_vertex.get_field(position)

    cpdef append(self, value: c_Terrain_Trees.coord_type):
        self._c_vertex.add_field(value)

    def __len__(self) -> int:
        return self._c_vertex.get_fields_num()

    def __iter__(self):
        yield from (self[index] for index in range(len(self)))

    def __eq__(self, other: VertexFields)-> bool:
        return len(self) == len(other) and list(self) == list(other)

    def __str__(self) -> str:
        return f'{self.__class__.__name__} - {self.coords} - {", ".join(str(value) for value in self)}'

cdef class Vertex:
    cdef c_Terrain_Trees.Vertex* _c_vertex
    cdef VertexFields __fields

    def __cinit__(self, x: c_Terrain_Trees.coord_type, y: c_Terrain_Trees.coord_type,
                  fields: c_Terrain_Trees.dvect):
        if len(fields) == 0:
            self._c_vertex = new c_Terrain_Trees.Vertex(x, y)
        elif len(fields) == 1:
            self._c_vertex = new c_Terrain_Trees.Vertex(x, y, fields[0])
        else:
            self._c_vertex = new c_Terrain_Trees.Vertex(x, y, fields)

        self.__fields = VertexFields(self)

    @property
    def coords(self) -> List[float]:
        return [self._c_vertex.get_c(index) for index in range(2)]

    @property
    def fields(self) -> VertexFields:
        return self.__fields

    def __eq__(self, other: Vertex) -> bool:
        return self.coords == other.coords and self.fields == other.fields

cdef class TriangleVertexIndices:
    cdef c_Terrain_Trees.Triangle* _c_index_triangle

    def __cinit__(self, triangle: IndexTriangle):
        self._c_index_triangle = triangle._c_index_triangle

    def __getitem__(self, position: int) -> int:
        return self._c_index_triangle.TV(position)

    def __len__(self) -> int:
        return self._c_index_triangle.vertices_num()

    def __iter__(self) -> int:
        for position in range(len(self)):
            yield self[position]

    def __str__(self) -> str:
        return f'{self.__class__.__name__} - {", ".join(str(value) for value in self)}'

cdef class TriangleEdgeIndices:
    cdef c_Terrain_Trees.Triangle* _c_index_triangle

    def __cinit__(self, triangle: IndexTriangle):
        self._c_index_triangle = triangle._c_index_triangle

    def __getitem__(self, position: int) -> vector[int]:
        cdef vector[int] edge
        self._c_index_triangle.TE(position, edge)
        return edge

    def __len__(self) -> int:
        # TODO make this more flexible
        return 3

    def __iter__(self) -> int:
        for position in range(len(self)):
            yield self[position]

    def __str__(self) -> str:
        return f'{self.__class__.__name__} - {", ".join(str(value) for value in self)}'

cdef class TriangleVertices:
    cdef c_Terrain_Trees.Explicit_Triangle* _c_triangle

    def __cinit__(self, triangle: Triangle):
        self._c_triangle = triangle._c_triangle

    def __getitem__(self, position: int) -> Vertex:
        cdef c_Terrain_Trees.Vertex vertex = self._c_triangle.get_vertex(position)
        return Vertex(vertex.get_c(0), vertex.get_c(1),
                      tuple(vertex.get_field(index) for index in range(vertex.get_fields_num())))

    cpdef append(self, vertex: Vertex):
        self._c_triangle.add_vertex(dereference(vertex._c_vertex))

    def __len__(self) -> int:
        return self._c_triangle.vertices_num()

    def __iter__(self) -> Vertex:
        for position in range(len(self)):
            yield self[position]

    def __str__(self) -> str:
        return f'{self.__class__.__name__} - {", ".join(str(value) for value in self)}'

cdef class Triangle:
    cdef c_Terrain_Trees.Explicit_Triangle* _c_triangle
    cdef TriangleVertices __vertices

    def __cinit__(self, vertex_1: Vertex, vertex_2: Vertex,
                  vertex_3: Vertex):
        self._c_triangle = new c_Terrain_Trees.Explicit_Triangle()

        self.__vertices = TriangleVertices(self)

        self.vertices.append(vertex_1)
        self.vertices.append(vertex_2)
        self.vertices.append(vertex_3)

    @property
    def vertices(self) -> TriangleVertices:
        return self.__vertices

    def __contains__(self, vertex: Vertex) -> bool:
        return any(vertex == triangle_vertex for triangle_vertex in self.vertices)

cdef class IndexTriangle:
    cdef c_Terrain_Trees.Triangle* _c_index_triangle
    cdef TriangleVertexIndices __vertices
    cdef TriangleEdgeIndices __edges

    def __cinit__(self, vertex_1: c_Terrain_Trees.itype, vertex_2: c_Terrain_Trees.itype,
                  vertex_3: c_Terrain_Trees.itype):
        if vertex_1 is None or vertex_2 is None or vertex_3 is None:
            self._c_index_triangle = new c_Terrain_Trees.Triangle()
        else:
            self._c_index_triangle = new c_Terrain_Trees.Triangle(vertex_1, vertex_2, vertex_3)

        self.__vertices = TriangleVertexIndices(self)
        self.__edges = TriangleEdgeIndices(self)

    @property
    def vertices(self) -> TriangleVertexIndices:
        return self.__vertices

    @property
    def edges(self) -> TriangleEdgeIndices:
        return self.__edges

    def __richcmp__(self, other: IndexTriangle, operation: int) -> bool:
        cdef c_Terrain_Trees.Triangle this_triangle = dereference(self._c_index_triangle)
        cdef c_Terrain_Trees.Triangle other_triangle = dereference(other._c_index_triangle)
        if operation == Py_EQ:
            return this_triangle == other_triangle
        elif operation == Py_NE:
            return this_triangle != other_triangle
        else:
            raise NotImplementedError(
                f'comparison operation {operation} not implemented for class {self.__class__.__name__}')

    def __contains__(self, item: int) -> bool:
        if isinstance(item, int):
            return self._c_index_triangle.has_vertex(item)
        else:
            return self._c_index_triangle.has_simplex(item)

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

    cpdef vector[vector[int]] vertex_triangle_relations(self, Mesh mesh):
        cdef vector[vector[int]] vertex_triangle_relations
        self._c_node_v.get_VT(vertex_triangle_relations, dereference(mesh._c_mesh))
        return vertex_triangle_relations

    @property
    def is_leaf(self) -> bool:
        return self._c_node_v.is_leaf()

    cpdef Node_V child(self, index: int):
        cdef Node_V node_v = Node_V()
        if self._c_node_v.get_son(index) is NULL:
            return None
        else:
            node_v._c_node_v = self._c_node_v.get_son(index)
            return node_v

    @property
    def is_indexing_vertices(self) -> bool:
        return self._c_node_v.indexes_vertices()

cdef c_Terrain_Trees.Reader* _c_reader
cdef c_Terrain_Trees.Writer* _c_writer

cdef class MeshVertices:
    cdef c_Terrain_Trees.Mesh* _c_mesh

    def __cinit__(self, mesh: Mesh):
        self._c_mesh = mesh._c_mesh

    def __getitem__(self, position: c_Terrain_Trees.itype) -> Vertex:
        cdef c_Terrain_Trees.Vertex vertex = self._c_mesh.get_vertex(position)
        return Vertex(*(vertex.get_c(index) for index in range(2)),
                      tuple(vertex.get_field(index) for index in range(vertex.get_fields_num())))

    cpdef append(self, vertex: Vertex):
        self._c_mesh.add_vertex(dereference(vertex._c_vertex))

    def __delitem__(self, position: c_Terrain_Trees.itype):
        if not self._c_mesh.is_vertex_removed(position):
            self._c_mesh.remove_vertex(position)
        else:
            raise KeyError(f'no vertex exists at position {position}')

    def __len__(self) -> int:
        return self._c_mesh.get_vertices_num()

    def __iter__(self) -> int:
        for position in range(len(self)):
            yield self[position]

    def __str__(self) -> str:
        return f'{self.__class__.__name__} - {", ".join(str(value) for value in self)}'

cdef class MeshTriangles:
    cdef c_Terrain_Trees.Mesh* _c_mesh

    def __cinit__(self, mesh: Mesh):
        self._c_mesh = mesh._c_mesh

    def __getitem__(self, position: c_Terrain_Trees.itype) -> IndexTriangle:
        cdef c_Terrain_Trees.Triangle triangle = self._c_mesh.get_triangle(position)
        return IndexTriangle(*(triangle.TV(position) for position in range(triangle.vertices_num())))

    cpdef append(self, triangle: IndexTriangle):
        self._c_mesh.add_triangle(dereference(triangle._c_index_triangle))

    def __delitem__(self, position: c_Terrain_Trees.itype):
        if not self._c_mesh.is_triangle_removed(position):
            self._c_mesh.remove_triangle(position)
        else:
            raise KeyError(f'no triangle exists at position {position}')

    def __len__(self) -> int:
        return self._c_mesh.get_triangles_num()

    def __iter__(self) -> int:
        for position in range(len(self)):
            yield self[position]

    def __str__(self) -> str:
        return f'{self.__class__.__name__} - {", ".join(str(value) for value in self)}'

cdef class Mesh:
    cdef c_Terrain_Trees.Mesh* _c_mesh
    cdef MeshVertices __vertices
    cdef MeshTriangles __triangles

    def __cinit__(self):
        self._c_mesh = new c_Terrain_Trees.Mesh()
        self.__vertices = MeshVertices(self)
        self.__triangles = MeshTriangles(self)

    @classmethod
    def from_file(cls, path: PathLike):
        cdef Mesh instance = cls()
        _c_reader.read_mesh(dereference(instance._c_mesh), bytes(str(path), encoding='utf8'))
        return instance

    def to_file(self, path: PathLike, extra_fields: bool = False):
        _c_writer.write_mesh(bytes(str(path), encoding='utf8'), bytes('pyterraintree', encoding='utf8'),
                             dereference(self._c_mesh),
                             extra_fields)

    @property
    def vertices(self) -> MeshVertices:
        return self.__vertices

    @property
    def triangles(self) -> MeshTriangles:
        return self.__triangles

cdef class SoupTriangles:
    cdef c_Terrain_Trees.Soup* _c_soup

    def __cinit__(self, soup: Soup):
        self._c_soup = soup._c_soup

    def __getitem__(self, position: c_Terrain_Trees.itype) -> Triangle:
        # TODO fix this, it currently causes a segfault
        cdef c_Terrain_Trees.Explicit_Triangle c_triangle = self._c_soup.get_triangle(position)

        cdef c_Terrain_Trees.Vertex c_vertex_1 = c_triangle.get_vertex(0)
        cdef c_Terrain_Trees.Vertex c_vertex_2 = c_triangle.get_vertex(1)
        cdef c_Terrain_Trees.Vertex c_vertex_3 = c_triangle.get_vertex(2)

        cdef Vertex vertex_1 = Vertex(c_vertex_1.get_c(0), c_vertex_1.get_c(1), tuple(
            c_vertex_1.get_field(field_index) for field_index in range(c_vertex_1.get_fields_num())))
        cdef Vertex vertex_2 = Vertex(c_vertex_2.get_c(0), c_vertex_2.get_c(1), tuple(
            c_vertex_2.get_field(field_index) for field_index in range(c_vertex_2.get_fields_num())))
        cdef Vertex vertex_3 = Vertex(c_vertex_3.get_c(0), c_vertex_3.get_c(1), tuple(
            c_vertex_3.get_field(field_index) for field_index in range(c_vertex_3.get_fields_num())))

        cdef Triangle triangle = Triangle(vertex_1, vertex_2, vertex_3)

        return triangle

    cpdef append(self, triangle: Triangle):
        self._c_soup.add_triangle(dereference(triangle._c_triangle))

    def __len__(self) -> int:
        return self._c_soup.get_triangles_num()

    def __iter__(self) -> int:
        for position in range(len(self)):
            yield self[position]

    def __str__(self) -> str:
        return f'{self.__class__.__name__} - {", ".join(str(value) for value in self)}'

cdef class Soup:
    cdef c_Terrain_Trees.Soup* _c_soup
    cdef SoupTriangles __triangles

    def __cinit__(self):
        self._c_soup = new c_Terrain_Trees.Soup()
        self.__triangles = SoupTriangles(self)

    @classmethod
    def from_file(cls, path: PathLike):
        cdef Soup instance = cls()
        _c_reader.read_soup(dereference(instance._c_soup), bytes(str(path), encoding='utf8'))
        return instance

    @property
    def triangles(self) -> SoupTriangles:
        return self.__triangles

cdef class PointRegionTree:
    cdef c_Terrain_Trees.PRT_Tree* _c_tree
    cdef Mesh __mesh

    def __cinit__(self, vertices_per_leaf: int, division_type: int, build: bool = True):
        self._c_tree = new c_Terrain_Trees.PRT_Tree(vertices_per_leaf, division_type)
        if build:
            self._c_tree.build_tree()
        self.__mesh = Mesh()
        self.__mesh._c_mesh = &self._c_tree.get_mesh()

    @classmethod
    def from_file(cls, path: PathLike, vertices_per_leaf: int, division_type: int) -> PointRegionTree:
        cdef PointRegionTree tree = PointRegionTree(vertices_per_leaf, division_type, build=False)
        cdef Mesh mesh = tree.mesh
        _c_reader.read_mesh(dereference(mesh._c_mesh), bytes(str(path), encoding='utf8'))
        tree._c_tree.build_tree()
        return tree

    def to_file(self, path: PathLike):
        pass

    @property
    def mesh(self) -> Mesh:
        cdef Mesh mesh = self.__mesh
        return mesh

    @property
    def root(self) -> Node_V:
        cdef Node_V node = Node_V()
        node._c_node_v = &self._c_tree.get_root()
        return node

    @property
    def leaf_blocks(self) -> int:
        return self._c_tree.get_leaves_number()

    cpdef reindex(self, save_vertex_indices: bool, save_triangle_indices: bool):
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
