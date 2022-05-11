from Terrain_Trees import Node_V, PointRegionTree

from tests import INPUT_DIRECTORY


def test_point_region_tree():
    tree_1 = PointRegionTree(1, 4)
    tree_2 = PointRegionTree.from_file(str(INPUT_DIRECTORY / 'devil_0.tri'), 1, 4)

    assert tree_1.root.is_leaf
    assert not tree_1.root.is_indexing_vertices

    assert not tree_2.root.is_leaf
    assert not tree_2.root.is_indexing_vertices
    assert tree_2.root.first_index == 1
    assert tree_2.root.last_index == 4

    assert isinstance(tree_2.root.child(0), Node_V)

    assert tree_2.leaf_blocks == 0

    assert len(tree_2.mesh.vertices) == 0
    assert len(tree_2.mesh.triangles) == 0


def test_point_region_critical_points():
    tree_1 = PointRegionTree(1, 4)

    critical_points = tree_1.critical_points
    critical_points.compute()

    critical_points.print_stats()


def test_point_region_triangle_slopes():
    tree_1 = PointRegionTree(1, 4)

    triangle_slopes = tree_1.triangle_slopes
    triangle_slopes.compute()

    triangle_slopes.print_stats()
