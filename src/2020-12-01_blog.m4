<section id="ISO_DATE" class="blog-entry">

<a class="jumpto" name="ISO_DATE"></a>

<header class="post-header">
    <span class="post-meta">
        <time datetime="ISO_DATE">
            LONG_DATE
        </time>
    </span>
    <h2 class="post-title">A Case for Modular Bash Applications</h2>
</header>

<header class="post-header">
    <h3>What were you thinking ???</h3>
</header>

<p>
As an old Unix developer (circa 1986), I've successfully written
and deployed mission critical applications and services using shell.
So, as a <i>proper</i> programming language, bash is even more adept
</p>

<p>
However, some of the drawbacks are difficult to ignore:

<ul>
<li>No Standard Library Concept</li>
<li>Arcane Syntax</li>
<li>Ambiguous Features</li>
<li>No Namespaces</li>
<li>Slow</li>

</ul>

Some of these concerns can be mitigated however...
</p>

<header class="post-header">
    <h3>File layout for a Bash Application</h3>
</header>

<p>
Historically, bash programs are single file affairs. Why? because there aren't
standardised expectations for deploying and importing application libraries.
</p>

<p>
Binary applications commonly deposit shareable objects in /usr/lib or /usr/local/lib.
Python package management, similarly, create and manage modules beneath /usr/local/lib/python-<version>.
Bash has no standard package management, but that doesn't mean we can't leverage standard library directories in
the same way
</p>

<header class="post-header">
    <h3>Flubber : A demo bash application</h3>
</header>

<p>
Let's call our test application flubber. Here's the on disk layout
</p>

<pre>
<code>
/usr
    /bin
        /flubber
    /lib
        /flubber-0.01
            /features

        /flubber
</code>
</pre>
<p>
/usr/bin/flubber is the program entry point. What does it do ?
</p>

<pre>
<code>
#!/usr/bin/env bash

# Locate the library path
binary_file="$(readlink -f "${BASH_SOURCE[0]}")"
binary_path="$(dirname "${binary_file}")"
binary_name="$(basename "${binary_file}")"
library_import_file="$(readlink -f "${path_path}/../lib/${binary_name}")"
</code>
</pre>
<p>
This preamble asserts that the library will be located relative to the binary, this time
in /usr/lib/flubber. Then, we import the library with
</p>

<pre>
<code>
. "${library_import_file}"
</code>
</pre>

<p>
This let's us divorce the binary from the library code. It also lets other entities, or
even an interactive session, import the library's namespace elements and functionality
directly. More on this later. For now, let's look at /usr/lib/flubber...
</p>

<pre>
<code>
#!/usr/bin/env bash

library_file="$(readlink -f "${BASH_SOURCE[0]}")"
library_path="$(dirname "${binary_file}")"
package_name="$(basename "${library_file}")"
</code>
</pre>

<p>
Similar file location behaviour as in the binary, but we're actually interested
in determining something else...
</p>

<pre>
<code>
export __FLUBBER_VERSION__="$(
    find "${library_path}/${package_name}"-[.0-9]* -maxdepth 0 -mindepth 0 -type d -printf "%f\n" |
    awk -F- '{print $NF;}' |
    sort -nr |
    head -1
)"
</code>
</pre>

<p>
... which is capturing the numbered subdirectories prefixed with the package name, in this case
there's only flubber-0.01. We then use that subdirectory to import the component modules.
</p>

<p>
There's only one: features.
</p>

<pre>
<code>
import_path="${local_path}/${package_name}-${__FLUBBER_VERSION__}"

. "${import_path}/features"
</code>
</pre>

<p>
After we import the components, for good measure, we refresh the namespace cache with hash -r
</p>

<pre>
<code>
hash -r
</code>
</pre>

<p>
The file /usr/local/lib/flubber-0.01/features provides functions specific to flubber features
</p>

<pre>
<code>
#!/usr/bin/env bash

flubber::features::construct() {
    echo "FLUBBER construction"
}
</code>
</pre>

<p>
We're only defining one function in this module, using namespace naming semantics
to forego collisions with other libraries or modules.
<br>
Bash, of course, doesn't care that we're using colons in its function names.
The point is, flubber will be able to call flubber::features::construct and we'll
understand what the function is and where its coming from
</p>

<header class="post-header">
    <h3>Using Flubber</h3>
</header>

<p>
Now we can finish off /usr/bin/flubber. We won't get into getopt based command line
options handling just yet (another post will cover that). However, we will accept a
single command line option
</p>

<pre>
<code>
case "$1" in
    --lib)
        echo "${library_import_file}"
        shift
        exit 0
        ;;
esac
</code>
</pre>

<p>
So, if we run flubber, we'll get the library import entry point
</p>
<pre>
<code>
$ flubber --lib

/usr/lib/flubber
</code>
</pre>

<p>
We can now import the namespace from the command line
</p>
<pre>
<code>
$ . $(flubber --lib)
$ flubber::features::construct

FLUBBER construction
</code>
</pre>

<p>
We can also endow the flubber application with the same capability, essentially
'exporting' the internal behaviour via the user interface. If we rewrite the case
statement to add another option --doit
</p>

<pre>
<code>
case "$1" in
    --lib)
        echo "${library_import_file}"
        shift
        exit 0
        ;;

    --doit)
        flubber::features::construct
        shift
        exit 0
        ;;
esac
</code>
</pre>

<p>
We can run it like this
</p>

<pre>
<code>
$ flubber --doit

FLUBBER construction
</code>
</pre>

<header class="post-header">
    <h3>What Next?</h3>
</header>
<p>
As mentioned, there's no getopt parameter handling here, but there is a pattern
(and a library) to handle that.
</p>

<p>
Adding features to flubber now consists of changing or adding files in /usr/lib/flubber-0.01
New versions should be exposed by renaming to or adding /usr/lib/flubber-0.0x
</p>

<p>
Makefiles for existing applications can be augmented to place components into
the appropriate directory layout and monolithic code blocks can then be reliably
refactored into discrete components.
</p>

<p>
A representative example of this pattern, which is also the library providing getopt
integration can be found here here: <a href=https://github.com/damionw/optionslib>https://github.com/damionw/optionslib</a>
</p>
</section>
