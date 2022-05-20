#cython: language_level=3
from os import PathLike
from pathlib import Path
from typing import List

# @formatter:off

cimport c_Terrain_Trees
from cpython.object cimport Py_EQ, Py_GE, Py_GT, Py_LE, Py_LT, Py_NE
from cython.operator cimport dereference
from libcpp.vector cimport vector

# @formatter:on

cdef class Point:
    cdef c_Terrain_Trees.Point *_c_point

    def __cinit__(self, x: c_Terrain_Trees.coord_type, y: c_Terrain_Trees.coord_type):
        """
        :param x: x coordinate
        :param y: y coordinate
        """

        self._c_point = new c_Terrain_Trees.Point()
        self._c_point.set(x, y)

    cdef set_point(self, c_Terrain_Trees.Point *point):
        self._c_point = point

    def __copy__(self) -> Point:
        return self.__class__(*self.coords)

    @property
    def coords(self) -> List[float]:
        """
        :return: coordinates
        """

        return [self._c_point.get_c(index) for index in range(self._c_point.get_dimension())]

    def distance(self, other: Point) -> float:
        """
        :param other: another point
        :return: distance to another point
        """

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
    cdef c_Terrain_Trees.Vertex *_c_vertex

    def __cinit__(self):
        self._c_vertex = new c_Terrain_Trees.Vertex()

    cdef set_vertex(self, c_Terrain_Trees.Vertex *vertex):
        self._c_vertex = vertex

    def __getitem__(self, position: int) -> float:
        return self._c_vertex.get_field(position)

    def append(self, value: c_Terrain_Trees.coord_type):
        """
        :param value: value to append to fields list
        """

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
    cdef c_Terrain_Trees.Vertex *_c_vertex
    cdef VertexFields __fields

    def __cinit__(
            self,
            x: c_Terrain_Trees.coord_type,
            y: c_Terrain_Trees.coord_type,
            fields: c_Terrain_Trees.dvect,
    ):
        """
        :param x: x coordinate
        :param y: y coordinate
        :param fields: list of values to attach to the vertex
        """

        if len(fields) == 0:
            self._c_vertex = new c_Terrain_Trees.Vertex(x, y)
        elif len(fields) == 1:
            self._c_vertex = new c_Terrain_Trees.Vertex(x, y, fields[0])
        else:
            self._c_vertex = new c_Terrain_Trees.Vertex(x, y, fields)

        self.__fields = VertexFields()
        self.__fields.set_vertex(self._c_vertex)

    cdef set_vertex(self, c_Terrain_Trees.Vertex *vertex):
        self._c_vertex = vertex

    @property
    def coords(self) -> List[float]:
        """
        :return: coordinates
        """

        return [self._c_vertex.get_c(index) for index in range(2)]

    @property
    def fields(self) -> VertexFields:
        """
        :return: fields
        """

        return self.__fields

    def __eq__(self, other: Vertex) -> bool:
        return self.coords == other.coords and self.fields == other.fields

cdef class TriangleVertexIndices:
    cdef c_Terrain_Trees.Triangle *_c_index_triangle

    def __cinit__(self):
        self._c_index_triangle = new c_Terrain_Trees.Triangle()

    cdef set_triangle(self, c_Terrain_Trees.Triangle *triangle):
        self._c_index_triangle = triangle

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
    cdef c_Terrain_Trees.Triangle *_c_index_triangle

    def __cinit__(self):
        self._c_index_triangle = new c_Terrain_Trees.Triangle()

    cdef set_triangle(self, c_Terrain_Trees.Triangle *triangle):
        self._c_index_triangle = triangle

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
    cdef c_Terrain_Trees.Explicit_Triangle *_c_triangle

    def __cinit__(self):
        self._c_triangle = new c_Terrain_Trees.Explicit_Triangle()

    cdef set_triangle(self, c_Terrain_Trees.Explicit_Triangle *triangle):
        self._c_triangle = triangle

    def __getitem__(self, position: int) -> Vertex:
        cdef c_Terrain_Trees.Vertex vertex = self._c_triangle.get_vertex(position)
        return Vertex(vertex.get_c(0), vertex.get_c(1),
                      tuple(vertex.get_field(index) for index in range(vertex.get_fields_num())))

    def append(self, vertex: Vertex):
        """
        :param vertex: vertex to append to the triangle
        """

        self._c_triangle.add_vertex(dereference(vertex._c_vertex))

    def __len__(self) -> int:
        return self._c_triangle.vertices_num()

    def __iter__(self) -> Vertex:
        for position in range(len(self)):
            yield self[position]

    def __str__(self) -> str:
        return f'{self.__class__.__name__} - {", ".join(str(value) for value in self)}'

cdef class Triangle:
    cdef c_Terrain_Trees.Explicit_Triangle *_c_triangle
    cdef TriangleVertices __vertices

    def __cinit__(
            self,
            vertex_1: Vertex,
            vertex_2: Vertex,
            vertex_3: Vertex,
    ):
        """
        :param vertex_1: first vertex of the triangle
        :param vertex_2: second vertex of the triangle
        :param vertex_3: third vertex of the triangle
        """

        self._c_triangle = new c_Terrain_Trees.Explicit_Triangle()

        self.__vertices = TriangleVertices()
        self.__vertices.set_triangle(self._c_triangle)

        self.__vertices.append(vertex_1)
        self.__vertices.append(vertex_2)
        self.__vertices.append(vertex_3)

    cdef set_triangle(self, c_Terrain_Trees.Explicit_Triangle *triangle):
        self._c_triangle = triangle

    @property
    def vertices(self) -> TriangleVertices:
        """
        :return: vertices of this triangle
        """

        return self.__vertices

    def __contains__(self, vertex: Vertex) -> bool:
        return any(vertex == triangle_vertex for triangle_vertex in self.vertices)

cdef class IndexTriangle:
    cdef c_Terrain_Trees.Triangle *_c_index_triangle
    cdef TriangleVertexIndices __vertices
    cdef TriangleEdgeIndices __edges

    def __cinit__(
            self,
            vertex_1: c_Terrain_Trees.itype,
            vertex_2: c_Terrain_Trees.itype,
            vertex_3: c_Terrain_Trees.itype,
    ):
        """
        :param vertex_1: first vertex of the triangle
        :param vertex_2: second vertex of the triangle
        :param vertex_3: third vertex of the triangle
        """

        if vertex_1 is None or vertex_2 is None or vertex_3 is None:
            self._c_index_triangle = new c_Terrain_Trees.Triangle()
        else:
            self._c_index_triangle = new c_Terrain_Trees.Triangle(vertex_1, vertex_2, vertex_3)

        self.__vertices = TriangleVertexIndices()
        self.__vertices.set_triangle(self._c_index_triangle)

        self.__edges = TriangleEdgeIndices()
        self.__edges.set_triangle(self._c_index_triangle)

    cdef set_triangle(self, c_Terrain_Trees.Triangle *triangle):
        self._c_index_triangle = triangle

    @property
    def vertices(self) -> TriangleVertexIndices:
        """
        :return: indices of vertices of this triangle
        """

        return self.__vertices

    @property
    def edges(self) -> TriangleEdgeIndices:
        """
        :return: indices of edges of this triangle
        """

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

cdef class Box:
    cdef c_Terrain_Trees.Box *_c_box

    def __cinit__(self, min_x: c_Terrain_Trees.coord_type, min_y: c_Terrain_Trees.coord_type, max_x: c_Terrain_Trees.coord_type, max_y: c_Terrain_Trees.coord_type):
        """
        :param min_x: minimum x coordinate
        :param min_y: minimum y coordinate
        :param max_x: maximum x coordinate
        :param max_y: maximum y coordinate
        """

        cdef Point min_point = Point(min_x, min_y)
        cdef Point max_point = Point(max_x, max_y)
        self._c_box = new c_Terrain_Trees.Box(dereference(min_point._c_point), dereference(max_point._c_point))

    cdef set_box(self, c_Terrain_Trees.Box *box):
        self._c_box = box

cdef class VertexNode:
    cdef c_Terrain_Trees.Node_V *_c_node

    def __cinit__(self):
        """
        a node encoding vertices
        """

        self._c_node = new c_Terrain_Trees.Node_V()

    cdef set_node(self, c_Terrain_Trees.Node_V *node):
        self._c_node = node

    @property
    def first_index(self) -> int:
        """
        :return: first vertex index of this node
        """

        return self._c_node.get_v_start()

    @property
    def last_index(self) -> int:
        """
        :return: final vertex index of this node
        """

        return self._c_node.get_v_end()

    def vertex_triangle_relations(self, Mesh mesh) -> c_Terrain_Trees.leaf_VT:
        """
        :param mesh: mesh to check
        :return: neighboring vertex indices for each vertex in this triangle 
        """

        cdef c_Terrain_Trees.leaf_VT vertex_triangle_relations
        self._c_node.get_VT(vertex_triangle_relations, dereference(mesh._c_mesh))
        return vertex_triangle_relations

    @property
    def is_leaf(self) -> bool:
        """
        :return: whether this node is a leaf node (contains only values)
        """

        return self._c_node.is_leaf()

    def child(self, index: int) -> VertexNode:
        """
        :param index: index
        :return: child node at the given index
        """

        cdef c_Terrain_Trees.Node_V *child_node = self._c_node.get_son(index)
        cdef VertexNode child = VertexNode()
        child.set_node(child_node)
        return child

    @property
    def is_indexing_vertices(self) -> bool:
        return self._c_node.indexes_vertices()

cdef class TriangleNode:
    cdef c_Terrain_Trees.Node_T *_c_node

    def __cinit__(self):
        """
        a node encoding triangles
        """

        self._c_node = new c_Terrain_Trees.Node_T()

    cdef set_node(self, c_Terrain_Trees.Node_T *node):
        self._c_node = node

    def vertex_range(self, Mesh mesh, Box domain) -> (int, int):
        """
        :param mesh: mesh to check within
        :param domain: domain to check within
        :return: the first vertex indexed by this node, and the first vertex outside this node
        """

        cdef c_Terrain_Trees.itype start_index
        cdef c_Terrain_Trees.itype end_index
        self._c_node.get_v_range(start_index, end_index, dereference(domain._c_box), dereference(mesh._c_mesh))
        return int(start_index), int(end_index)

    def vertex_in_range(self, vertex_index: int, start_index: int, end_index: int) -> bool:
        return self._c_node.indexes_vertex(v_start=start_index, v_end=end_index, v_id=vertex_index)

cdef c_Terrain_Trees.Reader *_c_reader
cdef c_Terrain_Trees.Writer *_c_writer

cdef class MeshVertices:
    cdef c_Terrain_Trees.Mesh *_c_mesh

    def __cinit__(self):
        self._c_mesh = new c_Terrain_Trees.Mesh()

    cdef set_mesh(self, c_Terrain_Trees.Mesh *mesh):
        self._c_mesh = mesh

    def __getitem__(self, position: c_Terrain_Trees.itype) -> Vertex:
        cdef c_Terrain_Trees.Vertex vertex = self._c_mesh.get_vertex(position)
        return Vertex(*(vertex.get_c(index) for index in range(2)),
                      tuple(vertex.get_field(index) for index in range(vertex.get_fields_num())))

    def append(self, vertex: Vertex):
        """
        :param vertex: vertex to append to the mesh
        """

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
    cdef c_Terrain_Trees.Mesh *_c_mesh

    def __cinit__(self):
        self._c_mesh = new c_Terrain_Trees.Mesh()

    cdef set_mesh(self, c_Terrain_Trees.Mesh *mesh):
        self._c_mesh = mesh

    def __getitem__(self, position: c_Terrain_Trees.itype) -> IndexTriangle:
        cdef c_Terrain_Trees.Triangle triangle = self._c_mesh.get_triangle(position)
        if triangle.vertices_num() < 3:
            raise ValueError(f'empty triangle at position {position}')
        return IndexTriangle(*(triangle.TV(position) for position in range(triangle.vertices_num())))

    def append(self, triangle: IndexTriangle):
        """
        :param triangle: triangle (of indices) to add to the mesh
        """

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
    """
    a mesh of triangles linked by neighbor adjacencies
    """

    cdef c_Terrain_Trees.Mesh *_c_mesh
    cdef MeshVertices __vertices
    cdef MeshTriangles __triangles

    def __cinit__(self):
        self._c_mesh = new c_Terrain_Trees.Mesh()

        self.__vertices = MeshVertices()
        self.__vertices.set_mesh(self._c_mesh)

        self.__triangles = MeshTriangles()
        self.__triangles.set_mesh(self._c_mesh)

    cdef set_mesh(self, c_Terrain_Trees.Mesh *mesh):
        self._c_mesh = mesh
        self.__vertices.set_mesh(self._c_mesh)
        self.__triangles.set_mesh(self._c_mesh)

    @classmethod
    def from_file(cls, path: PathLike):
        """
        :param path: file path of mesh
        """

        cdef c_Terrain_Trees.Mesh *mesh = new c_Terrain_Trees.Mesh()
        _c_reader.read_mesh(dereference(mesh), bytes(str(path), encoding='utf8'))

        cdef Mesh instance = cls()
        instance.set_mesh(mesh)
        return instance

    def to_file(self, path: PathLike, extra_fields: bool = False):
        """
        :param path: file path to write mesh
        :param extra_fields: whether to also write fields
        """

        _c_writer.write_mesh(
            bytes(str(path), encoding='utf8'),
            bytes('pyterraintree', encoding='utf8'),
            dereference(self._c_mesh),
            extra_fields,
        )

    @property
    def vertices(self) -> MeshVertices:
        """
        :return: vertices of this mesh
        """

        return self.__vertices

    @property
    def triangles(self) -> MeshTriangles:
        """
        :return: triangles of this mesh
        """

        return self.__triangles

cdef class SoupTriangles:
    cdef c_Terrain_Trees.Soup *_c_soup

    def __cinit__(self):
        self._c_soup = new c_Terrain_Trees.Soup()

    cdef set_soup(self, c_Terrain_Trees.Soup *soup):
        self._c_soup = soup

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

    def append(self, triangle: Triangle):
        """
        :param triangle: triangle to add to this soup
        """

        self._c_soup.add_triangle(dereference(triangle._c_triangle))

    def __len__(self) -> int:
        return self._c_soup.get_triangles_num()

    def __iter__(self) -> int:
        for position in range(len(self)):
            yield self[position]

    def __str__(self) -> str:
        return f'{self.__class__.__name__} - {", ".join(str(value) for value in self)}'

cdef class Soup:
    """
    a collection of triangles (with coordinates instead of indices)
    """

    cdef c_Terrain_Trees.Soup *_c_soup
    cdef SoupTriangles __triangles

    def __cinit__(self):
        self._c_soup = new c_Terrain_Trees.Soup()
        self.__triangles = SoupTriangles()
        self.__triangles.set_soup(self._c_soup)

    cdef set_soup(self, c_Terrain_Trees.Soup *soup):
        self._c_soup = soup
        self.__triangles.set_soup(self._c_soup)

    @classmethod
    def from_file(cls, path: PathLike):
        """
        :param path: file path to soup
        """

        cdef c_Terrain_Trees.Soup *soup = new c_Terrain_Trees.Soup()
        _c_reader.read_soup(dereference(soup), bytes(str(path), encoding='utf8'))

        cdef Soup instance = cls()
        instance.set_soup(soup)
        return instance

    @property
    def triangles(self) -> SoupTriangles:
        """
        :return: triangles of this soup
        """

        return self.__triangles

cdef class SpatialSubdivision:
    cdef c_Terrain_Trees.Spatial_Subdivision *_c_subdivision

    def __cinit__(self, children_per_node: int):
        self._c_subdivision = new c_Terrain_Trees.Spatial_Subdivision(children_per_node)

    cdef set_subdivision(self, c_Terrain_Trees.Spatial_Subdivision *subdivision):
        self._c_subdivision = subdivision

    @property
    def children(self) -> int:
        return self._c_subdivision.son_number()

cdef class MeshCriticalPoints:
    cdef c_Terrain_Trees.c_bool __computed
    cdef c_Terrain_Trees.Critical_Points_Extractor *_c_critical_points_extractor
    cdef c_Terrain_Trees.Mesh *_c_mesh

    def __cinit__(self):
        self._c_mesh = new c_Terrain_Trees.Mesh()
        self._c_critical_points_extractor = new c_Terrain_Trees.Critical_Points_Extractor()
        self.__computed = False

    cdef set_mesh(self, c_Terrain_Trees.Mesh *mesh):
        self._c_mesh = mesh

    cdef compute(self, c_Terrain_Trees.Node_V *root_node, c_Terrain_Trees.Spatial_Subdivision *subdivision):
        """
        add critical points information to the given mesh
        """

        self._c_critical_points_extractor.compute_critical_points(
            dereference(root_node),
            dereference(self._c_mesh),
            dereference(subdivision),
        )
        # self._c_critical_points_extractor.compute_critical_points(
        #     dereference(root_node._c_node),
        #     dereference(domain._c_box),
        #     dereference(self._c_mesh),
        #     dereference(subdivision._c_subdivision),
        # )
        self.__computed = True

    @property
    def computed(self) -> bool:
        return self.__computed

    @property
    def indices(self) -> [int]:
        return self._c_critical_points_extractor.get_critical_points()

    def print_stats(self):
        self._c_critical_points_extractor.print_stats()

    def to_file(self, path: PathLike):
        _c_writer.write_critical_points(
            bytes(str(path), encoding='utf8'),
            self.indices,
            dereference(self._c_mesh),
        )

cdef class MeshTriangleSlopes:
    cdef c_Terrain_Trees.c_bool __computed
    cdef c_Terrain_Trees.Slope_Extractor *_c_slope_extractor
    cdef c_Terrain_Trees.Mesh *_c_mesh

    def __cinit__(self):
        self._c_mesh = new c_Terrain_Trees.Mesh()
        self._c_slope_extractor = new c_Terrain_Trees.Slope_Extractor()
        self.__computed = False

    cdef set_mesh(self, c_Terrain_Trees.Mesh *mesh):
        self._c_mesh = mesh

    cdef compute(self, c_Terrain_Trees.Node_V *root_node, c_Terrain_Trees.Spatial_Subdivision *subdivision):
        """
        add triangle slope information to the given mesh
        """

        self._c_slope_extractor.compute_triangles_slopes(
            dereference(root_node),
            dereference(self._c_mesh),
            dereference(subdivision),
        )
        self._c_slope_extractor.compute_edges_slopes(
            dereference(root_node),
            dereference(self._c_mesh),
            dereference(subdivision),
        )
        # self._c_slope_extractor.compute_triangles_slopes(
        #     dereference(root_node._c_node),
        #     dereference(domain._c_box),
        #     level,
        #     dereference(self._c_mesh),
        #     dereference(subdivision._c_subdivision),
        # )
        # self._c_slope_extractor.compute_edges_slopes(
        #     dereference(root_node._c_node),
        #     dereference(domain._c_box),
        #     level,
        #     dereference(self._c_mesh),
        #     dereference(subdivision._c_subdivision),
        # )
        self.__computed = True

    @property
    def computed(self) -> bool:
        return self.__computed

    @property
    def indices(self) -> [int]:
        return self._c_slope_extractor.get_tri_slopes()

    def print_stats(self):
        self._c_slope_extractor.print_slopes_stats()

    def to_file(self, path: PathLike):
        _c_writer.write_tri_slope_VTK(
            bytes(str(path), encoding='utf8'),
            dereference(self._c_mesh),
            self.indices,
        )

cdef class MeshTriangleAspects:
    cdef c_Terrain_Trees.c_bool __computed
    cdef c_Terrain_Trees.Aspect *_c_aspect
    cdef c_Terrain_Trees.Mesh *_c_mesh

    def __cinit__(self):
        self._c_mesh = new c_Terrain_Trees.Mesh()
        self._c_aspect = new c_Terrain_Trees.Aspect()
        self.__computed = False

    cdef set_mesh(self, c_Terrain_Trees.Mesh *mesh):
        self._c_mesh = mesh

    cdef compute(self, c_Terrain_Trees.Node_V *root_node, c_Terrain_Trees.Spatial_Subdivision *subdivision):
        """
        add triangle aspect information to the given mesh
        """

        self._c_aspect.compute_triangles_aspects(
            dereference(root_node),
            dereference(self._c_mesh),
            dereference(subdivision),
        )
        # self._c_aspect.compute_triangles_aspects(
        #     dereference(root_node),
        #     dereference(domain._c_box),
        #     level,
        #     dereference(self._c_mesh),
        #     dereference(subdivision),
        # )
        self.__computed = True

    @property
    def computed(self) -> bool:
        return self.__computed

    def print_stats(self):
        self._c_aspect.print_aspects_stats()

    def to_file(self, path: PathLike):
        raise NotImplementedError()

cdef class MeshFormanGradient:
    cdef c_Terrain_Trees.c_bool __computed
    cdef c_Terrain_Trees.Forman_Gradient *_c_forman_gradient
    cdef c_Terrain_Trees.Forman_Gradient_Computation *_c_forman_gradient_computation
    cdef c_Terrain_Trees.Mesh *_c_mesh

    def __cinit__(self):
        self._c_mesh = new c_Terrain_Trees.Mesh()
        self._c_forman_gradient_computation = new c_Terrain_Trees.Forman_Gradient_Computation()
        self.__computed = False

    cdef set_mesh(self, c_Terrain_Trees.Mesh *mesh):
        self._c_mesh = mesh
        self._c_forman_gradient = new c_Terrain_Trees.Forman_Gradient(self._c_mesh.get_triangles_num())

    cdef compute(self, c_Terrain_Trees.Node_V *root_node, c_Terrain_Trees.Spatial_Subdivision *subdivision):
        """
        add Forman gradient information to the given mesh
        """

        # self._c_forman_gradient_computation.initial_filtering_IA(dereference(self._c_mesh))
        self._c_forman_gradient_computation.compute_gradient_vector(
            dereference(self._c_forman_gradient),
            dereference(root_node),
            dereference(self._c_mesh),
            dereference(subdivision),
        )

        self.__computed = True

    @property
    def computed(self) -> bool:
        return self.__computed

    @property
    def critical_simplices(self) -> {int, [[int]]}:
        return self._c_forman_gradient_computation.get_critical_simplices()

    def to_file(self, path: PathLike):
        _c_writer.write_critical_points_morse(
            bytes(str(path), encoding='utf8'),
            self.critical_simplices,
            dereference(self._c_mesh),
        )

cdef class Tree:
    """
    a hierarchical tree of nodes
    """

    cdef Mesh __mesh
    cdef int __vertices_per_leaf
    cdef SpatialSubdivision __subdivision
    cdef MeshCriticalPoints __critical_points
    cdef MeshFormanGradient __forman_gradient
    cdef MeshTriangleSlopes __triangle_slopes
    cdef MeshTriangleAspects __triangle_aspects

    @classmethod
    def from_file(cls, path: PathLike, vertices_per_leaf: int, division_type: int) -> PointRegionTree:
        """
        :param path: file path to tree
        :param vertices_per_leaf: number of vertices to store in each leaf node
        :param division_type: KDtree (2) or quadtree (4)
        """

        raise NotImplementedError()

    def to_file(self, path: PathLike):
        """
        :param path: file path to write tree
        """

        raise NotImplementedError()

    @property
    def subdivision(self) -> SpatialSubdivision:
        return self.__subdivision

    @property
    def vertices_per_leaf(self) -> int:
        return self.__vertices_per_leaf

    @property
    def mesh(self) -> Mesh:
        """
        :return: underlying triangle mesh of this tree
        """

        raise NotImplementedError()

    @property
    def root(self) -> VertexNode:
        """
        :return: root node of this tree
        """

        raise NotImplementedError()

    @property
    def leaf_blocks(self) -> int:
        """
        :return: number of leaf blocks in this tree
        """

        raise NotImplementedError()

    def reindex(self, save_vertex_indices: bool, save_triangle_indices: bool):
        """
        reindex this tree

        :param save_vertex_indices: whether to save the vertex indices
        :param save_triangle_indices: whether to save the triangle indices
        """

        raise NotImplementedError()

    @property
    def critical_points(self):
        raise NotImplementedError()

    @property
    def forman_gradient(self):
        raise NotImplementedError()

    @property
    def triangle_slopes(self):
        raise NotImplementedError()

    @property
    def triangle_aspects(self):
        raise NotImplementedError()

cdef class PointRegionTree(Tree):
    cdef c_Terrain_Trees.PRT_Tree *_c_tree
    cdef c_Terrain_Trees.Node_V *_c_root

    def __cinit__(self, vertices_per_leaf: int, children_per_node: int, build: bool = True):
        self._c_tree = new c_Terrain_Trees.PRT_Tree(vertices_per_leaf, children_per_node)

        if build:
            self._c_tree.build_tree()

        self.__mesh = Mesh()
        self.__mesh.set_mesh(&self._c_tree.get_mesh())

        self._c_root = &self._c_tree.get_root()

        self.__vertices_per_leaf = vertices_per_leaf
        self.__subdivision = SpatialSubdivision(children_per_node)

        self.__critical_points = MeshCriticalPoints()
        self.__critical_points.set_mesh(self.__mesh._c_mesh)

        self.__forman_gradient = MeshFormanGradient()
        self.__forman_gradient.set_mesh(self.__mesh._c_mesh)

        self.__triangle_slopes = MeshTriangleSlopes()
        self.__triangle_slopes.set_mesh(self.__mesh._c_mesh)

        self.__triangle_aspects = MeshTriangleAspects()
        self.__triangle_aspects.set_mesh(self.__mesh._c_mesh)

    @classmethod
    def from_file(cls, path: PathLike, vertices_per_leaf: int, children_per_node: int) -> PointRegionTree:
        cdef PointRegionTree tree = PointRegionTree(vertices_per_leaf, children_per_node, build=False)
        cdef Mesh mesh = tree.mesh
        if Path(path).suffix in ['.tree', '.vtk']:
            _c_reader.read_tree(dereference(tree._c_tree), tree._c_tree.get_root(), bytes(str(path), encoding='utf8'))
        else:
            _c_reader.read_mesh(dereference(mesh._c_mesh), bytes(str(path), encoding='utf8'))
            tree.__mesh.set_mesh(mesh._c_mesh)
        tree._c_tree.build_tree()
        return tree

    # @classmethod
    # def from_soup(cls, soup: Soup, vertices_per_leaf: int, children_per_node: int):
    #     cdef PointRegionTree tree = PointRegionTree(vertices_per_leaf, children_per_node, build=False)
    #     tree._c_tree.build_tree(dereference(soup._c_soup))
    #     return tree

    @classmethod
    def from_points(self, points: c_Terrain_Trees.vertex_multifield):
        self._c_tree.build_tree(points)

    cdef set_tree(self, c_Terrain_Trees.PRT_Tree *tree):
        self._c_tree = tree

        self.__mesh.set_mesh(&self._c_tree.get_mesh())
        self._c_tree.build_tree()

        self._c_root = &self._c_tree.get_root()

        self.__critical_points.set_mesh(self.__mesh._c_mesh)
        self.__forman_gradient.set_mesh(self.__mesh._c_mesh)
        self.__triangle_slopes.set_mesh(self.__mesh._c_mesh)
        self.__triangle_aspects.set_mesh(self.__mesh._c_mesh)

    def to_file(self, path: PathLike):
        _c_writer.write_tree(
            bytes(str(path), encoding='utf8'),
            self._c_tree.get_root(),
            dereference(new c_Terrain_Trees.Spatial_Subdivision(self.__subdivision.children)),
        )

    @property
    def mesh(self) -> Mesh:
        cdef Mesh mesh = self.__mesh
        return mesh

    @property
    def root(self) -> VertexNode:
        cdef VertexNode root = VertexNode()
        root.set_node(self._c_root)
        return root

    @property
    def leaf_blocks(self) -> int:
        return self._c_tree.get_leaves_number()

    def reindex(self, save_vertex_indices: bool, save_triangle_indices: bool):
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

    @property
    def critical_points(self):
        if not self.__critical_points.computed:
            self.__critical_points.compute(self._c_root, self.__subdivision._c_subdivision)
        return self.__critical_points

    @property
    def forman_gradient(self):
        if not self.__forman_gradient.computed:
            self.__forman_gradient.compute(self._c_root, self.__subdivision._c_subdivision)
        return self.__forman_gradient

    @property
    def triangle_slopes(self):
        if not self.__triangle_slopes.computed:
            self.__triangle_slopes.compute(self._c_root, self.__subdivision._c_subdivision)
        return self.__triangle_slopes

    @property
    def triangle_aspects(self):
        if not self.__triangle_aspects.computed:
            self.__triangle_aspects.compute(self._c_root, self.__subdivision._c_subdivision)
        return self.__triangle_aspects
