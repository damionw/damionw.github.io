<section id="ISO_DATE" class="blog-entry">

<a class="jumpto" name="ISO_DATE"></a>

<header class="post-header">
    <span class="post-meta">
        <time datetime="ISO_DATE">
            LONG_DATE
        </time>
    </span>

    <h2 class="post-title">Python Decorator Fun #1</h2>
</header>

            <p>
Given the title's attached serial number, it would seem like this would
portend an ongoing saga of python decorators ad nauseam. However, I promise
not to bore you to tears (well, almost)
            </p>
            <p>
The intent of this post and any to follow are to demonstrate interesting
and possibly helpful applications of decorator logic, where decorators
themselves promise simpler, more fathomable code.
            </p>
            <p>
Did you ever wish that you could access an object member like it was an
array, but "catch" the subscript and produce a result algorithmically
instead ?
            </p>
Well, have no fear. We will present an interface for just such a beast: The
subscripted decorator.
            <p>
            </p>
We can jump right to a provoking use case. Here we instantiate our demo
object, which is pretending to "hold" a range of numbers from 5 to 11
<pre>
<code>
obj = MyRangeHandler(5, 12)
</code>
</pre>

Let's look at the simple values
<pre>
<code>
print obj.values

[5, 6, 7, 8, 9, 10, 11]
</code>
</pre>
            <p>
So let's get the square of the value at position 2 (7)
<pre>
<code>
print obj.squares[2]

49
</code>
</pre>
            </p>
            <p>
Get it ? However, we don't have to store the square values ahead of time, we can
compute them based on the index passed on the original values
            </p>
            <p>
So, let's see how this is implemented...
            </p>
            <p>
First, we'll need functools
<pre>
<code>
from functools import wraps
</code>
</pre>
            </p>

<p>
We'll define a function that'll produce our decorated method
<pre>
<code>
def subscripted(function_reference):
</code>
</pre>
            <p>
This needs to return a wrapped inner function...
<pre>
<code>
    @wraps(function_reference)
    def wrapper(obj, *args, **kwargs):
</code>
</pre>
            </p>
            <p>
Inside that, we define a class whose sole purpose is to implement
the subscripting protocol's lookup method __getitem__()
<pre>
<code>
        class subscripter(object):
            def __getitem__(self, key):
                return function_reference(obj, key)
</code>
</pre>
            </p>
            <p>
Notice that all it does is call the original object method with the
lookup key that the wrapper caller provided. Now we tell the wrapper to return
an instance of the newly defined class, which has captured the outer
object's reference.
<pre>
<code>
        return subscripter()
</code>
</pre>
            </p>
            <p>
And, we have the decorator method return the wrapper as a property of
of the enclosing object, so it will fetch a new subscripter object
whenever we use the . accessor on the decorated method name.
<pre>
<code>
    return property(wrapper)
</code>
</pre>

<p>
Now, we can create our MyRangeHandler class
<pre>
<code>
class MyRangeHandler(object):
    def __init__(self, start, finish):
        self.values = range(start, finish, 1)
</code>
</pre>
</p>

<p>
And let's implement the squared attribute...
<pre>
<code>
    @subscripted
    def squared(self, index):
        return self.values[index] ** 2
</code>
</pre>
</p>

<p>
    And that's it. This use case can obviously be handled using
normal function-style decomposition or simply storing all computable
values. But, there may be cases where subscript lookup is more "natural"
and precomputation is too expensive.
</p>

<p>
This example doesn't allow for fetching all of the square values, however,
since the subscripter class doesn't support slicing, and isn't a "proper"
standin for a list object in any case.
</p>

<p>
Hope you found that useful !
</p>
</section>