f = open('/etc/motd', 'a')

f.write("""
Welcome to the THMcards - Virtual Machine.

You can start or stop the app from the /vagrant - directory with

forever <command> app.js

, where <command> is either start or stop.
You will have to wait for a few seconds until the app is launched.

The app can then be accessed through http://<server-ip>:3000 .
[ Couchdb can be accessed through http://<host-server-ip>:5985 or
                                  http://<guest-server-ip>:5984. ]

Look at /vagrant/README.md for more details.

""")

f.close()