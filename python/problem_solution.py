def random3():
    s = 2 * random2() + random2()
    while s == 3:
        s = 2 * random2() + random2()
    return s
