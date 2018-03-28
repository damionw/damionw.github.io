<section id="ISO_DATE" class="blog-entry">

<a class="jumpto" name="ISO_DATE"></a>

<header class="post-header">
    <span class="post-meta">
        <time datetime="ISO_DATE">
            LONG_DATE
        </time>
    </span>
    <h2 class="post-title">Shell Function keyword arguments</h2>
</header>

<header class="post-header">
    <h3>The Problem</h3>
</header>

<p>
    For those of you who might be unfamilar, BASH, or Bourne Again Shell, really is a complete
    programming language, replete with every facility you might want.
</p>
<p>
However, there are features it infuriatingly lacks that one might have experienced in other languages,
such as Erlang, Perl or Python
</p>
<p>
Having worked in Python constantly since 2008, I'm particular to amenities offered there, especially
when I'm using Bash as 'glue' to string together tools that are themselves written in Python.
</p>
<p>
To this end, one such feature is the ability in Python to specify function parameters either by keyword
or by position.
</p>
<p>
And, in a moment of heightened irritation, I had to have it...
</p>
<header class="post-header">
    <h3>What it looks like</h3>
</header>

<p>
Here's a python function with two parameters:
</p>
<pre>
<code>
def myfunc(one, two):
    print one
    print two
</code>
</pre>
<p>
We can call it many ways:
</p>
<pre>
<code>
myfunc(one=1, two=2)
myfunc(1, 2)
myfunc(1, two=2)
</code>
</pre>
<p>
Each invocation ensures that, within the body of myfunc(), variables one and two
are given the respective values 1 and 2
</p>

<header class="post-header">
    <h3>BASH Use Case</h3>
</header>
<p>
So, what would this look like in BASH?
</p>
<p>
We can't rely on BASH itself, which doesn't offer keyword parameters on its own. All it
knows about are positional parameters. However, they're all strings, so what if we passed
parameters that looked like this:
</p>
<pre>
<code>
myfunc "one=1" "two=2" 3 4
</code>
</pre>
<p>
Ok, so within the function, we have an arrangement where a positional string value could be in
a special form, where something like <identifier>= might be prepended
</p>
<pre>
<code>
$1="one=1"
$2="two=2"
$3="3"
$4="4"
</code>
</pre>
<p>
After that, we'd need to preprocess the argument list and evaluate all the values and populate
a keyword hash table, supported in Bash >= 4.0 (see <a ref="https://stackoverflow.com/questions/1494178/how-to-define-hash-tables-in-bash"></a>)
</p>
<pre>
<code>
eval "$(argument_formatter "$@")"
</code>
</pre>
<p>
Which would populate a hash table named kwargs and a positional array named args (internally managed in python)
</p>
<pre>
<code>
$ echo ${kwargs["one"]}

1

$ echo ${kwargs["two"]}

2

$ echo ${args[0]}

3

$ echo ${args[1]}

4
</code>
</pre>
<p>
Determining where/how to use mixed positional and keyword interpretations
</p>
<pre>
<code>
myfunc one=1 2
</code>
</pre>
<p>
Extracting the values could look like so...
</p>
<pre>
<code>
$ one=${kwargs["one"]:-${args[0]}}
$ two=${kwargs["two"]:-${args[1]}}
$ echo $one

1

$ echo $two

2
</code>
</pre>
<p>
...ensuring the kwarg is preferred, but the positional argument is used as the default
</p>
<header class="post-header">
    <h3>Implementation</h3>
</header>
<p>
But, how do we implement this feature. Glad you asked. Here, we're calling our function
this
</p>
<pre>
<code>
argument_formatter() {
...
}
</code>
</pre>
<p>
Inside, we first create separate arrays to hold the keyword and the
positional arguments as we parse them from the parameter list.
Note the difference in declaration styles.
</p>
<pre>
<code>
    local -A _keyword_args=()
    local -a _positional_args=()
</code>
</pre>

>p>
Then, let's loop through them, looking for entries of the form <identifier>=<value>. Those'll
be the keyword args, anything else is positional. We have to split the keywords from their values
so we can store them in the 
>/p>

<pre>
<code>
    for _parameter in "$@"
    do
        if (echo "${_parameter}" | grep -q '^[[:alpha:]][[:alnum:]]*[=]')
        then
            _key="$(echo "${_parameter}" | sed -e 's/=.*$//g')"
            _value="$(echo "${_parameter}" | sed -e 's/^[^=]*=//g')"
            _keyword_args["${_key}"]="${_value}"
        else
            _positional_args[${#_positional_args[@]}]="${_parameter}"
        fi
    done
</code>
</pre>

>p>
Then, since we're using eval, we just print out the bash source
required to create the kwargs in the target scope
>/p>

<pre>
<code>
    echo -n "local -A kwargs=("
    for _key in "${!_keyword_args[@]}"
    do
        echo -n " [\"${_key}\"]=\"$(echo "${_keyword_args["${_key}"]}" | sed -e 's/\"/\\\"/g')\""
    done
    echo " )"
</code>
</pre>

>p>
And, likewise, the source required to create the positional args in the target scope
>/p>

<pre>
<code>
    echo -n "local -a args=("
    for _value in "${_positional_args[@]}"
    do
        echo -n " \"$(echo "${_value}" | sed -e 's/\"/\\\"/g')\""
    done
    echo " )"
</code>
</pre>

>p>
That's it! Once eval'ed, the calling function will have the kwargs and args arrays
defined locally
>/p>

<p>
You can see the full implementation here: https://github.com/damionw/bashLib/blob/master/src/lib/bashLib-0.12/arguments
or clone https://github.com/damionw/bashLib and try it out from there.
</p>
<p>
I hope that was informative !
</p>
</section>