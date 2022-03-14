from Terrain_Trees import Mesh

from tests import INPUT_DIRECTORY


def test_mesh():
    mesh_1 = Mesh()
    mesh_2 = Mesh.from_file(str(INPUT_DIRECTORY / 'devil_0.tri'))

    print('done')
