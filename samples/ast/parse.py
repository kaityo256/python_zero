import ast
import sys

from graphviz import Digraph


def visit(node, parent, d, s):
    if isinstance(node, ast.Load):
        return
    d[node] = len(d)
    if parent:
        s.add((parent, node))
    for i in ast.iter_child_nodes(node):
        visit(i, node, d, s)


def draw(s, d):
    g = Digraph(format="png")
    for node in d:
        name = str(type(node).__name__)
        g.node(str(d[node]), name)
    for node, parent in s:
        node_id = d[node]
        parent_id = d[parent]
        g.edge(str(parent_id), str(node_id))
    g.render("test")


filename = sys.argv[0]
if len(sys.argv) > 1:
    filename = sys.argv[1]

with open(filename) as f:
    d = {}
    s = set()
    tree = ast.parse(f.read())
    visit(tree, None, d, s)
    draw(s, d)
