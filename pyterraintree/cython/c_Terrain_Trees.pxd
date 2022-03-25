from libcpp cimport bool as c_bool
from libcpp.map cimport map as c_map
from libcpp.pair cimport pair
from libcpp.set cimport set as c_set
from libcpp.string cimport string
from libcpp.vector cimport vector as vector


cdef extern from "basic_types/basic_wrappers.h":
    ctypedef unsigned utype

    ctypedef int itype
    ctypedef vector[int] ivect
    ctypedef c_set[int] iset
    
    ctypedef ivect VT
    ctypedef iset VV
    ctypedef ivect VV_vec
    ctypedef vector[VT] leaf_VT
    ctypedef vector[VV] leaf_VV
    
    ctypedef pair[itype, itype] ET
    ctypedef c_map[ivect, ET] leaf_ET

    ctypedef double coord_type
    ctypedef vector[double] dvect
    ctypedef c_set[double] dset
    ctypedef c_map[int, c_set[double]] vertex_multifield;


cdef extern from "basic_types/point.h":
    cdef cppclass Point:
        Point() except +
        Point(Point& orig) except +
        Point(coord_type x, coord_type y) except +

        c_bool operator ==(Point& p, Point& q)
        c_bool operator !=(Point& p, Point& q)
        c_bool operator <(Point& s)
        c_bool operator >(Point& s)
        Point add "operator+"(Point& s)
        Point sub "operator-"(Point& s)
        Point mul "operator*"(coord_type& f)

        int get_dimension()
        coord_type get_c(int pos)
        void set(coord_type x, coord_type y)
        void set(Point& p)
        void set_x(coord_type x)
        void set_y(coord_type y)
        void set_c(int pos, coord_type c)

        coord_type distance(Point& v)


cdef extern from "basic_types/box.h":
    cdef cppclass Box:
        Box()
        # Box(Box& orig)
        # Box(Point& min, Point& max) except +

        Point& get_min()
        void set_min(coord_type x, coord_type y)

        Point& get_max()
        void set_max(coord_type x, coord_type y)


cdef extern from "basic_types/vertex.h":
    cdef cppclass Vertex:
        Vertex() except +
        # Vertex(Vertex& orig) except +
        Vertex(coord_type x, coord_type y, coord_type field) except +
        Vertex(coord_type x, coord_type y, dvect & fields) except +

        coord_type get_z()
        coord_type get_c(int pos)
        void set_c(int pos, coord_type c)

        coord_type norm(Vertex& v)
        coord_type scalar_product(Vertex& v1, Vertex& v2)

        int get_fields_num()
        coord_type get_field(int pos)
        void add_field(coord_type f)


cdef extern from "basic_types/triangle.h":
    cdef cppclass Triangle:
        Triangle() except +
        # Triangle(Triangle& orig) except +
        Triangle(ivect& v) except +

        void set(itype v1, itype v2, itype v3)

        itype TV(int pos)
        void setTV(int pos, itype newId)
        void TE(int pos, vector[int]& e)

        int vertices_num()
        c_bool has_vertex(itype v_id)

        c_bool is_border_edge(int pos)
        c_bool has_edge(const ivect & e)
        short edge_index(const ivect & e)

        c_bool operator ==(const Triangle & p, const Triangle & q)
        c_bool operator !=(const Triangle & p, const Triangle & q)

        c_bool has_simplex(ivect & s)

        void convert_to_vec(ivect & t)


cdef extern from "terrain_trees/node_v.h":
    cdef cppclass Node_V:
        Node_V() except +

        int get_v_start()
        int get_v_end()

        void get_VT(vector[vector[int]] & all_vt, Mesh & mesh)
        void get_VV(leaf_VV & all_vv, Mesh& mesh)
        void get_VV_VT(leaf_VV & all_vv, leaf_VT & all_vt, Mesh& mesh)
        void get_ET(leaf_ET & ets, Mesh & mesh)
        
        Node_V * get_son(int)

        c_bool is_leaf()
        c_bool indexes_vertices()

        utype get_real_v_array_size()
        utype get_v_array_size()


cdef extern from "basic_types/mesh.h":
    cdef cppclass Mesh:
        Mesh() except +
        # Mesh(Mesh& orig) except +

        Box& get_domain()

        utype get_vertices_num()
        Vertex& get_vertex(itype id)
        void add_vertex(Vertex& v)
        void remove_vertex(itype v_id)
        void vertices_swap(int v_id1, int v_id2)
        c_bool is_vertex_removed(itype v)
        c_bool is_vertex_removed(Vertex& v)

        utype get_triangles_num()
        Triangle& get_triangle(itype id)
        void add_triangle(Triangle& t)
        void remove_triangle(itype t)
        void triangles_swap(int t_id1, int t_id2)
        c_bool is_triangle_removed(itype t)
        c_bool is_triangle_removed(Triangle& t)

        # itype get_max_elevation_vertex(Triangle& t)
        # itype get_max_elevation_vertex(ivect& vect)


cdef extern from "basic_types/soup.h":
    cdef cppclass Soup:
        Soup() except +
        # Soup(Soup& orig) except +

        Box get_domain()


cdef extern from "terrain_trees/prt_tree.h":
    cdef cppclass PRT_Tree:
        PRT_Tree()
        PRT_Tree(int vertices_per_leaf, int sons_num) except +
        # PRT_Tree(PRT_Tree& orig) except +

        void build_tree()
        void build_tree(Soup & soup)

        Mesh& get_mesh()

        Node_V& get_root()
        unsigned get_leaves_number()


cdef extern from "terrain_trees/reindexer.h":
    cdef cppclass Reindexer:
        Reindexer() except +
        void reindex_tree_and_mesh(
                PRT_Tree& tree, c_bool save_v_indices, vector[int] & original_vertex_indices,
                c_bool save_t_indices, vector[int] & original_triangle_indices
        )


cdef extern from "io/reader.h":
    cdef cppclass Reader:
        @staticmethod
        c_bool read_mesh(Mesh& mesh, string path)


cdef extern from "io/writer.h":
    cdef cppclass N:
        pass

    cdef cppclass D:
        pass

    cdef cppclass Writer:
        @staticmethod
        void write_point_queries(c_set[Point]& points, string fileName)

        @staticmethod
        void write_box_queries(c_set[Box] boxes, string fileName)

        @staticmethod
        void write_tree_VTK(string file_name, N & root, D & division, Mesh & mesh)

        @staticmethod
        void write_mesh(string mesh_name, string operation_type, Mesh & mesh, c_bool extra_fields)

        @staticmethod
        void write_mesh_VTK(string mesh_name, Mesh & mesh)

        @staticmethod
        void write_mesh_curvature_VTK(string mesh_name, Mesh & mesh, string curvature_type, int c_pos)
        @staticmethod
        void write_mesh_roughness_VTK(string mesh_name, Mesh & mesh, int c_pos)
        @staticmethod
        void write_mesh_gradient_VTK(string mesh_name, Mesh & mesh, int c_pos)
        @staticmethod
        void write_mesh_multifield_VTK(string mesh_name, Mesh & mesh, int c_pos, string mode)
        @staticmethod
        void write_tri_slope_VTK(string mesh_name, Mesh & mesh, c_map[itype, coord_type] slopes)

        @staticmethod
        void write_filtered_points_cloud(string mesh_name, Mesh & mesh)
        @staticmethod
        void write_filtered_points_cloud_with_id(string mesh_name, Mesh & mesh)
        @staticmethod
        void write_multifield_points_cloud(string mesh_name, vertex_multifield & multifield, Mesh & mesh)

        @staticmethod
        void write_field_csv(string mesh_name, Mesh & mesh)
        @staticmethod
        void write_critical_points_morse(string mesh_name, c_map[short, c_set[ivect]] & critical_simplices, Mesh & mesh)
        @staticmethod
        void write_critical_points(string mesh_name, vector[short] & critical_simplices, Mesh & mesh)
