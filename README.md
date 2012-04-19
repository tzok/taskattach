taskattach
==========

Provides support for attachment management for Taskwarrior

You can easily add as many attachments as you want to any task. The application
allows also to select an attachment for opening. If it detects plaintext file,
it invokes an editor. Otherwise, a default handler is called.

Examples
--------

Please find a demonstration session below:

    $ task add Test
    Created task 10.
    $ taskattach 10 /tmp/document.pdf
    Annotating task 10 'Test'.
    Annotated 1 task.
    $ taskattach 10 ~/notes.txt
    Annotating task 10 'Test'.
    Annotated 1 task.
    $ taskattach 10 ~/new/notes.txt
    cp: overwrite '/home/tzok/.local/share/taskattach/c7aaf28a-a212-4590-9236-952044ebd178/test'?
    $ taskattach 10
    1) document.pdf
    2) notes.txt
    #? 

Some additional notes
---------------------

Files are kept in a location with conformance to XDG Base Directory
Specification, in a unique directory name (taken from Taskwarrior itself).

Each basename of attachment can occur only once per task. If you *really* need
to add `~/notes.txt` and `~/new/notes.txt`, please rename the second one. At
least temporarily.

Attachments are copies of the original files. This has a disadvantage of
wasting some disk space. On the other hand, if you work on document, you have
always the latest version already attached to the task.

TODO
----

A cleaning mechanism is missing (i.e. one cannot remove attachments, even those
of deleted/finished tasks)
