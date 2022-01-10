<?php

/* Local configuration for Roundcube Webmail */

// ----------------------------------

// SQL DATABASE

// ----------------------------------

// Database connection string (DSN) for read+write operations

// Format (compatible with PEAR MDB2): db_provider://user:password@host/database

// Currently supported db_providers: mysql, pgsql, sqlite, mssql, sqlsrv, oracle

// For examples see http://pear.php.net/manual/en/package.database.mdb2.intro-dsn.php

// Note: for SQLite use absolute path (Linux): 'sqlite:////full/path/to/sqlite.db?mode=0646'

//       or (Windows): 'sqlite:///C:/full/path/to/sqlite.db'

// Note: Various drivers support various additional arguments for connection,

//       for Mysql: key, cipher, cert, capath, ca, verify_server_cert,

//       for Postgres: application_name, sslmode, sslcert, sslkey, sslrootcert, sslcrl, sslcompression, service.

//       e.g. 'mysql://roundcube:@localhost/roundcubemail?verify_server_cert=false'

$config['db_dsnw'] = 'mysql://roundcube_admin:Pa%24%24w0rd%21@localhost/roundcube';

// ----------------------------------

// IMAP

// ----------------------------------

// The IMAP host chosen to perform the log-in.

// Leave blank to show a textbox at login, give a list of hosts

// to display a pulldown menu or set one host as string.

// Enter hostname with prefix ssl:// to use Implicit TLS, or use

// prefix tls:// to use STARTTLS.

// Supported replacement variables:

// %n - hostname ($_SERVER['SERVER_NAME'])

// %t - hostname without the first part

// %d - domain (http hostname $_SERVER['HTTP_HOST'] without the first part)

// %s - domain name after the '@' from e-mail address provided at login screen

// For example %n = mail.domain.tld, %t = domain.tld

// WARNING: After hostname change update of mail_host column in users table is

//          required to match old user data records with the new host.

$config['default_host'] = 'localhost';

// provide an URL where a user can get support for this Roundcube installation

// PLEASE DO NOT LINK TO THE ROUNDCUBE.NET WEBSITE HERE!

$config['support_url'] = '';

// This key is used for encrypting purposes, like storing of imap password

// in the session. For historical reasons it's called DES_key, but it's used

// with any configured cipher_method (see below).

// For the default cipher_method a required key length is 24 characters.

$config['des_key'] = 'hxgaY77LChV5qqspV4EFobIY';

// The following lines are all added
$config['default_port'] = 143;
$config['smtp_server'] = 'localhost';
$config['smtp_port'] = 25;
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '';
$config['smtp_auth_type'] = 'LOGIN';
$config['debug_level'] = 1;
$config['smtp_debug'] = true;
$config['plugins'] = array('virtuser_query');
$config['virtuser_query'] = "SELECT Email FROM postfix_accounts.accounts_table WHERE Email = '%u'";

// ----------------------------------

// PLUGINS

// ----------------------------------

// List of active plugins (in plugins/ directory)

//$config['plugins'] = array('password');

// Password Plugin options
// -----------------------
//$config['password_driver'] = 'ldap_simple';
//$config['password_confirm_current'] = true;
//$config['password_minimum_length'] = 6;
//$config['password_require_nonalpha'] = false;
//$config['password_log'] = false;
//$config['password_login_exceptions'] = null;
//$config['password_hosts'] = null;
//$config['password_force_save'] = false;
 
 
// LDAP and LDAP_SIMPLE Driver options
// -----------------------------------
//$config['password_ldap_host'] = '10.15.1.14';
//$config['password_ldap_port'] = '389';
//$config['password_ldap_starttls'] = false;
//$config['password_ldap_version'] = '3';
//$config['password_ldap_basedn'] = 'dc=groep5,dc=local';
//$config['password_ldap_method'] = 'user';
//$config['password_ldap_searchDN'] = 'cn=bind1,cn=Users,dc=groep5,dc=local';
//$config['password_ldap_searchPW'] = 'Pa$$w0rd!';
//$config['password_ldap_search_base'] = 'cn=Users,dc=groep5,dc=local';
//$config['password_ldap_search_filter'] = '(uniqueIdentifier=%name)';
//$config['password_ldap_encodage'] = 'crypt';
//$config['password_ldap_pwattr'] = 'userPassword';
//$config['password_ldap_force_replace'] = true;
