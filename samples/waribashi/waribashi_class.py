from graphviz import Digraph


class State:
    def __init__(self, is_first, f, s):
        self.is_first = is_first
        self.f = [max(f), min(f)]
        self.s = [max(s), min(s)]

    def params(self):
        return (self.is_first, self.f, self.s)

    def __eq__(self, other):
        return self.params() == other.params()

    def __str__(self):
        s = str(self.f) + "\n" + str(self.s)
        if self.is_first:
            return "f\n" + s
        else:
            return "s\n" + s

    def __hash__(self):
        return hash(str(self))

    def is_impossible(self, fi, si):
        return self.f[fi] == 0 or self.s[si] == 0

    def next_state(self, fi, si):
        d = self.f[fi] + self.s[si]
        f2 = self.f.copy()
        s2 = self.s.copy()
        if d >= 5:
            d = 0
        if self.is_first:
            s2[si] = d
        else:
            f2[fi] = d
        return State(not self.is_first, f2, s2)


def move(state1, fi, si, nodes, edges, is_first):
    if state1.is_impossible(fi, si):
        return
    state2 = state1.next_state(fi, si)
    if state2 not in nodes:
        nodes[state2] = len(nodes)
    i1 = nodes[state1]
    i2 = nodes[state2]
    if (i1, i2) not in edges:
        edges.append((i1, i2))
    move(state2, 0, 0, nodes, edges, not is_first)
    move(state2, 0, 1, nodes, edges, not is_first)
    move(state2, 1, 0, nodes, edges, not is_first)
    move(state2, 1, 1, nodes, edges, not is_first)


def main():
    nodes = {}
    edges = []
    state1 = State(True, [1, 1], [1, 1])
    nodes[state1] = 0
    move(state1, 0, 0, nodes, edges, True)
    g = Digraph(format="png")
    for n in nodes:
        g.node(str(nodes[n]), str(n))
    for (i1, i2) in edges:
        g.edge(str(i1), str(i2))
    g.render("test")
    return


main()
