#cython: language_level=3
from ctypes import Union
from os import PathLike
from typing import List

# @formatter:off

cimport c_Terrain_Trees
from cpython.object cimport Py_EQ, Py_GE, Py_GT, Py_LE, Py_LT, Py_NE
from cython.operator cimport dereference
from libcpp.vector cimport vector

# @formatter:on

cdef class Point:
    cdef c_Terrain_Trees.Point * _c_point

    def __cinit__(self, x: c_Terrain_Trees.coord_type, y: c_Terrain_Trees.coord_type):
        """
        :param x: x coordinate
        :param y: y coordinate
        """

        self._c_point = new c_Terrain_Trees.Point()
        self._c_point.set(x, y)

    def __copy__(self) -> Point:
        return self.__class__(*self.coords)

    @property
    def coords(self) -> List[float]:
        """
        :return: coordinates
        """

        return [self._c_point.get_c(index) for index in range(self._c_point.get_dimension())]

    cpdef float distance(self, other: Point):
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
    cdef c_Terrain_Trees.Vertex * _c_vertex

    def __cinit__(self, vertex: Vertex):
        """
        :param vertex: vertex to attach fields to
        :return: set of vertex fields attached to the given vertex
        """

        self._c_vertex = vertex._c_vertex

    def __getitem__(self, position: int) -> float:
        return self._c_vertex.get_field(position)

    cpdef append(self, value: c_Terrain_Trees.coord_type):
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
    cdef c_Terrain_Trees.Vertex * _c_vertex
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

        self.__fields = VertexFields(self)

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
    cdef c_Terrain_Trees.Triangle * _c_index_triangle

    def __cinit__(self, triangle: IndexTriangle):
        """
        :param triangle: triangle to attach indices to
        """

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
    cdef c_Terrain_Trees.Triangle * _c_index_triangle

    def __cinit__(self, triangle: IndexTriangle):
        """
        :param triangle: triangle to index
        """

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
    cdef c_Terrain_Trees.Explicit_Triangle * _c_triangle

    def __cinit__(self, triangle: Triangle):
        """
        :param triangle: triangle to attach vertices to
        """

        self._c_triangle = triangle._c_triangle

    def __getitem__(self, position: int) -> Vertex:
        cdef c_Terrain_Trees.Vertex vertex = self._c_triangle.get_vertex(position)
        return Vertex(vertex.get_c(0), vertex.get_c(1),
                      tuple(vertex.get_field(index) for index in range(vertex.get_fields_num())))

    cpdef append(self, vertex: Vertex):
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
    cdef c_Terrain_Trees.Explicit_Triangle * _c_triangle
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

        self.__vertices = TriangleVertices(self)

        self.vertices.append(vertex_1)
        self.vertices.append(vertex_2)
        self.vertices.append(vertex_3)

    @property
    def vertices(self) -> TriangleVertices:
        """
        :return: vertices of this triangle
        """

        return self.__vertices

    def __contains__(self, vertex: Vertex) -> bool:
        return any(vertex == triangle_vertex for triangle_vertex in self.vertices)

cdef class IndexTriangle:
    cdef c_Terrain_Trees.Triangle * _c_index_triangle
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

        self.__vertices = TriangleVertexIndices(self)
        self.__edges = TriangleEdgeIndices(self)

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
    cdef c_Terrain_Trees.Box * _c_box

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

cdef class Node:
    pass

cdef class Node_V(Node):
    cdef c_Terrain_Trees.Node_V * _c_node_v

    def __cinit__(self):
        """
        a node encoding vertices
        """

        self._c_node_v = new c_Terrain_Trees.Node_V()

    @property
    def first_index(self) -> int:
        """
        :return: first vertex index of this node
        """

        return self._c_node_v.get_v_start()

    @property
    def last_index(self) -> int:
        """
        :return: final vertex index of this node
        """

        return self._c_node_v.get_v_end()

    cpdef c_Terrain_Trees.leaf_VT vertex_triangle_relations(self, Mesh mesh):
        """
        :param mesh: mesh to check
        :return: neighboring vertex indices for each vertex in this triangle 
        """

        cdef c_Terrain_Trees.leaf_VT vertex_triangle_relations
        self._c_node_v.get_VT(vertex_triangle_relations, dereference(mesh._c_mesh))
        return vertex_triangle_relations

    @property
    def is_leaf(self) -> bool:
        """
        :return: whether this node is a leaf node (contains only values)
        """

        return self._c_node_v.is_leaf()

    cpdef Node_V child(self, index: int):
        """
        :param index: index 
        :return: child node at the given index
        """

        cdef Node_V node_v = Node_V()
        if self._c_node_v.get_son(index) is NULL:
            return None
        else:
            node_v._c_node_v = self._c_node_v.get_son(index)
            return node_v

    @property
    def is_indexing_vertices(self) -> bool:
        return self._c_node_v.indexes_vertices()

cdef class Node_T(Node):
    cdef c_Terrain_Trees.Node_T * _c_node_t

    def __cinit__(self):
        """
        a node encoding triangles
        """

        self._c_node_t = new c_Terrain_Trees.Node_T()

    cpdef (int, int) vertex_range(self, Mesh mesh, Box domain):
        """
        :param mesh: mesh to check within
        :param domain: domain to check within
        :return: the first vertex indexed by this node, and the first vertex outside this node
        """

        cdef c_Terrain_Trees.itype start_index
        cdef c_Terrain_Trees.itype end_index
        self._c_node_t.get_v_range(start_index, end_index, dereference(domain._c_box), dereference(mesh._c_mesh))
        return int(start_index), int(end_index)

    def vertex_in_range(self, vertex_index: int, start_index: int, end_index: int) -> bool:
        return self._c_node_t.indexes_vertex(v_start=start_index, v_end=end_index, v_id=vertex_index)

cdef c_Terrain_Trees.Reader * _c_reader
cdef c_Terrain_Trees.Writer * _c_writer

cdef class MeshVertices:
    cdef c_Terrain_Trees.Mesh * _c_mesh

    def __cinit__(self, mesh: Mesh):
        """
        :param mesh: mesh to attach vertices to
        """

        self._c_mesh = mesh._c_mesh

    def __getitem__(self, position: c_Terrain_Trees.itype) -> Vertex:
        cdef c_Terrain_Trees.Vertex vertex = self._c_mesh.get_vertex(position)
        return Vertex(*(vertex.get_c(index) for index in range(2)),
                      tuple(vertex.get_field(index) for index in range(vertex.get_fields_num())))

    cpdef append(self, vertex: Vertex):
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
    cdef c_Terrain_Trees.Mesh * _c_mesh

    def __cinit__(self, mesh: Mesh):
        """
        :param mesh: mesh to attach triangles to
        """

        self._c_mesh = mesh._c_mesh

    def __getitem__(self, position: c_Terrain_Trees.itype) -> IndexTriangle:
        cdef c_Terrain_Trees.Triangle triangle = self._c_mesh.get_triangle(position)
        return IndexTriangle(*(triangle.TV(position) for position in range(triangle.vertices_num())))

    cpdef append(self, triangle: IndexTriangle):
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

    cdef c_Terrain_Trees.Mesh * _c_mesh
    cpdef MeshVertices __vertices
    cpdef MeshTriangles __triangles

    def __cinit__(self):
        self._c_mesh = new c_Terrain_Trees.Mesh()
        self.__vertices = MeshVertices(self)
        self.__triangles = MeshTriangles(self)

    @classmethod
    def from_file(cls, path: PathLike):
        """
        :param path: file path of mesh
        """

        cdef Mesh instance = cls()
        _c_reader.read_mesh(dereference(instance._c_mesh), bytes(str(path), encoding='utf8'))
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
    cdef c_Terrain_Trees.Soup * _c_soup

    def __cinit__(self, soup: Soup):
        """
        :param soup: soup to attach triangles to
        """

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

    cdef c_Terrain_Trees.Soup * _c_soup
    cpdef SoupTriangles __triangles

    def __cinit__(self):
        self._c_soup = new c_Terrain_Trees.Soup()
        self.__triangles = SoupTriangles(self)

    @classmethod
    def from_file(cls, path: PathLike):
        """
        :param path: file path to soup
        """

        cdef Soup instance = cls()
        _c_reader.read_soup(dereference(instance._c_soup), bytes(str(path), encoding='utf8'))
        return instance

    @property
    def triangles(self) -> SoupTriangles:
        """
        :return: triangles of this soup
        """

        return self.__triangles

cdef class TreeCriticalPoints:
    cdef c_Terrain_Trees.c_bool __computed
    cdef c_Terrain_Trees.Critical_Points_Extractor * _c_critical_points_extractor

    def compute(self):
        """
        add critical points information to the given tree
        """

        raise NotImplementedError()

    def computed(self) -> bool:
        return self.__computed

    def print_stats(self):
        self._c_critical_points_extractor.print_stats()

cdef class PointRegionTreeCriticalPoints(TreeCriticalPoints):
    cdef c_Terrain_Trees.PRT_Tree * _c_tree

    def __cinit__(self, tree: PointRegionTree):
        """
        :param tree: tree to attach critical points to
        """

        self._c_tree = tree._c_tree
        self._c_critical_points_extractor = new c_Terrain_Trees.Critical_Points_Extractor()
        self.__computed = False

    def compute(self):
        self._c_critical_points_extractor.compute_critical_points(
            self._c_tree.get_root(),
            self._c_tree.get_mesh(),
            self._c_tree.get_subdivision(),
        )
        self.__computed = True

cdef class TreeTriangleSlopes:
    cdef c_Terrain_Trees.c_bool __computed
    cdef c_Terrain_Trees.Slope_Extractor * _c_slope_extractor

    def compute(self):
        """
        add triangle slope information to the given tree
        """

        raise NotImplementedError()

    def computed(self) -> bool:
        return self.__computed

    def print_stats(self):
        self._c_slope_extractor.print_slopes_stats()
        self._c_slope_extractor.reset_stats()

cdef class PointRegionTreeTriangleSlopes(TreeTriangleSlopes):
    cdef c_Terrain_Trees.PRT_Tree * _c_tree

    def __cinit__(self, tree: PointRegionTree):
        """
        :param tree: tree to attach triangle slopes to
        """

        self._c_tree = tree._c_tree
        self._c_slope_extractor = new c_Terrain_Trees.Slope_Extractor()
        self.__computed = False

    def compute(self):
        self._c_slope_extractor.compute_triangles_slopes(
            self._c_tree.get_root(),
            self._c_tree.get_mesh(),
            self._c_tree.get_subdivision(),
        )
        self._c_slope_extractor.compute_edges_slopes(
            self._c_tree.get_root(),
            self._c_tree.get_mesh(),
            self._c_tree.get_subdivision(),
        )
        self.__computed = True

cdef class Tree:
    """
    a hierarchical tree of nodes
    """

    cdef Mesh __mesh
    cdef int __vertices_per_leaf
    cdef int __division_type

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
    def mesh(self) -> Mesh:
        """
        :return: underlying triangle mesh of this tree
        """

        raise NotImplementedError()

    @property
    def root(self) -> Union[Node_V, Node_T]:
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

    cpdef reindex(self, save_vertex_indices: bool, save_triangle_indices: bool):
        """
        reindex this tree
        
        :param save_vertex_indices: whether to save the vertex indices
        :param save_triangle_indices: whether to save the triangle indices
        """

        raise NotImplementedError()

cdef class PointRegionTree(Tree):
    cdef c_Terrain_Trees.PRT_Tree * _c_tree
    cpdef PointRegionTreeCriticalPoints __critical_points
    cpdef PointRegionTreeTriangleSlopes __triangle_slopes

    def __cinit__(self, vertices_per_leaf: int, division_type: int, build: bool = True):
        self._c_tree = new c_Terrain_Trees.PRT_Tree(vertices_per_leaf, division_type)
        if build:
            self._c_tree.build_tree()
        self.__mesh = Mesh()
        self.__mesh._c_mesh = &self._c_tree.get_mesh()
        self.__vertices_per_leaf = vertices_per_leaf
        self.__division_type = division_type

        self.__critical_points = PointRegionTreeCriticalPoints(self)
        self.__triangle_slopes = PointRegionTreeTriangleSlopes(self)

    @classmethod
    def from_file(cls, path: PathLike, vertices_per_leaf: int, division_type: int) -> PointRegionTree:
        cdef PointRegionTree tree = PointRegionTree(vertices_per_leaf, division_type, build=False)
        cdef Mesh mesh = tree.mesh
        _c_reader.read_mesh(dereference(mesh._c_mesh), bytes(str(path), encoding='utf8'))
        tree._c_tree.build_tree()
        return tree

    def to_file(self, path: PathLike):
        # cdef Node_V root_node = self._c_tree.get_root()
        # _c_writer.write_tree_VTK(bytes(str(path), encoding='utf8'), root_node, self.__division_type, self._c_tree.get_mesh())
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

    @property
    def critical_points(self):
        if not self.__critical_points.__computed:
            self.__critical_points.compute()
        return self.__critical_points

    @property
    def triangle_slopes(self):
        if not self.__triangle_slopes.__computed:
            self.__triangle_slopes.compute()
        return self.__triangle_slopes

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
