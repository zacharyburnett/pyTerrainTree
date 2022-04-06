from Terrain_Trees import Mesh, Soup
from tests import INPUT_DIRECTORY


def test_from_file():
    mesh_1 = Mesh()
    mesh_2 = Mesh.from_file(str(INPUT_DIRECTORY / 'devil_0.tri'))

    assert len(mesh_1.vertices) == 0
    assert len(mesh_2.vertices) == 32100

    assert len(mesh_1.triangles) == 0
    assert len(mesh_2.triangles) == 63851

    assert mesh_2.vertices[1].coords == [512, 0]
    assert mesh_2.vertices[5].coords == [0, 256]

    assert list(mesh_2.triangles[15].edges) == [[54, 58], [54, 90], [58, 90]]
    assert list(mesh_2.triangles[6].edges) == [[20, 60], [60, 92], [20, 92]]
