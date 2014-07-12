from configparser import ConfigParser


COUCHDB_INI = '/etc/couchdb/local.ini'


c = ConfigParser(interpolation=None)
c.optionxform = lambda option: option


c.read(COUCHDB_INI)

c['httpd']['bind_address'] = '0.0.0.0'


f = open(COUCHDB_INI, 'w')

c.write(f)

f.close()
