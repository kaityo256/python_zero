from graphviz import Digraph


class State:
    def __init__(self, is_first, f, s):
        self.is_first = is_first
        self.f = [max(f), min(f)]
        self.s = [max(s), min(s)]
        self.siblings = []
        self.is_drawn = False

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


def move(parent, index, is_first, nodes):
    fi, si = index
    if parent.is_impossible(fi, si):
        return
    child = parent.next_state(fi, si)

    if child in parent.siblings:
        return
    s = str(child)
    if s in nodes:
        child = nodes[s]
    else:
        nodes[s] = child
    parent.siblings.append(child)
    for i in [(0, 0), (0, 1), (1, 0), (1, 1)]:
        move(child, i, not is_first, nodes)


def make_tree():
    nodes = {}
    root = State(True, [1, 1], [1, 1])
    nodes[str(root)] = root
    move(root, (0, 0), True, nodes)
    return root


def make_graph(node, g):
    if node.is_drawn:
        return
    node.is_drawn = True
    for n in node.siblings:
        g.edge(str(node), str(n))
        make_graph(n, g)


root = make_tree()
g = Digraph(format="png")
make_graph(root, g)
g.render("tree")
