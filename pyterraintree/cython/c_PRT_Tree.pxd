cimport c_Mesh
cimport c_Node_V


cdef extern from "terrain_trees/prt_tree.h":
    cdef cppclass PRT_Tree:
        PRT_Tree(int, int) except +
        void build_tree()
        c_Mesh.Mesh& get_mesh()
        c_Node_V.Node_V& get_root()
        # int get_leaves_number()
