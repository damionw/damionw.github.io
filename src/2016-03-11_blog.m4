<section id="ISO_DATE" class="blog-entry">

<a class="jumpto" name="ISO_DATE"></a>

<header class="post-header">
    <span class="post-meta">
        <time datetime="ISO_DATE">
            LONG_DATE
        </time>
    </span>
    <h2 class="post-title">Reference Counted Process Group Supervision</h2>
</header>

<header class="post-header">
    <h3>The Provocation</h3>
</header>

<p>
Some months ago, in a flurry of frustration provoked coding, I implemented my
own email client. At some point, it'll make a blog post but, for now, suffice
it to say that my once torrid love affair with Kmail from KDE3 has ended with
the advent of KDE4. As an aside, it's sad that software projects can and do
reach perfection and then pass it by in their quests for relevance
</p>

<header class="post-header">
    <h3>Email Services</h3>
</header>

<p>
In the details of writing an email client are essentially 4 elements, which can
all be represented as separate services, though in mass market clients, they're
strangely all bundled into a single executable, binding them unnecessarily.
</p>

<p>
<table class="tableview">
<tr><td>Retrieval</td></tr>
<tr><td>Dispatching</td></tr>
<tr><td>Indexing</td></tr>
<tr><td>Viewing</td></tr>
</table>
</p>

<p>
In my case, I merged the Retrieval and Indexing into a single service, but I'm sure you get
the picture
</p>

<p>
The nature of email clients are that, typically, the user will start the email program just
after login, which is when any queued messages are sent, new messages are received, and the
UI is displayed with whatever viewing preferences the user last selected.
</p>

<p>
In my case, each separate service needed to be started, too, but with a difference. Since
the UI is only needed for me to view email, I don't need to start the UI then (more on that
later), but email collection and dispatching should start happening independently.
</p>

<p>
With the pattern that emerged, it became clear that email collection and dispatch were services
<i>linked to my login</i>. But which login ? I'm on linux where I could login via ssh and
conceivably want my email to start working. The keyboard and screen interface is only one
part of the user experience
</p>

<p>
So, it seemed that I needed a service 'group', consisting of three services:

<table class="tableview">
<tr><td>email_send</td></tr>
<tr><td>email_retrieval</td></tr>
<tr><td>webmail_service</td></tr>
</table>
</p>

<p>
The webmail service materialised after I decided not to use a Qt standalone UI and, instead,
implemented the client using a browser interface. The services are not interdependent in this
case, but they are connected by the common file structure and that they are subservient to
at <i>least one</i> active user login session.
</p>

<header class="post-header">
    <h3>Supervised Processes with Reference Counting</h3>
</header>

<p>
After this set of requirements became clear, I implemented a Bash script that, when invoked,
would test for the presence of a process group supervisor, which was responsible for ensuring
that the three services were alive and maintaining the list of dependent processes. If the
supervisor were not present, it would be started and then it would launch the three services.
</p>

<p>
The script would also inform the supervisor about the process id (PID) of the shell that invoked
it, adding it to the list of dependents. Subsequently, the running supervisor would delete
PID's from the list as the processes disappeared or when explicitly commanded to do so.
</p>

<p>
Once the list of dependents was empty, the supervisor would shutdown, after stopping its services
</p>

<p>
After running the suite for several months, it became apparent that this was the arrangement I'd
been missing the whole time! Indeed, I was provoked to add on other services, such as a notifier that
fades the incoming subject lines in and out on the screen independently of an active email client.
</p>

<header class="post-header">
    <h3>Chaining</h3>
</header>

<p>
Soon, it became obvious that what was needed was a general purpose tool, that would maintain arbitrary
process groups, utilising the same approach. So, after another flurry of viscious coding, I produced such
a tool which can be seen <a href="https://github.com/damionw/process-groups">here</a>
</p>

<p>
Normally, I'd show the code to implement this, but that's going to be a turnoff unless you're hot for Bash
code. No, what's more interesting is what's possible with reference counted process groups.
</p>

<p>
The process groups can be chained. Let's imagine that for a moment:
<br>
Each of the managed services in a process group can run the same Bash script and express interest in another
named group of services. Doing so introduces a managed group dependency, ensuring that, as long as the first
group is running, the other group will be running too.
</p>

<p>
And, as it turns out, this is exactly what happens when an init system runs, or supervisord, or any of the
other process supervision/startup frameworks. Except, this approach differs in that it does support a
dendritic dependency graph but does not attempt to do so from the top down. And, if any group is explicitly
stopped by pruning the dependencies, all of the groups that list it as a dependent will be stopped if that
is their only dependent.
describe the dependency
</p>

<p>
I'll stop there, before I start showing you any Bash, but I encourage you to play with the tool and explore
what can be done with these kinds of process groups.
</p>

</section>