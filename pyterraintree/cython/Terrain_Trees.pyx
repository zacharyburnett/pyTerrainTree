# distutils: language = c++
from typing import List

cimport c_Mesh
cimport c_Node_V
cimport c_PRT_Tree
cimport c_Reader
cimport c_Reindexer
cimport c_Triangle
cimport c_Vertex
from cython.operator cimport dereference
from libcpp cimport bool
from libcpp.vector cimport vector


cdef c_Reader.Reader *_c_tree_reader


cdef class Mesh:
    cdef c_Mesh.Mesh *_c_mesh

    def __cinit__(self):
        self._c_mesh = new c_Mesh.Mesh()

    def vertex(self, int position) -> Vertex:
        vertex = Vertex()
        vertex._c_vertex = self._c_mesh.get_vertex(position)
        return vertex

    def triangle(self, int position) -> Triangle:
        triangle = Triangle()
        triangle._c_triangle = self._c_mesh.get_triangle(position)
        return triangle

    # def __dealloc__(self):  ## will cause segmentation fault.
    #     del self._c_mesh

cdef class Vertex:
    cdef c_Vertex.Vertex _c_vertex

    def __cinit__(self):
        self._c_vertex = c_Vertex.Vertex()

    def coordinate(self, int position) -> float:
        return self._c_vertex.get_c(position)

cdef class Triangle:
    cdef c_Triangle.Triangle _c_triangle

    def __cinit__(self):
        self._c_triangle = c_Triangle.Triangle()

    def vertex(self, int position) -> int:
        return self._c_triangle.TV(position)

    def edge(self, int position) -> List[int]:
        cdef vector[int] edge
        self._c_triangle.TE(position, edge)
        return edge

cdef class Node_V:
    cdef c_Node_V.Node_V *_c_node_v
    # cdef vector[set[int]] vvs

    def __cinit__(self):
        self._c_node_v = new c_Node_V.Node_V()

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
        node_v = Node_V()
        if self._c_node_v.get_son(index) is NULL:
            return None
        else:
            node_v._c_node_v = self._c_node_v.get_son(index)
            return node_v

    @property
    def is_indexing_vertices(self) -> bool:
        return self._c_node_v.indexes_vertices()

    # def __dealloc__(self):
    #     del self._c_node_v

cdef class PRT_Tree:
    cdef c_PRT_Tree.PRT_Tree *_c_tree

    def __cinit__(self, int vertices_per_leaf, int division_type, build: bool = True):
        self._c_tree = new c_PRT_Tree.PRT_Tree(vertices_per_leaf, division_type)
        if build:
            self._c_tree.build_tree()

    @classmethod
    def from_file(cls, str path, int vertices_per_leaf, int division_type) -> PRT_Tree:
        tree = PRT_Tree(vertices_per_leaf, division_type, build=False)
        tree.read_file(path)
        tree._c_tree.build_tree()
        return tree

    def read_file(self, str path):
        _c_tree_reader.read_mesh(self._c_tree.get_mesh(), bytes(path, encoding='utf8'))

    @property
    def mesh(self) -> Mesh:
        mesh = Mesh()
        mesh._c_mesh = &(self._c_tree.get_mesh())
        return mesh

    @property
    def root(self) -> Node_V:
        node = Node_V()
        node._c_node_v = &(self._c_tree.get_root())
        return node

    # @property
    # def leaf_blocks(self) -> int:
    #     return self._c_tree.get_leaves_number()

    def reindex(self, bool save_vertex_indices, bool save_triangle_indices):
        cdef c_Reindexer.Reindexer _c_reindexer = c_Reindexer.Reindexer()
        cdef vector[int] original_vertex_indices
        cdef vector[int] original_triangle_indices

        _c_reindexer.reindex_tree_and_mesh(
            dereference(self._c_tree),
            save_vertex_indices,
            original_vertex_indices,
            save_vertex_indices,
            original_triangle_indices
        )

    def __dealloc__(self):
        del self._c_tree
