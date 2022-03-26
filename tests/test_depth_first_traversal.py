import Terrain_Trees


def depth_first_traversal(root: Terrain_Trees.Node_V, mesh: Terrain_Trees.Mesh):
    if root.is_leaf:
        if root.is_indexing_vertices:
            print(root.v_start)
            print(root.v_end)
            for vid in range(root.v_start, root.v_end):
                vertex = mesh.vertex(vid)
                for index in range(0, 3):
                    print(vertex.coordinate(index))
            vt = root.vertex_triangle_relations(mesh)
            print(vt)
    else:
        for i in range(0, 4):
            child = root.child(i)
            if child is not None:
                depth_first_traversal(child, mesh)


if __name__ == '__main__':
    tree = Terrain_Trees.PRT_Tree.from_file('data/devil_0.tri', 1, 4)

    # tree.leaf_blocks
    tree.reindex(False, False)

    depth_first_traversal(tree.root, tree._c_mesh)

    print('done')
