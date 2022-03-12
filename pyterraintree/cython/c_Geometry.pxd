cdef extern from "basic_types/basic_wrappers.h":
    cdef coord_type

cdef extern from "basic_types/point.h":
    cdef cppclass Point:
        Point()
        Point(const Point& orig)
        Point(coord_type x, coord_type y)

        bool operator==(const Point& p, const Point &q)
        bool operator!=(const Point& p, const Point & q)
        bool operator <(const Point& s)
        bool operator >(const Point& s)
        Point operator+(const Point & s)
        Point operator-(const Point & s)
        Point operator *(const coord_type & f)
        coord_type get_x()
        coord_type get_y()
        coord_type get_c(int pos)
        set_c(int pos, coord_type c)
        set(coord_type x, coord_type y)
        set(Point &p)
        int get_dimension()
        coord_type distance(Point& v)

cdef extern from "basic_types/box.h":
    cdef cppclass Box:
        Box()
        Box(const Box& orig)
        Box(Point& min, Point& max)

        Point& get_min()
        Point& get_max()
        set_min(coord_type x, coord_type y)
        set_max(coord_type x, coord_type y)