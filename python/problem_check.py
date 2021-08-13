##Программа для эмпирической проверки выполнения задания. Выдаёт долю полученных нулей, единиц, двоек на миллион вызовов random3()
##Библиотека random использовалась для создания функции random2(), которая по условия считается данной

import random


def random2():
    return random.randint(0, 1)


def random3():
    s = 2 * random2() + random2()
    while s == 3:
        s = 2 * random2() + random2()
    return s


n = 10**6
zeros = ones = twos = 0

for i in range(n):
    s = random3()

    if s == 0:
        zeros += 1
    else:
        if s == 1:
            ones += 1
        else:
            if s == 2:
                twos += 1

print("zeros: ", zeros / n)
print("ones : ", ones / n)
print("two's: ", twos / n)
