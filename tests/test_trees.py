from Terrain_Trees import Node_V, PointRegionTree
from tests import INPUT_DIRECTORY


def test_point_region_tree():
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
