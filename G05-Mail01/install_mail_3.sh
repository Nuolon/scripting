#!/bin/bash
# This is the last script for the
# configuration of the mail server

# Copy the last configuration file to
# access Roundcube from a different device

cp configfiles/var/www/html/roundcube/config/config.inc.php /var/www/html/roundcube/config/config.inc.php

# This was the end of the configuration of
# the mail server. It should be possible to
# send mails.
