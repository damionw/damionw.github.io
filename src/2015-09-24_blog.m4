<section id="ISO_DATE" class="blog-entry">

<a class="jumpto" name="ISO_DATE"></a>

<header class="post-header">
    <span class="post-meta">
        <time datetime="ISO_DATE">
            LONG_DATE
        </time>
    </span>

    <h2 class="post-title">Python Object Proxying</h2>
</header>

            <p>
I stumbled upon this <a href="http://code.activestate.com/recipes/496741-object-proxying/">recipe</a>
and couldn't resist applying it to a common problem: converting linear computations into
parallel tasks with asynchronous result delivery.
            </p>
            <p>
But, enough about that for a while. What we're really here for is a simple implementation and use case
for this delectable technique
            </p>
            <p>
This time, we'll dive right into the implementation. Here is the basic class, without any augmentation
<pre>
<code>
class BasicObjectProxy(object):
    __slots__ = ["_obj", "__weakref__"]

    def __init__(self, obj=None):
        object.__setattr__(self, "_obj", obj)

    #
    # proxying (special cases)
    #
    def __getattribute__(self, name):
        return getattr(object.__getattribute__(self, "_obj"), name)

    def __delattr__(self, name):
        delattr(object.__getattribute__(self, "_obj"), name)

    def __setattr__(self, name, value):
        setattr(object.__getattribute__(self, "_obj"), name, value)

    def __nonzero__(self):
        return bool(object.__getattribute__(self, "_obj"))

    def __str__(self):
        return str(object.__getattribute__(self, "_obj"))

    def __unicode__(self):
        return unicode(object.__getattribute__(self, "_obj"))

    def __repr__(self):
        return repr(object.__getattribute__(self, "_obj"))

    def _proxy_synchronise_(self):
        pass

    @classmethod
    def _create_class_proxy(cls, theclass):
        """creates a proxy for the given class"""

        def make_method(name):
            def method(self, *args, **kw):
                return getattr(object.__getattribute__(self, "_obj"), name)(*args, **kw)

            return method

        _proxied_accessor_methods = [
            '__abs__', '__add__', '__and__', '__call__', '__cmp__', '__coerce__',
            '__contains__', '__delitem__', '__delslice__', '__div__', '__divmod__',
            '__eq__', '__float__', '__floordiv__', '__ge__', '__getitem__',
            '__getslice__', '__gt__', '__hash__', '__hex__', '__iadd__', '__iand__',
            '__idiv__', '__idivmod__', '__ifloordiv__', '__ilshift__', '__imod__',
            '__imul__', '__int__', '__invert__', '__ior__', '__ipow__', '__irshift__',
            '__isub__', '__iter__', '__itruediv__', '__ixor__', '__le__', '__len__',
            '__long__', '__lshift__', '__lt__', '__mod__', '__mul__', '__ne__',
            '__neg__', '__oct__', '__or__', '__pos__', '__pow__', '__radd__',
            '__rand__', '__rdiv__', '__rdivmod__', '__reduce__', '__reduce_ex__',
            '__repr__', '__reversed__', '__rfloordiv__', '__rlshift__', '__rmod__',
            '__rmul__', '__ror__', '__rpow__', '__rrshift__', '__rshift__', '__rsub__',
            '__rtruediv__', '__rxor__', '__setitem__', '__setslice__', '__sub__',
            '__truediv__', '__xor__', 'next',
        ]

        return type(
            "%s(%s)" % (cls.__name__, theclass.__name__),
            (cls,),
            {
                _key: make_method(_key)
                for _key
                in _proxied_accessor_methods
                if hasattr(theclass, _key) and not hasattr(cls, _key)
            }
        )

    @classmethod
    def __new__(cls, obj, *args, **kwargs):
        proxied_type = obj.__class__

        try:
            cache = cls.__dict__["_class_proxy_cache"]
        except KeyError:
            cls._class_proxy_cache = cache = {}
        try:
            synthesized_class = cache[proxied_type]
        except KeyError:
            cache[proxied_type] = synthesized_class = cls._create_class_proxy(proxied_type)

        return object.__new__(synthesized_class)
</code>
</pre>
</p>
<p>
The entire trickery for BasicObjectProxy is contained in the overloaded __new__() and the class method _create_class_proxy()
</p>
<p>
new() uses the wrapped object type and calls _create_class_proxy() to produce a
new type that is built specifically to masquerade as the original type.
</p>
<p>
The artificial type (possibly cached) is used to
instantiate a new object, which is returned from the
'constructor'.
</p>
<p>
The wrapped object is then passed to __init__() where it is captured to provide
the underlying value for all of the proxy object's accessor methods.
</p>
<p>
_create_class_proxy() Iterates over a static list of possible attribute names,and
creates wrapper methods to implement each call that the wrapped type supports.
<br>
In this case, the wrapper methods jus return the underlying object, so the proxy
appears to be no different than the original object
</p>
<p>
So, now, we have a proxy class that can be used like so:
<pre>
<code>
>>> value = BasicObjectProxy(22)

>>> print value

22

>>> print type(value)

&lt;class '__main__.BasicObjectProxy(int)'&gt;

>>> print value + 11

33
</code>
</pre>
Not bad at all, but we want more...
</p>
<p>
What we <i>really</i> want is to intercept each accessor call, and substitute our own
sentinel before it.
</p>
<p>
To accomplish that, we have to do some work:
<pre>
<code>
class BasicObjectProxy(object):
    __slots__ = ["_obj", "__weakref__"]

    def __init__(self, obj=None):
        object.__setattr__(self, "_obj", obj)

    #
    # proxying (special cases)
    #
    def __getattribute__(self, name):
        object.__getattribute__(self, "_proxy_synchronise_")()
        return getattr(object.__getattribute__(self, "_obj"), name)

    def __delattr__(self, name):
        object.__getattribute__(self, "_proxy_synchronise_")()
        delattr(object.__getattribute__(self, "_obj"), name)

    def __setattr__(self, name, value):
        object.__getattribute__(self, "_proxy_synchronise_")()
        setattr(object.__getattribute__(self, "_obj"), name, value)

    def __nonzero__(self):
        object.__getattribute__(self, "_proxy_synchronise_")()
        return bool(object.__getattribute__(self, "_obj"))

    def __str__(self):
        object.__getattribute__(self, "_proxy_synchronise_")()
        return str(object.__getattribute__(self, "_obj"))

    def __unicode__(self):
        object.__getattribute__(self, "_proxy_synchronise_")()
        return unicode(object.__getattribute__(self, "_obj"))

    def __repr__(self):
        object.__getattribute__(self, "_proxy_synchronise_")()
        return repr(object.__getattribute__(self, "_obj"))

    def _proxy_synchronise_(self):
        pass

    @classmethod
    def _create_class_proxy(cls, theclass):
        """creates a proxy for the given class"""

        def make_method(name):
            def method(self, *args, **kw):
                object.__getattribute__(self, "_proxy_synchronise_")()
                return getattr(object.__getattribute__(self, "_obj"), name)(*args, **kw)

            return method

        _proxied_accessor_methods = [
            '__abs__', '__add__', '__and__', '__call__', '__cmp__', '__coerce__',
            '__contains__', '__delitem__', '__delslice__', '__div__', '__divmod__',
            '__eq__', '__float__', '__floordiv__', '__ge__', '__getitem__',
            '__getslice__', '__gt__', '__hash__', '__hex__', '__iadd__', '__iand__',
            '__idiv__', '__idivmod__', '__ifloordiv__', '__ilshift__', '__imod__',
            '__imul__', '__int__', '__invert__', '__ior__', '__ipow__', '__irshift__',
            '__isub__', '__iter__', '__itruediv__', '__ixor__', '__le__', '__len__',
            '__long__', '__lshift__', '__lt__', '__mod__', '__mul__', '__ne__',
            '__neg__', '__oct__', '__or__', '__pos__', '__pow__', '__radd__',
            '__rand__', '__rdiv__', '__rdivmod__', '__reduce__', '__reduce_ex__',
            '__repr__', '__reversed__', '__rfloordiv__', '__rlshift__', '__rmod__',
            '__rmul__', '__ror__', '__rpow__', '__rrshift__', '__rshift__', '__rsub__',
            '__rtruediv__', '__rxor__', '__setitem__', '__setslice__', '__sub__',
            '__truediv__', '__xor__', 'next',
        ]

        return type(
            "%s(%s)" % (cls.__name__, theclass.__name__),
            (cls,),
            {
                _key: make_method(_key)
                for _key
                in _proxied_accessor_methods
                if hasattr(theclass, _key) and not hasattr(cls, _key)
            }
        )

    @classmethod
    def _allocator(cls, proxied_type):
        try:
            cache = cls.__dict__["_class_proxy_cache"]
        except KeyError:
            cls._class_proxy_cache = cache = {}
        try:
            synthesized_class = cache[proxied_type]
        except KeyError:
            cache[proxied_type] = synthesized_class = cls._create_class_proxy(proxied_type)

        return object.__new__(synthesized_class)

    def __new__(cls, obj, *args, **kwargs):
        return cls._allocator(obj.__class__)
</code>
</pre>
</p>
<p>
Not too much has changed.
</p>
<p>
First, we instituted a call to a method named _proxy_synchronise_()
whenever one of the accessor methods is called.
</p>
<p>
Because we can't trust the object's symbol table anymore, we have to call object.__getattribute__()
every time we want a 'real' proxy object attribute.
</p>
<p>
In this class, we don't bother endow _proxy_synchronise_() with any functionality, since we
aim to subclass from it
</p>
<p>
We've also separated the __new__() from the wrapper class synthesis, which is now held
in class method _allocator()
</p>
<p>
So, with the new base class implementing the 'guts' of the proxying work, we can do anything
we want in a derived class...
<pre>
<code>
def ProxyObjectFactory(proxied_type, value_callback):
    class _Internal(BasicObjectProxy):
        def __new__(cls, *args, **kwargs):
            return cls._allocator(proxied_type)

        def __init__(self, initial_value):
            super(_Internal, self).__init__()

            if type(initial_value) == proxied_type:
                object.__setattr__(self, "_obj", initial_value)

        def _proxy_synchronise_(self):
            previous_value = object.__getattribute__(self, "_obj")
            object.__setattr__(self, "_obj", value_callback(previous_value))

    return _Internal
</code>
</pre>
Of course, we're doing more than just subclassing, but to what end ?
</p>
<p>
Well, we want to be able to create classes which wrap functions and then use
those classes to create any number of objects, using the same underlying function
<br>
To that end, the ProxyObjectFactory needs a type to masquerade and a function
which it then uses instead of getting the target type <i>and</i> the underlying
value from the wrapped object used in the original implementation.
</p>
<p>
As we can see, _proxy_synchronise_() is overloaded to fetch a value using the
provided callback method. In this case,the previously held wrapped value is passed
into it. That new value is then used to replace the wrapped value
</p>
<p>
Now we can synthesize a new wrapper type...
<pre>
<code>
>>> IntegerFunctionProxy = ProxyObjectFactory(int, lambda previous: previous * 2)
</code>
</pre>
implementing the interface for the int type and a function to multiply the previous
value by 2.
<br>
We make a wrapped instance this way, storing the initial value 1...
<pre>
<code>
>>> value = IntegerFunctionProxy(1)
</code>
</pre>
We can probe the proxy's values, which continue to double per the underlying function
<pre>
<code>
>>> print value

2

>>> print value

4

>>> print value

8

>>> print value + 7

23
</code>
</pre>
I think you get the idea
</p>
<p>
The callback in this case could be any function that takes and int and returns
an int.
</p>
<p>
One can already see that using a function to initiate an asynchronous request
and letting the proxy object marshall the return value could be trivial...
<br>
...well, almost trivial
</p>
<p>
I hope that was entertaining. Until next time ...
</p>
</section>