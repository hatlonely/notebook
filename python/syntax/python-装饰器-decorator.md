# python 装饰器 decorator

装饰器模式是软件设计模式中的一种，它将函数包装起来，然后返回一个新的函数，新的函数可以扩展函数的功能，也可以调用原来的函数，从而达到装饰的目的。

python 中提供了装饰器的语法糖，只要在函数的定义处加上 @decorator，就可以使用装饰器了，非常方便。

## 简单装饰器

```python
def simple_decorator(func):
    def wrapper():
        print('Before call')
        func()
        print('After call')

    return wrapper


def test_simple_decorator():
    def hello():
        print('Hello world')

    hello = simple_decorator(hello)
    hello()
    print('Done')
```

上面这段代码是装饰器的基本原理，定义一个装饰器，在调用前后执行一些额外的输出。在实际函数调用处，使用装饰器包装函数（`simple_decorator(hello)`）
从而使得对 `hello` 的调用会被装饰器拦截，从而执行装饰器中的代码。

但是这种方式在每次调用函数时都需要手动包装一次，这样就失去了装饰器的意义了，所以 python 提供了语法糖来简化装饰器的使用。
只需要像下面的代码一样，在函数定义处加上 `@simple_decorator` 就可以了。

```python
def test_simple_decorator2():
    @simple_decorator
    def hello():
        print('Hello world')

    hello()
    print('Done')
```

## 带参数的装饰器

装饰器也可以有自己的参数，这样就可以根据参数的不同，对函数进行不同的装饰。

比如重试这个场景，可能会有不同的重试次数和重试间隔，这时候就可以使用带参数的装饰器。

```python
def retry(times=3, delay=0.1):
    def decorator(func):
        def wrapper(*args, **kwargs):
            for i in range(times):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    print("retry {}".format(i), e)
                    time.sleep(delay)

        return wrapper

    return decorator


def test_retry():
    @retry(times=5, delay=0.05)
    def hello():
        print('Hello world')
        raise Exception('Timeout')

    hello()
```

## 参考链接

- [stackoverflow decorators-with-parameters](https://stackoverflow.com/questions/5929107/decorators-with-parameters)
- [Primer on Python Decorators](https://realpython.com/primer-on-python-decorators/)
