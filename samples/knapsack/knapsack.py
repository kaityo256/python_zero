from graphviz import Digraph



g = Digraph(format='png')


def func(data, mydata, pindex, nodes, total):
    if total > 10:
        return
    name = str(mydata) + str(total)
    index = len(nodes)
    nodes.append(index)
    g.node(str(index), name)
    g.edge(str(pindex), str(index))
    if not data:
        print(mydata)
        return
    a = data.pop(0)
    for add in (True, False):
        m = mydata.copy()
        mytotal = total
        if add:
            m.append(a[0])
            mytotal = mytotal + a[1]
        func(data.copy(), m, index, nodes, mytotal)


d = [("A", 5), ("B", 4), ("C", 3), ("D", 3)]
func(d, [], 0, [], 0)

g.graph_attr.update(ratio="0.6")
g.render("test")
