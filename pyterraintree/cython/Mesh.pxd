from Triangle cimport Triangle
from Vertex cimport Vertex


cdef extern from "basic_types/mesh.h":
    cdef cppclass Mesh:
        Mesh() except +
        Vertex& get_vertex(int)
        Triangle& get_triangle(int)
        # Mesh(const Mesh) except +
        #V& getVertex(int)
        #double getX()
        #double getY()
        #double getZ()
        #int getNumVertex()
        #int getTopSimplexesNum()
