import pytest
from Terrain_Trees import Point, Triangle, Vertex


def test_point():
    point_1 = Point(0, 0)
    point_2 = Point(0, 1)
    point_3 = Point(1, 4)

    with pytest.raises(TypeError):
        Point(0)

    with pytest.raises(TypeError):
        Point()

    assert point_1.coords == [0, 0]
    assert point_2.coords == [0, 1]
    assert point_3.coords == [1, 4]

    assert point_1.distance(point_2) == 1
    assert point_1.distance(point_3) >= 4.123
    assert point_2.distance(point_3) >= 3.162


def test_vertex():
    vertex_1 = Vertex(0, 1, [])
    vertex_2 = Vertex(0, 1, [3.2])
    vertex_3 = Vertex(1, 4, [1.1, 1.2])

    assert vertex_1.coords == [0, 0]
    assert vertex_2.coords == [0, 1]
    assert vertex_3.coords == [1, 4]

    assert vertex_1.fields == []
    assert vertex_2.fields == [3.2]
    assert vertex_3.fields == [1.1, 1.2]


def test_triangle():
    triangle_1 = Triangle()
