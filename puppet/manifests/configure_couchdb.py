
# Author: Roman Domnich ( workaddr [ at ] yahoo.de )

from ConfigParser import SafeConfigParser


COUCHDB_INI = '/etc/couchdb/local.ini'


c = SafeConfigParser()
c.optionxform = lambda option: option


c.read(COUCHDB_INI)

c.set('httpd', 'bind_address', '0.0.0.0')


f = open(COUCHDB_INI, 'w')

c.write(f)

f.close()
