from libcpp cimport bool as c_bool
from libcpp.map cimport map as c_map
from libcpp.pair cimport pair
from libcpp.set cimport set as c_set
from libcpp.string cimport string
from libcpp.vector cimport vector as vector


cdef extern from "basic_types/basic_wrappers.h":
    ctypedef unsigned utype

    ctypedef int itype
    ctypedef unsigned utype
    ctypedef vector[int] ivect
    ctypedef vector[utype] uvect
    ctypedef c_set[ivect] ivect_set
    ctypedef c_set[int] iset

    ctypedef ivect VT
    ctypedef iset VV
    ctypedef ivect VV_vec
    ctypedef vector[VT] leaf_VT
    ctypedef vector[VV] leaf_VV
    ctypedef vector[VV_vec] leaf_VV_vec
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
        Box() except +
        # Box(Box& orig)
        Box(Point& min, Point& max) except +

        Point& get_min()
        void set_min(coord_type x, coord_type y)

        Point& get_max()
        void set_max(coord_type x, coord_type y)


cdef extern from "basic_types/vertex.h":
    cdef cppclass Vertex:
        Vertex() except +
        # Vertex(Vertex& orig) except +
        Vertex(coord_type x, coord_type y) except +
        Vertex(coord_type x, coord_type y, coord_type field) except +
        Vertex(coord_type x, coord_type y, dvect& fields) except +

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
        Triangle(itype v1, itype v2, itype v3) except +

        void set(itype v1, itype v2, itype v3)

        itype TV(int pos)
        void setTV(int pos, itype newId)
        void TE(int pos, vector[int]& e)

        int vertices_num()
        c_bool has_vertex(itype v_id)

        c_bool is_border_edge(int pos)
        c_bool has_edge(const ivect& e)
        short edge_index(const ivect& e)

        c_bool operator ==(const Triangle& p, const Triangle& q)
        c_bool operator !=(const Triangle& p, const Triangle& q)

        c_bool has_simplex(ivect& s)

        void convert_to_vec(ivect& t)

cdef extern from "basic_types/explicit_triangle.h":
    cdef cppclass Explicit_Triangle:
        Explicit_Triangle() except +

        Vertex& get_vertex(int pos)
        void add_vertex(Vertex& v)

        int vertices_num()

cdef extern from "terrain_trees/node_v.h":
    cdef cppclass Node_V:
        Node_V() except +

        int get_v_start()
        int get_v_end()

        void get_VT(leaf_VT& all_vt, Mesh& mesh)
        void get_VV(leaf_VV& all_vv, Mesh& mesh)
        void get_VV_VT(leaf_VV& all_vv, leaf_VT& all_vt, Mesh& mesh)
        void get_ET(leaf_ET& ets, Mesh& mesh)

        Node_V * get_son(int)

        c_bool is_leaf()
        c_bool indexes_vertices()

        utype get_real_v_array_size()
        utype get_v_array_size()

cdef extern from "terrain_trees/node_t.h":
    cdef cppclass Node_T:
        Node_T() except +

        void get_v_range(itype& v_start, itype& v_end, Box& dom, Mesh& mesh)
        c_bool indexes_vertex(itype v_start, itype v_end, itype v_id)

        void get_VT(leaf_VT& all_vt, Box& dom, Mesh& mesh)
        void get_VT(leaf_VT& all_vt, itype v_start, itype v_end, Mesh& mesh)
        void get_VV(leaf_VV& all_vv, Box& dom, Mesh& mesh)
        void get_VV(leaf_VV& all_vv, itype v_start, itype v_end, Mesh& mesh)
        void get_VV_vector(leaf_VV_vec& all_vv, Box& dom, Mesh& mesh)
        void get_VV_vector(leaf_VV_vec& all_vv, itype v_start, itype v_end, Mesh& mesh)
        void get_VV_VT(leaf_VV& all_vv, leaf_VT& all_vt, itype v_start, itype v_end, Mesh& mesh);
        void get_ET(leaf_ET& ets, itype v_start, itype v_end, Mesh& mesh);

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

        Box& get_domain()

        Explicit_Triangle& get_triangle(itype id)
        void add_triangle(Explicit_Triangle& t)

        itype get_triangles_num()

cdef extern from "terrain_trees/tree.h":
    cdef cppclass Tree:
        Mesh& get_mesh()
        # N& get_root()
        Spatial_Subdivision& get_subdivision()
        void build_tree()
        void build_tree(Soup& soup)
        void build_tree_from_cloud(vertex_multifield& multifield)

cdef extern from "terrain_trees/prt_tree.h":
    cdef cppclass PRT_Tree(Tree):
        PRT_Tree()
        PRT_Tree(int vertices_per_leaf, int sons_num) except +
        # PRT_Tree(PRT_Tree& orig) except +

        void build_tree()
        void build_tree(Soup& soup)

        Node_V& get_root()
        unsigned get_leaves_number()


cdef extern from "terrain_trees/reindexer.h":
    cdef cppclass Reindexer:
        Reindexer() except +
        void reindex_tree_and_mesh(
                PRT_Tree& tree, c_bool save_v_indices, vector[int]& original_vertex_indices,
                c_bool save_t_indices, vector[int]& original_triangle_indices
        )


cdef extern from "io/reader.h":
    cdef cppclass Reader:
        @ staticmethod
        c_bool read_mesh(Mesh& mesh, string path)

        @ staticmethod
        c_bool read_soup(Soup& soup, string path)

        @ staticmethod
        c_bool read_tree(Tree& tree, Node_V& n, string fileName)


cdef extern from "io/writer.h":
    ctypedef fused D:
        Spatial_Subdivision

    ctypedef fused N:
        Node_V
        Node_T

    cdef cppclass Writer:
        @ staticmethod
        void write_point_queries(c_set[Point]& points, string fileName)

        @ staticmethod
        void write_box_queries(c_set[Box] boxes, string fileName)

        @ staticmethod
        void write_tree(string fileName, Node_V& root, Spatial_Subdivision& division)

        @ staticmethod
        void write_tree_VTK(string file_name, Node_V& root, Spatial_Subdivision& division, Mesh& mesh)

        @ staticmethod
        void write_tree_VTK(string file_name, Node_T& root, Spatial_Subdivision& division, Mesh& mesh)

        @ staticmethod
        void write_mesh(string mesh_name, string operation_type, Mesh& mesh, c_bool extra_fields)

        @ staticmethod
        void write_mesh_VTK(string mesh_name, Mesh& mesh)

        @ staticmethod
        void write_mesh_curvature_VTK(string mesh_name, Mesh& mesh, string curvature_type, int c_pos)
        @ staticmethod
        void write_mesh_roughness_VTK(string mesh_name, Mesh& mesh, int c_pos)
        @ staticmethod
        void write_mesh_gradient_VTK(string mesh_name, Mesh& mesh, int c_pos)
        @ staticmethod
        void write_mesh_multifield_VTK(string mesh_name, Mesh& mesh, int c_pos, string mode)
        @ staticmethod
        void write_tri_slope_VTK(string mesh_name, Mesh& mesh, c_map[itype, coord_type] slopes)

        @ staticmethod
        void write_filtered_points_cloud(string mesh_name, Mesh& mesh)
        @ staticmethod
        void write_filtered_points_cloud_with_id(string mesh_name, Mesh& mesh)
        @ staticmethod
        void write_multifield_points_cloud(string mesh_name, vertex_multifield& multifield, Mesh& mesh)

        @ staticmethod
        void write_field_csv(string mesh_name, Mesh& mesh)
        @ staticmethod
        void write_critical_points_morse(string mesh_name, c_map[short, c_set[ivect]]& critical_simplices, Mesh& mesh)
        @ staticmethod
        void write_critical_points(string mesh_name, vector[short]& critical_simplices, Mesh& mesh)


cdef extern from "terrain_trees/spatial_subdivision.h":
    cdef cppclass Spatial_Subdivision:
        Spatial_Subdivision(int sn) except +

        int son_number()
        Box compute_domain(Box& parent_dom, int level, int child_ind)


cdef extern from "terrain_features/critical_points_extractor.h":
    cdef cppclass Critical_Points_Extractor:
        void compute_critical_points(Node_V& n, Mesh& mesh, Spatial_Subdivision& division)
        void compute_critical_points(Node_T& n, Box& dom, Mesh& mesh, Spatial_Subdivision& division)
        void print_stats()
        vector[short] get_critical_points()


cdef extern from "terrain_features/slope_extractor.h":
    cdef cppclass Slope_Extractor:
        Slope_Extractor() except +

        void compute_triangles_slopes(Node_V& n, Mesh& mesh, Spatial_Subdivision& division)
        void compute_triangles_slopes(Node_T& n, Box& dom, int level, Mesh& mesh, Spatial_Subdivision& division)

        void compute_edges_slopes(Node_V& n, Mesh& mesh, Spatial_Subdivision& division)
        void compute_edges_slopes(Node_T& n, Box& dom, int level, Mesh& mesh, Spatial_Subdivision& division)

        void print_slopes_stats()
        void print_slopes_stats(utype tnum)

        void reset_stats()
        c_map[itype, coord_type] get_tri_slopes()

cdef extern from "terrain_features/Aspect.h":
    cdef cppclass Aspect:
        Aspect() except +

        void compute_triangles_aspects(Node_V& n, Mesh& mesh, Spatial_Subdivision& division)
        void compute_triangles_aspects(Node_T& n, Box& dom, int level, Mesh& mesh, Spatial_Subdivision& division)

        void print_aspects_stats()
        void print_aspects_stats(utype tnum)

        void reset_stats()

cdef extern from "morse/forman_gradient.h":
    cdef cppclass Forman_Gradient:
        Forman_Gradient(itype num_t) except +

        c_bool is_triangle_critical(itype t)
        c_bool is_edge_critical(const ivect& e, const pair[itype, itype]& et, Mesh& mesh)
        c_bool is_edge_critical(const ivect& e, itype etstar, Mesh& mesh)
        c_bool is_vertex_critical(itype v, itype t_id, Mesh& mesh)

        void set_VE(itype v, itype v2, pair[itype, itype]& et, Mesh& mesh)
        void set_VE(itype v, itype v2, leaf_ET& et, Mesh& mesh)
        void free_VE(itype v1, itype v2, pair[itype, itype]& et, Mesh& mesh)

        void set_ET(itype t, const ivect& edge, Mesh& mesh);
        void free_ET(int v_pos, itype t)

cdef extern from "morse/forman_gradient_computation.h":
    cdef cppclass Forman_Gradient_Computation:
        Forman_Gradient_Computation() except +

        void compute_gradient_vector(Forman_Gradient& gradient, Node_V& n, Mesh& mesh, Spatial_Subdivision& division)
        void compute_gradient_vector(Forman_Gradient& gradient, Node_T& n, Box& n_dom, Mesh& mesh, Spatial_Subdivision& division)
        void compute_gradient_vector(Forman_Gradient& gradient, Node_V& n, Mesh& mesh, Spatial_Subdivision& division, c_bool output)
        void compute_gradient_vector(Forman_Gradient& gradient, Node_T& n, Box& n_dom, Mesh& mesh, Spatial_Subdivision& division, c_bool output)

        void initial_filtering(Mesh& mesh);
        void initial_filtering_IA(Mesh& mesh);
        uvect get_filtration()
        void reset_filtering(Mesh& mesh, ivect& original_vertex_indices);
        c_map[short, ivect_set]& get_critical_simplices()
