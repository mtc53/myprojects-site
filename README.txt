MYPROJECTS.CC
=============

Everything the server needs, in one folder. Copy this whole folder to the
machine (C:\myprojects is a good spot) and double-click run.bat.

    run.bat          starts everything - the only thing you touch
    Caddyfile        which address goes where, and the password
    site\            the front page          -> myprojects.cc
    lol\             League Vault publishes here -> lol.myprojects.cc
    warroom\         the War Room            -> rok.myprojects.cc
    caddy.exe        put it here (or C:\Caddy\, or on PATH)

Caddy answers on 80 and 443 and hands each address to the right place. The
War Room runs on 127.0.0.1:8081, reachable only through Caddy.


FIRST TIME
----------
1. Put caddy.exe in this folder.
   https://caddyserver.com/download  - Windows, amd64.

2. Set the password. Run this and type the password you want twice:

       caddy.exe hash-password

   Copy the line it prints and paste it into Caddyfile, replacing
   REPLACE_WITH_HASH. Keep the word "user" in front of it.

3. Bring your existing War Room data across. From C:\WarRoom copy into
   warroom\ :

       state.json      every week and setting - the actual data
       password.txt    the password for editing the rankings
       .secret         keeps logins working across a restart
       uploads\        the archived spreadsheets
       backups\        the last ten saves

   Without state.json the site starts empty.

4. Stop the old setup so the ports are free:
   - close the old C:\WarRoom start.bat window
   - if Caddy is installed as a service:   sc stop caddy

5. In Cloudflare, point these at the server, all DNS only (grey cloud):

       @      154.3.224.22
       lol    154.3.224.22
       rok    154.3.224.22

6. On the Mac, League Vault > Settings > Your server: publish into
   this folder's lol\ (for example  C:\myprojects\lol ).

7. Double-click run.bat and leave the window open.

Certificates take a minute the first time. Caddy gets them itself and
renews them on its own, so win-acme is no longer needed - you can cancel
its renewal tasks and delete the .pem files from C:\WarRoom.


EVERY DAY
---------
Double-click run.bat. Closing that window stops both the War Room and
Caddy. Anything the War Room prints goes to warroom\server.log.


TWO PASSWORDS
-------------
Caddy asks for one to let you in at all. The War Room then asks for its
own before it will let you change the rankings - that one lives in
warroom\password.txt. They can be the same, or you can delete
warroom\password.txt and let Caddy's be the only one.


UPDATING THE WAR ROOM
---------------------
When the project changes, rebuild and copy the new files in:

    python webapp\build.py

then copy selfhost\index.html, server.py, check.py, check.bat and
README.txt into warroom\. Never copy state.json, password.txt, .secret,
uploads\ or backups\ over - those are the live data.


IF SOMETHING IS WRONG
---------------------
run.bat checks the obvious things first and says which one failed. Beyond
that:

    caddy.exe validate --config Caddyfile     is the config sane
    warroom\check.bat                         is the War Room reachable

The usual causes are the old War Room still holding port 80, a Caddy
service running alongside this one, or the Caddyfile still saying
REPLACE_WITH_HASH.
