from Terrain_Trees import Mesh, Node_V, PRT_Tree
from tests import INPUT_DIRECTORY


def test_mesh():
    mesh_1 = Mesh()
    mesh_2 = Mesh.from_file(str(INPUT_DIRECTORY / 'devil_0.tri'))

    assert len(mesh_1.vertices) == 0
    assert len(mesh_2.vertices) == 32100

    assert len(mesh_1.triangles) == 0
    assert len(mesh_2.triangles) == 63851

    assert mesh_2.vertices[0].coords == [0, 0]
    assert mesh_2.vertices[1].coords == [512, 0]

    assert mesh_2.triangles[0].edges == [512, 0]
    assert mesh_2.vertices[1].coords == [512, 0]

    print('done')


def test_node_v():
    node_v_1 = Node_V()


def test_pr_tree():
    tree_1 = PRT_Tree(1, 4)
    tree_2 = PRT_Tree.from_file(str(INPUT_DIRECTORY / 'devil_0.tri'), 1, 4)

    print('done')
