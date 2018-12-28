import ast

from graphviz import Digraph


def getname(node):
    return str(type(node).__name__)


def visit(node, parent, d, s):
    if isinstance(node, ast.Load):
        return
    d[node] = len(d)
    if parent:
        s.add((parent, node))
    for i in ast.iter_child_nodes(node):
        visit(i, node, d, s)


f = open("test.py")
src = f.read()
tree = ast.parse(src)

d = {}
s = set()
visit(tree, None, d, s)

g = Digraph(format="png")
for node in d:
    g.node(str(d[node]), getname(node))
for node, parent in s:
    node_id = d[node]
    parent_id = d[parent]
    g.edge(str(parent_id), str(node_id))
g.render("test")
