cdef extern from "basic_types/vertex.h":
    cdef cppclass Vertex:
        Vertex() except +
        double get_c(int pos)
