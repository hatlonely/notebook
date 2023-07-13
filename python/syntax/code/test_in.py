from dataclasses import dataclass


@dataclass
class Point:
    x: int
    y: int


class Point1(Point):
    def __init__(self, point):
        super().__init__(x=point.x, y=point.y)

    def __hash__(self):
        return hash(self.x) + hash(self.y)

    def __eq__(self, other):
        return self.x == other.x and self.y == other.y


def test_object_in1():
    l1 = [
        Point(x=1, y=1),
        Point(x=2, y=2),
        Point(x=3, y=3),
    ]

    l2 = [
        Point(x=2, y=2),
        Point(x=3, y=3),
    ]

    assert set([Point1(x) for x in l1]) >= set([Point1(x) for x in l2])


@dataclass
class Point2:
    x: int
    y: int

    def __hash__(self):
        return hash(self.x) + hash(self.y)

    def __eq__(self, other):
        return self.x == other.x and self.y == other.y


def test_object_in2():
    l1 = [
        Point2(x=1, y=1),
        Point2(x=2, y=2),
        Point2(x=3, y=3),
    ]

    l2 = [
        Point2(x=2, y=2),
        Point2(x=3, y=3),
    ]

    assert set(l1) >= set(l2)


def test_set_in():
    l1 = {1, 2, 3}
    l2 = {2, 3}
    assert l1 >= l2
