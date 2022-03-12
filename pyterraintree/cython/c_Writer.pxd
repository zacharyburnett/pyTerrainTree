from typing import List

from libcpp cimport bool
from libcpp.string cimport string

cimport c_Geometry


# Declare the class Mesh with cdef
cdef extern from "io/writer.h":
    cdef cppclass Writer:
        @staticmethod
        void write_point_queries(List[c_Geometry.Point] &points, string fileName);

        @staticmethod
        void write_box_queries(List[c_Geometry.Box] boxes, string fileName);

        @ staticmethod
        template<class N, class D> static void write_tree_VTK(string file_name, N &root, D &division, Mesh &mesh);

        @ staticmethod
        void write_mesh(string mesh_name, string operation_type, Mesh &mesh, bool extra_fields); /// OFF format

        @staticmethod
        void write_mesh_VTK(string mesh_name, Mesh &mesh);

        @staticmethod
        void write_mesh_curvature_VTK(string mesh_name, Mesh &mesh, string curvature_type, int c_pos);
        @staticmethod
        void write_mesh_roughness_VTK(string mesh_name, Mesh &mesh, int c_pos);
        @staticmethod
        void write_mesh_gradient_VTK(string mesh_name, Mesh &mesh, int c_pos);
        @staticmethod
        void write_mesh_multifield_VTK(string mesh_name, Mesh &mesh, int c_pos,string mode);
        @staticmethod
        void write_tri_slope_VTK(string mesh_name, Mesh &mesh,map<itype,coord_type> slopes);

        @staticmethod
        void write_filtered_points_cloud(string mesh_name, Mesh &mesh); /// SpatialHadoop format
        @staticmethod
        void write_filtered_points_cloud_with_id(string mesh_name, Mesh &mesh); /// SpatialHadoop format with vertex index
        @staticmethod
        void write_multifield_points_cloud(string mesh_name, vertex_multifield &multifield, Mesh &mesh);

        @staticmethod
        void write_field_csv(string mesh_name, Mesh &mesh);
        @staticmethod
        void write_critical_points_morse(string mesh_name, map<short, set<ivect> > &critical_simplices, Mesh &mesh);
        @staticmethod
        void write_critical_points(string mesh_name, vector<short> &critical_simplices, Mesh &mesh);
