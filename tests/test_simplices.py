from Terrain_Trees import IndexTriangle


def test_index_triangle():
    triangle_1 = IndexTriangle(0, 1, 2)
    triangle_2 = IndexTriangle(3, 1, 2)
    triangle_3 = IndexTriangle(2, 1, 0)
    triangle_4 = IndexTriangle(0, 1, 2)

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
