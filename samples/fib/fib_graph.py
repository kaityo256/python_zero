from graphviz import Digraph


def fib(n, g, nodes, parent=None):
    index = str(len(nodes))
    nodes.append(index)
    g.node(index, str(n))

    if parent is not None:
        g.edge(index, parent)

    if n in (0, 1):
        return
    fib(n-1, g, nodes, index)
    fib(n-2, g, nodes, index)


graph = Digraph(format="png")
fib(6, graph, [])
graph.graph_attr.update(size="10,10")
graph.render("test")
