July 1, 2017

Clarification: This is about the Q-tools (server, cli etc.) and not about our primary ongoing Q-library work.
 
I’ve done some major changes to the libraries used, and small change in design that may help with future feature-scale. This is in branch sri-qtool2; I’ve sent pull request for it.
 
Indrajeet: We’ll need to add the dependencies mentioned in corresponding section below to our env-scripts; can you please check that?
 
Ramesh/Indrajeet: Could you please take a look at http://25thandclement.com/~william/projects/cqueues.pdf which is the core library on which the server is based; need your evaluation and also good to understand all capabilities of a tool we’re using.
 
Notes:
-          Q_TOOL is deprecated; contents of this folder is still running, but it now to be regarded replaced by the new stuff below
-          Q_HTTP: Runs basic http-server; cd to this folder and run q-srv.sh (take optional port as argument)
-          Q_REPL:  a cli which can run standalone, or act as a client to remote-q-server; cd to this folder and run q-cli.sh (takes host/port as optional arguments)
-          Q_HTTP/index.html: Directly open this file in a browser. Add host,port as query parameters in the url and it will redirect all commands to that q-server. For example on my machine, this is the url in my browser
file:///home/srinath/Ramesh/Q/Q_HTTP/index.html?host=localhost&port=3000  
                This is just a POC of what can be accomplished if we have a web-server that talks to our q-server above
 
Dependencies:
-          Q_HTTP depends on lua-http (which uses cqueues underneath)
o   It seems to require m4 and libssl-dev that I installed on Ubuntu using apt
o   sudo luarocks install http
-          Q_REPL depends on lua-linenoise; needs to be checked-out and built
o   git clone https://github.com/hoelzro/lua-linenoise.git
o   luarocks make
 
Code-structure:
-          Q_HTTP and Q_REPL (also deprecated Q_TOOL) belong outside Q folder/repo; Ramesh/Indrajeet: can you please create appropriate structure and give access accordingly?
 
I request you to start using at least Q_REPL asap; it is much more convenient (has history with up/down arrows, stores history in a .q_history file). I do think error cases may not be handled well at this point (haven’t put much time into that), and feedback will help improve.
 
Pending impl: Multi-line input in the REPL should be supported likely
 
Pending clarity: How global Lua variables are modified in presence of multiple concurrent threads/clients – needs some concurrency testing, and theoretical clarity on cqueues library.
 
Thanks,
Srinath.
