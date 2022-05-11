from functools import partial
from typing import Callable

from Terrain_Trees import Mesh, Node_V, PointRegionTree

from tests import INPUT_DIRECTORY


def depth_first_traversal(callable: Callable, node: Node_V, mesh: Mesh):
    if node.is_leaf:
        if node.is_indexing_vertices:
            callable(node)
    else:
        for child_index in range(0, 4):
            child = node.child(child_index)
            if child is not None:
                depth_first_traversal(callable, child, mesh)


def test_depth_first_traversal():
    tree = PointRegionTree.from_file(str(INPUT_DIRECTORY / 'devil_0.tri'), 1, 4)

    tree.reindex(False, False)

    vertices = []
    callable = lambda vertices, node: vertices.extend(range(node.first_index, node.last_index))
    callable = partial(callable, vertices)

    depth_first_traversal(callable, tree.root, tree.mesh)

    assert len(vertices) == 32100
