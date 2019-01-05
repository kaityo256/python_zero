from graphviz import Digraph


def state2str(f, s, isfirst):
    s = str(f) + "\n" + str(s)
    if isfirst:
        return "f\n" + s
    else:
        return "s\n" + s


def move(f1, s1, index, nodes, edges, is_first):
    fi, si = index
    if f1[fi] == 0 or s1[si] == 0:
        return
    f2 = f1.copy()
    s2 = s1.copy()
    d = f1[fi] + s1[si]
    if d >= 5:
        d = 0
    if is_first:
        s2[si] = d
    else:
        f2[fi] = d
    f2 = [max(f2), min(f2)]
    s2 = [max(s2), min(s2)]
    st1 = state2str(f1, s1, is_first)
    st2 = state2str(f2, s2, not is_first)
    i1 = nodes[st1]
    if st2 not in nodes:
        nodes[st2] = len(nodes)
    i2 = nodes[st2]
    if (i1, i2) not in edges:
        edges.append((i1, i2))
    for i in [(0, 0), (1, 0), (0, 1), (1, 1)]:
        move(f2, s2, i, nodes, edges, not is_first)


def make_tree():
    f = [1, 1]
    s = [1, 1]
    nodes = {}
    edges = []
    st = state2str(f, s, True)
    nodes[st] = 0
    move(f, s, (0, 0), nodes, edges, True)
    return nodes, edges


def main():
    nodes, edges = make_tree()
    g = Digraph(format="png")
    for k in nodes:
        g.node(str(nodes[k]), k)
    for (i1, i2) in edges:
        g.edge(str(i1), str(i2))
    g.render("test")


main()
