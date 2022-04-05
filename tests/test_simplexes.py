import pytest

from pyterraintree import Point, Triangle, Vertex


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
    vertex_1 = Vertex(0, 0)
    vertex_2 = Vertex(0, 1, [])
    vertex_3 = Vertex(0, 1, [3.2])
    vertex_4 = Vertex(1, 4, [1.1, 1.2])

    assert vertex_1.coords == [0, 0]
    assert vertex_2.coords == [0, 1]
    assert vertex_3.coords == [0, 1]
    assert vertex_4.coords == [1, 4]

    assert vertex_1.fields == [0]
    assert vertex_2.fields == [0]
    assert vertex_3.fields == [3.2]
    assert vertex_4.fields == [1.1, 1.2]


def test_triangle():
    triangle_1 = Triangle(0, 1, 2)
    triangle_2 = Triangle(3, 1, 2)
    triangle_3 = Triangle(2, 1, 0)
    triangle_4 = Triangle(0, 1, 2)

    assert triangle_1 != triangle_2
    assert triangle_1 == triangle_3
    assert triangle_1 == triangle_4

    assert len(triangle_1.vertices) == 3
    assert len(triangle_2.vertices) == 3
    assert len(triangle_3.vertices) == 3
    assert len(triangle_4.vertices) == 3

    assert triangle_1.vertices[0] == 0
    assert triangle_3.vertices[0] == 2

    assert len(triangle_1.edges) == 3
    assert len(triangle_2.edges) == 3
    assert len(triangle_3.edges) == 3
    assert len(triangle_4.edges) == 3

    assert triangle_1.edges[0] == [1, 2]
    assert triangle_3.edges[0] == [0, 1]

    assert 1 in triangle_1
    assert 3 not in triangle_1
    assert [1, 2] in triangle_1
    assert [2, 1] in triangle_1
    assert [3, 1] not in triangle_1
