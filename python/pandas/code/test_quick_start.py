import numpy as np
import pandas as pd
import pandas.core.indexes.range


def test_series_1():
    series = pd.Series([1, 3, 5, 7, 6, 8])
    assert series[0] == 1
    assert series[1] == 3
    assert series[2] == 5

    assert isinstance(series.index, pandas.core.indexes.range.RangeIndex)
    assert series.index.start == 0
    assert series.index.stop == 6
    assert series.index.step == 1
    assert series.index.dtype == np.dtype('int64')

    print(series.values)
    assert isinstance(series.values, np.ndarray)
    assert series.values.dtype == np.dtype('int64')

    print(series.tolist())
    assert series.tolist() == [1, 3, 5, 7, 6, 8]
