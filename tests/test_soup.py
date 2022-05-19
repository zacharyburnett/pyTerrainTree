from Terrain_Trees import Soup

from tests import INPUT_DIRECTORY


def test_from_file():
    soup_1 = Soup()
    soup_2 = Soup.from_file(str(INPUT_DIRECTORY / 'simple_terrain.soup'))

    assert len(soup_1.triangles) == 0
    assert len(soup_2.triangles) == 18

    assert list(vertex.coords for vertex in soup_2.triangles[15].vertices) == [
        [1.0, 2.0],
        [1.0, 3.0],
        [2.0, 2.0],
    ]
    assert list(vertex.coords for vertex in soup_2.triangles[6].vertices) == [
        [2.0, 1.0],
        [3.0, 0.0],
        [3.0, 1.0],
    ]
