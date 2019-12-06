from graphviz import Digraph

#data = [("A", 5), ("B", 4), ("C", 3), ("D", 3)]


g = Digraph(format='png')


def func(data, mydata, pindex, nodes):
    name = str(mydata)
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
        if add:
            m.append(a)
        func(data.copy(), m, index, nodes)


func([1, 2, 3, 4], [], 0, [])

# g.graph_attr.update(size="10,10")
g.render("test")
