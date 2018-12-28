from graphviz import Digraph


def collatz(i, edges):
    while i != 1:
        j = i
        if i % 2 == 0:
            i = i // 2
        else:
            i = i * 3 + 1
        edges.add((j, i))


def make_graph(n):
    g = Digraph(format='png')
    edges = set()
    for i in range(1, n):
        collatz(i, edges)
    for i, j in edges:
        g.edge(str(i), str(j))
    g.render("test")


make_graph(26)
