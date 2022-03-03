cimport c_Triangle
cimport c_Vertex


cdef extern from "basic_types/mesh.h":
    cdef cppclass Mesh:
        Mesh() except +
        c_Vertex.Vertex& get_vertex(int)
        c_Triangle.Triangle& get_triangle(int)
        # Mesh(const Mesh) except +
        #V& getVertex(int)
        #double getX()
        #double getY()
        #double getZ()
        #int getNumVertex()
        #int getTopSimplexesNum()
