PI = 3.14159


def circle_area(radius: float) -> float:
    area = PI * radius * radius
    return area


def factorial(n: int) -> int:
    result = 1
    i = 1
    while i <= n:
        result = result * i
        i = i + 1
    return result


numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]
squares = []

for num in numbers:
    sq = num * num
    squares.append(sq)

print("Список квадратов:")
for s in squares:
    print(s, end=" ")
print()

# Работа со строками.
text = "Транслятор Python в C++"
length = len(text)
print("Длина текста:", length)

if length > 20:
    print("Длинная строка")
elif length == 20:
    print("Строка средней длины")
else:
    print("Короткая строка")
