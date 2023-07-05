import numpy as np
import pandas as pd
import pandas.core.indexes.range


def test_series_1():
    series = pd.Series([1, 3, 5, 7, 6, 8])
    assert series[0] == 1
    assert series[1] == 3
    assert series[2] == 5
    assert series[3:5].tolist() == [7, 6]
    assert series[3:5].equals(pd.Series([7, 6], index=[3, 4]))

    assert isinstance(series.index, pandas.core.indexes.range.RangeIndex)
    assert series.index.start == 0
    assert series.index.stop == 6
    assert series.index.step == 1
    assert series.index.dtype == np.dtype('int64')

    assert isinstance(series.values, np.ndarray)
    assert series.values.dtype == np.dtype('int64')

    assert series.tolist() == [1, 3, 5, 7, 6, 8]


def test_series_2():
    series = pd.Series([1, 3, 5, 7, 6, 8], index=['a', 'b', 'c', 'd', 'e', 'f'])
    assert series['a'] == 1
    assert series['b'] == 3

    assert isinstance(series.index, pd.core.indexes.base.Index)
    assert series.index.tolist() == ['a', 'b', 'c', 'd', 'e', 'f']

    assert isinstance(series.values, np.ndarray)
    assert series.values.dtype == np.dtype('int64')

    assert series.tolist() == [1, 3, 5, 7, 6, 8]


def test_series_3():
    s1 = pd.Series({'a': 1, 'b': 3, 'c': 5, 'd': 7, 'e': 6, 'f': 8})
    s2 = pd.Series([1, 3, 5, 7, 6, 8], index=['a', 'b', 'c', 'd', 'e', 'f'])
    assert s1.index.equals(s2.index)
    assert s1.equals(s2)

    s3 = pd.Series(6, index=['a', 'b', 'c', 'd', 'e', 'f'])
    s4 = pd.Series([6, 6, 6, 6, 6, 6], index=['a', 'b', 'c', 'd', 'e', 'f'])
    assert s3.index.equals(s4.index)
    assert s3.equals(s4)


def test_series_4():
    series = pd.Series([1, 3, 5, 7, 6, 8])
    assert series.mean() == 5
    assert series.max() == 8
    assert series.min() == 1
    assert series.sum() == 30
    assert series.count() == 6
    assert series.median() == 5.5
