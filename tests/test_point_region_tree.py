from Terrain_Trees import PointRegionTree, VertexNode

from tests import INPUT_DIRECTORY


# def test_read_soup():
#     soup = Soup.from_file(str(INPUT_DIRECTORY / 'simple_terrain.soup'))
#     tree = PointRegionTree.from_soup(soup, 1, 4)


def test_structure():
    tree_1 = PointRegionTree(1, 4)
    tree_2 = PointRegionTree.from_file(str(INPUT_DIRECTORY / 'devil_0.tri'), 1, 4)

    assert tree_1.root.is_leaf
    assert not tree_1.root.is_indexing_vertices

    assert not tree_2.root.is_leaf
    assert not tree_2.root.is_indexing_vertices
    assert tree_2.root.first_index == 1
    assert tree_2.root.last_index == 4

    assert isinstance(tree_2.root.child(0), VertexNode)

    assert tree_2.leaf_blocks == 0

    assert len(tree_2.mesh.vertices) == 32100
    assert len(tree_2.mesh.triangles) == 63851


def test_nodes():
    tree = PointRegionTree.from_file(str(INPUT_DIRECTORY / 'devil_0.tri'), 1, 4)

    root_node = tree.root
    child_1 = root_node.child(0)
    child_2 = root_node.child(1)
    child_3 = root_node.child(2)
    child_4 = root_node.child(3)
    child_5 = child_1.child(0)

    assert not root_node.is_leaf
    assert not root_node.is_indexing_vertices
    assert root_node.first_index == 1
    assert root_node.last_index == 4
    assert root_node.vertex_triangle_relations(tree.mesh) == []

    assert not child_1.is_leaf
    assert not child_1.is_indexing_vertices
    assert child_1.first_index == 9
    assert child_1.last_index == 21
    assert child_1.vertex_triangle_relations(tree.mesh) == []

    assert not child_2.is_leaf
    assert not child_2.is_indexing_vertices
    assert child_2.first_index == 1
    assert child_2.last_index == 6
    assert child_2.vertex_triangle_relations(tree.mesh) == []

    assert not child_3.is_leaf
    assert not child_3.is_indexing_vertices
    assert child_3.first_index == 2
    assert child_3.last_index == 8
    assert child_3.vertex_triangle_relations(tree.mesh) == []

    assert not child_4.is_leaf
    assert not child_4.is_indexing_vertices
    assert child_4.first_index == 3
    assert child_4.last_index == 10
    assert child_4.vertex_triangle_relations(tree.mesh) == []

    assert not child_5.is_leaf
    assert not child_5.is_indexing_vertices
    assert child_5.first_index == 25
    assert child_5.last_index == 53
    assert child_5.vertex_triangle_relations(tree.mesh) == []


def test_critical_points():
    tree_1 = PointRegionTree.from_file(str(INPUT_DIRECTORY / 'devil_0.tri'), 1, 4)

    critical_points = tree_1.critical_points
    critical_points.print_stats()


# def test_forman_gradient():
#     tree_1 = PointRegionTree.from_file(str(INPUT_DIRECTORY / 'devil_0.tri'), 1, 4)
#
#     forman_gradient = tree_1.forman_gradient
#     critical_simplices = forman_gradient.critical_simplices


def test_triangle_slopes():
    tree_1 = PointRegionTree.from_file(str(INPUT_DIRECTORY / 'devil_0.tri'), 1, 4)

    triangle_slopes = tree_1.triangle_slopes
    triangle_slopes.print_stats()


def test_triangle_aspects():
    tree_1 = PointRegionTree.from_file(str(INPUT_DIRECTORY / 'devil_0.tri'), 1, 4)

    triangle_aspects = tree_1.triangle_aspects
    triangle_aspects.print_stats()
