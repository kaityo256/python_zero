import ast
import sys

from graphviz import Digraph


def visit(node, nodes, pindex, g):
    name = str(type(node).__name__)
    index = len(nodes)
    nodes.append(index)
    g.node(str(index), name)
    if index != pindex:
        g.edge(str(index), str(pindex))
    for n in ast.iter_child_nodes(node):
        visit(n, nodes, index, g)


filename = sys.argv[0]
if len(sys.argv) > 1:
    filename = sys.argv[1]

with open(filename) as f:
    graph = Digraph(format="png")
    tree = ast.parse(f.read())
    visit(tree, [], 0, graph)
    graph.render("test")
