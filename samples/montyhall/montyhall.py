from random import choice, randint, seed


def keep(boxes):
    answer = choice(boxes)
    player_choice = choice(boxes)
    return player_choice == answer


def change(boxes):
    answer = choice(boxes)
    player_choice = choice(boxes)
    # プレイヤーが選んでなく、かつ答でもない箱のリスト
    boxes2 = list(filter(lambda x: x not in (player_choice, answer), boxes))
    # box2から司会者が開ける箱をランダムに選ぶ
    chair_choice = choice(boxes2)
    # プレイヤーは、自分が選んだものと、司会者が開けた箱以外から一つ箱を選ぶ
    boxes3 = list(filter(lambda x: x not in (player_choice, chair_choice), boxes))
    player_choice = choice(boxes3)
    return player_choice == answer


def calc_prob(n):
    k = 0  # Keep派の当たった回数
    c = 0  # Change派の当たった回数
    boxes = ["A", "B", "C"]
    for _ in range(n):
        if keep(boxes):
            k += 1
        if change(boxes):
            c += 1
    print("Keep  : " + str(k/n))
    print("Change: " + str(c/n))

seed(1)
calc_prob(1000)
