import pickle

with open('saizeriya.pickle', 'rb') as f:
    names, prices, cals = pickle.load(f)

print(names)

