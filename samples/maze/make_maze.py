import random


def show_maze_debug(maze, cluster_index):
    m = len(maze)//2
    n = len(maze[0])//2
    for r in range(m):
        for c in range(n):
            i = c + r * n
            maze[2*r+1][2*c+1] = get_cluster_index(i, cluster_index)
    for row in maze:
        print("".join([str(i) for i in row]))


def show_maze(maze):
    for row in maze:
        print("".join(row))


def get_cluster_index(i, cluster_index):
    while cluster_index[i] != i:
        i = cluster_index[i]
    return i


def connect(ci, cj, cluster_index):
    if ci > cj:
        ci, cj = cj, ci
    cluster_index[cj] = ci


def break_wall(w, n, cluster_index, maze):
    ri, ci, rj, cj = w
    i = ci + ri * n
    j = cj + rj * n
    cli = get_cluster_index(i, cluster_index)
    clj = get_cluster_index(j, cluster_index)
    if cli == clj:
        return
    connect(cli, clj, cluster_index)
    if ci == cj:
        # 縦の壁を壊す
        maze[ri*2+2][ci*2+1] = ' '
    else:
        # 横の壁を壊す
        maze[ri*2+1][ci*2+2] = ' '


def check_finish(cluster_index):
    """
    終了判定
    すべての壁が同じクラスター番号になったら壁の破壊をやめる
    """
    for i in range(len(cluster_index)):
        if get_cluster_index(i, cluster_index) != 0:
            return False
    return True


def make_maze(m, n):
    """
    迷路の作成ルーチン
    m行n列の迷路を作る
    """
    maze = [['*']*(2*n+1) for i in range(2*m+1)]
    walls = []
    for r in range(m):
        for c in range(n):
            maze[2*r+1][2*c+1] = ' '
            if r != m-1:
                walls.append([r, c, r+1, c])
            if c != n-1:
                walls.append([r, c, r, c+1])
    cluster_index = [i for i in range(m*n)]
    random.shuffle(walls)
    for w in walls:
        break_wall(w, n, cluster_index, maze)
        if check_finish(cluster_index):
            break

    maze[2*m-1][1] = 'S'
    maze[1][2*n-1] = 'G'
    show_maze(maze)


make_maze(10, 20)
