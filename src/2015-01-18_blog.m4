<section id="ISO_DATE" class="blog-entry">

<a class="jumpto" name="ISO_DATE"></a>

<header class="post-header">
    <span class="post-meta">
        <time datetime="ISO_DATE">
            LONG_DATE
        </time>
    </span>

    <h2 class="post-title">Python Decorator Fun #2 : Prototyped Functions</h2>
</header>

            <p>
Exposure to Erlang, as is common with any developer with multi language experience,
has caused me to wish for similar features that are otherwise absent from Python
            </p>
            <p>
But some are not so difficult to implement, and one of these is Erlang's function
signatures.
            </p>
            <p>
In short, Erlang functions are differentiated by the parameter types and their order,
like C++ for instance, but also can be differentiated by the values that some or all
of the parameters may have.
            </p>
            <p>
This is really cool, because it takes out a lot of value checking and comparisons in
what should otherwise be a 'clean' representation of the problem's solution. Indeed,
this is one of the goals of functional programming itself, which Erlang represents
and a metaphor which Python supports
            </p>
            <p>
Here is a simple Erlang case
<pre>
<code>
start_registered(ModuleName) ->
    start_registered(ModuleName, []).

start_registered(ModuleName, Arguments) ->
    start_registered(ModuleName, ModuleName, Arguments).

start_registered(RegisterName, ModuleName, Arguments) ->
    {ok, Pid} = start_link(ModuleName, Arguments),
    register(RegisterName, Pid),
    {ok, Pid}.
</code>
</pre>

We won't get into the weird Erlang syntax (for Pythonistas) but we are defining three
forms of the same function, start_registered.
</p><p>
<pre>
<code>
start_registered(ModuleName) ->
    start_registered(ModuleName, []).
</code>
</pre>
This form takes a single module name and calls the same function with that module
name followed by an empty parameter list
</p><p>
<pre>
<code>
start_registered(ModuleName, Arguments) ->
    start_registered(ModuleName, ModuleName, Arguments).
</code>
</pre>
This takes a module name and list of arguments, calling itself using the same module
name to register as a task, then the module name and the parameter list
</p><p>
</p><p>
<pre>
<code>
start_registered(ModuleName, Arguments) ->
    start_registered(ModuleName, ModuleName, Arguments).
</code>
</pre>
And this form has a name to register the task as its first parameter, the module name
followed by the list of arguments.
</p><p>
This kind of use saves having to define a single function that has to parse the intent
of the caller on whether to use defaults or not.
</p><p>
What's not shown is the ability for Erlang to also employ value checking on any of the
function parameters, called guards.
</p><p>
But Python has no strict typing and function parameters are really just managed as a list
of names with no sign of intent other than what names are used.
<pre>
<code>
def myfunction(name, address):
    pass
</code>
</pre>
</p><p>
What can we infer about the name and address parameters ? Nothing really, because we
can (obviously) call it this way...
<pre>
<code>
myfunction(0.2, AutomobileClass(None))
</code>
</pre>
... with no implications or penalties. It's up to myfunction to dynamically determine
if the parameters are correct in context

Of course, the fluid type handling of dynamic languages like Python are desired attributes
but, it's still nice to be able to have such features when you want them
</p>
<p>
What would this feature look like in Python ?

Since we can't really justify modifying the language, and this is a decorators tutorial,
we can try it with decorator logic !
<pre>
<code>
@prototype(one=int, two=int)
def myfunction(one=1, two=0):
    print "myfunction(int, int)", one, two

@prototype(one=(int, {1,2,3}))
def myfunction(one):
    print "myfunction(int=[1,2,3])", one

@prototype(one=int)
def myfunction(one):
    print "myfunction(int)", one
</code>
</pre>

We have three forms of myfunction(). One which takes two integers, named one and two.
The next takes a single integer named one, which can have values 1, 2, or 3. And the last
which takes a single integer of any value.
</p>
<p>
Calling these would have this effect
<pre>
<code>
>>> myfunction(one=10, two=7)

myfunction(int, int) 10 7

>>> myfunction(one=2)

myfunction(int=[1,2,3]) 2

>>> myfunction(one=99)

myfunction(int) 99
</code>
</pre>
</p>

<p>
Interested in seeing how such a thing might be implemented ? I thought so
</p>
<p>
We import some required modules
<pre>
<code>
from inspect import getargspec
from collections import OrderedDict
</code>
</pre>
We need getargspec() to interrogate the function parameters and
OrderedDict because the function parameter order is significant when
applying the type signature
</p>

<p>
We're implementing this decorator as a class because (1) we use the class
namespace to store a persistent function registry and (2) we use instantiated
objects to store the function's signature (temporarily)
<pre>
<code>
class prototype(object):
    _registry = {}

    def __init__(self, **prototype):
        self._prototype = prototype
</code>
</pre>
Each call to prototype(...) instantiates a new prototype object
</p>
<p>
This method lets us get a dictionary strictly mapping parameter names and their types
<pre>
<code>
    @staticmethod
    def get_type_spec(prototype):
        for _key, _type in prototype.iteritems():
            if type(_type) == type:
                yield _key, _type
            elif type(_type) == tuple:
                yield _key, _type[0]
            else:
                raise Exception("Type specification '%s' must be either a single type or a tuple" % (_key))
</code>
</pre>
</p>
<p>
This method lets us get a dictionary strictly mapping parameter names and the set of
permissible values
<pre>
<code>
    @staticmethod
    def get_value_spec(prototype):
        for _key, _type in prototype.iteritems():
            if type(_type) == type:
                yield _key, None
            else:
                yield _key, _type[1]
</code>
</pre>
</p><p>
Since we're using an object to implement the function decoration, we have to handle
the call with the function object as a parameter.
<pre>
<code>
    def __call__(self, fn):
</code>
</pre>
First, we make sure that the class function registry gets an entry for our function's
name
<pre>
<code>
        collection = self._registry.setdefault(fn.__name__, [])
</code>
</pre>
Then we craft a function definition recording the function object, its parameter
list, its type map and its permissible value map
<pre>
<code>
        signature_definition = [
            fn,
            getargspec(fn),
            dict(self.get_type_spec(self._prototype)),
            dict(self.get_value_spec(self._prototype)),
        ]
</code>
</pre>
And then record it in the collection for this function name
<pre>
<code>
        collection.append(signature_definition)
</code>
</pre>
Finally, we return a lambda that captures the function's name and will
call our static handler method with it.
This is what gets recorded as the decorated function.
<pre>
<code>
        return lambda *args, **kwargs: self.handler(fn.__name__, args, kwargs)
</code>
</pre>
</p><p>
The handler function is where the marshalling happens
<pre>
<code>
    @staticmethod
    def handler(name, args, kwargs):
</code>
</pre>
We must iterate through all of the function definitions recorded with
the same name, checking each one for candidacy.
<pre>
<code>
        for fn, spec, _prototype, _valuemap in prototype._registry[name]:
</code>
</pre>
We build a dictionary containing the parameter names and their default
values for the selected function instance.
<pre>
<code>
            instance_parameters = OrderedDict(
                zip(
                    spec.args,
                    [] if spec.defaults is None else spec.defaults,
                )
            )

</code>
</pre>
Then we update the dictionary with the positional parameters passed in the
current call attempt
<pre>
<code>
            instance_parameters.update(
                zip(
                    spec.args,
                    args,
                )
            )
</code>
</pre>
And then update the dictionary with the keyword arguments passed in the
current call attempt
<pre>
<code>
            instance_parameters.update(kwargs)
</code>
</pre>
Now, prepare a dictionary representing the signature of the current function
using the types of the parameters that were passed
<pre>
<code>
            instance_prototype = {
                _key: type(_value) for _key, _value in instance_parameters.iteritems()
            }
</code>
</pre>
If they don't match, this function is not the right candidate
<pre>
<code>
            if _prototype != instance_prototype:
                continue
</code>
</pre>
Iterate over the parameter values and see if the value specification for the
parameter is None (any value) or, if there is a collection, then determine if
the parameter is within the permissible values. As soon as function parameter
value is deemed inconsistent, then the loop is exited early. If the loop reaches
the end of the parameters without failing, then the function is called immediately
<pre>
<code>

            for key, value in instance_parameters.iteritems():
                permitted = _valuemap.get(key)

                if permitted is None or value in permitted:
                    continue

                # Found non permissible value
                break
            else:
                # All values were found to be permissible
                return fn(**instance_parameters)
</code>
</pre>
If no match is found, then the function, as called, is unimplemented
<pre>
<code>
        raise NotImplementedError("Function '%s' cannot be found with the expressed signature" % (name))
</code>
</pre>
The class can be immediately used at this point, so something like
<pre>
<code>
@prototype(a=float)
def myfunction(a):
    print "FLOAT", a
</code>
</pre>
is possible
</p>
<p>
I'm certain that there are ways to improve the (probably slow) function lookup method,
but, at the least, this benefits by 'hiding' the value and type comparisons that would
otherwise be done in plain view by a function that supported multiple call patterns
</p>
</p>
I hope you liked that !
<p>
</section>