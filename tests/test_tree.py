from Terrain_Trees import PRT_Tree

from tests import INPUT_DIRECTORY


def test_pr_tree():
    tree_1 = PRT_Tree(1, 4)
    tree_2 = PRT_Tree.from_file(str(INPUT_DIRECTORY / 'devil_0.tri'), 1, 4)

    print('done')
