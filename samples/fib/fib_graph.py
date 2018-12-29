from graphviz import Digraph


def fib(n, parent, nodes, g):
    index = len(nodes)
    nodes.append(index)
    if n == 1:
        g.node(str(index), str(n), color="red")
    else:
        g.node(str(index), str(n))

    if parent is not None:
        g.edge(str(index), str(parent))
    if n in (0, 1):
        return
    fib(n-1, index, nodes, g)
    fib(n-2, index, nodes, g)


g = Digraph(format="png")
fib(6, None, [], g)
g.graph_attr.update(size="10,10")
g.render("test")
