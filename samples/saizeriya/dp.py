from collections import defaultdict
import pickle

with open('saizeriya.pickle', 'rb') as f:
    names, prices, cals = pickle.load(f)

dic = defaultdict(int)


def search(n, budget):
    if n < 0:
        return 0
    if dic[(n, budget)] is not 0:
        return dic[(n, budget)]
    c1 = 0
    if prices[n] <= budget:
        c1 = cals[n] + search(n-1, budget - prices[n])
    c2 = search(n-1, budget)
    cmax = max(c1, c2)
    dic[(n, budget)] = cmax
    return cmax


def get_menu(budget, cal):
    menu = []
    for i in reversed(range(len(names))):
        if cal is 0:
            break
        if cal == cals[i] + dic[(i-1, budget-prices[i])]:
            cal -= cals[i]
            budget -= prices[i]
            menu.append(i)
    return menu


def show_menu(menu):
    for i in menu:
        print("{} {} Yen {} kcal".format(names[i], prices[i], cals[i]))
    total_price = sum(map(lambda x: prices[x], menu))
    total_cal = sum(map(lambda x: cals[x], menu))
    print("Total {} Yen {} kcal".format(total_price, total_cal))


def main():
    budget = 10000
    cal = search(113, budget)
    menu = get_menu(budget, cal)
    show_menu(menu)

if __name__ == '__main__':
    main()
