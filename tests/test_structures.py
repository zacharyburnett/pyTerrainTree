from pyterraintree import Mesh, Node_V, PointRegionTree
from tests import INPUT_DIRECTORY


def test_mesh():
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


def test_pr_tree():
    tree_1 = PointRegionTree(1, 4)
    tree_2 = PointRegionTree.from_file(str(INPUT_DIRECTORY / 'devil_0.tri'), 1, 4)

    assert tree_1.root.is_leaf
    assert not tree_1.root.is_indexing_vertices

    assert not tree_2.root.is_leaf
    assert not tree_2.root.is_indexing_vertices
    assert tree_2.root.v_start == 1
    assert tree_2.root.v_end == 4

    assert isinstance(tree_2.root.child(0), Node_V)

    assert tree_2.leaf_blocks == 0

    assert len(tree_2.mesh.vertices) == 0
    assert len(tree_2.mesh.triangles) == 0
