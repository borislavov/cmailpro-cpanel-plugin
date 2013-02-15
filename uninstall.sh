#!/bin/bash

PACKSRC=`pwd`
#################################################
#		cPanel Specific			#
#################################################

# iPhone provisioning using default httpd
rm -rf /usr/local/apache/htdocs/iOS
rm -rf /var/CommuniGate/apple

# Uninstall the WHM plugins (administration and groupware control)
rm -rf /usr/local/cpanel/whostmgr/docroot/cgi/cgpro*
rm -f /usr/local/cpanel/whostmgr/docroot/templates/cgpro_*

# Uninstall CGP Logo
rm -f /usr/local/cpanel/whostmgr/docroot/images/communigate.gif

# Uninstall the WHM Script hooks (CommuniGate provisioning)
if [ -f /usr/local/cpanel/scripts/postwwwacct ]
then
    rm -f /usr/local/cpanel/scripts/postwwwacct
fi

# Uninstall cPanel CommuniGate Custom Module
rm -f /usr/local/cpanel/Cpanel/CommuniGate.pm

# Lets remove CGPro perl lib
if [ ! -L /usr/local/lib/perl5/5.8.8/CLI.pm ]
then
    rm -f /usr/local/lib/perl5/5.8.8/CLI.pm
fi
rm -f /usr/local/cpanel/perl/CLI.pm

# CGPro cPanel Wrapper
rm -f /usr/local/cpanel/bin/ccaadmin
rm -f /usr/local/cpanel/bin/ccawrap

# Register installed hooks
/usr/local/cpanel/bin/manage_hooks delete module CGPro::Hooks
# Uninstall cPanel Function hooks
rm -rf /var/cpanel/perl5/lib/CGPro/

#Uninstall config file
rm -f /var/cpanel/communigate.yaml

# Uninstall CommuniGate Webmail in cPanel
rm -f /var/cpanel/webmail/webmail_communigate.yaml
rm -rf /usr/local/cpanel/base/3rdparty/CommuniGate/

# Uninstall SSO for Webmail
rm -f /var/CommuniGate/cgi/login.pl

# chkservd for CGServer & spamd
rm -f /etc/chkserv.d/CommuniGate
rm -f /etc/chkserv.d/CommuniGate_spamd
sed -i -e '/^CommuniGate/d' /etc/chkserv.d/chkservd.conf

# Uninstall CommuniGate Plugin
BASEDIR='/usr/local/cpanel/base/frontend';
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
THEMES=($(find ${BASEDIR} -maxdepth 1 -mindepth 1 -type d))
IFS=$OLDIFS

tLen=${#THEMES[@]}

LOCALES=($(find ${PACKSRC}/locale -maxdepth 1 -mindepth 1))
lLen=${#LOCALES[@]}

for (( i=0; i<${tLen}; i++ ));
do
    if [ "${THEMES[$i]}" == "${BASEDIR}/CommuniGate" ]
    then
        continue
    fi
    rm -rf ${THEMES[$i]}/cgpro
    rm -f ${THEMES[$i]}/branding/cgpro_*
    rm -rf ${THEMES[$i]}/dynamicui/dynamicui_cgpro.conf
    rm -f ${THEMES[$i]}/dynamicui/js2-min/cgpro/mail
    rmdir  ${THEMES[$i]}/dynamicui/js2-min/cgpro
    rm -f ${THEMES[$i]}/dynamicui/css2-min/cgpro/mail
    rmdir ${THEMES[$i]}/dynamicui/css2-min/cgpro
    for ((j=0; j<${lLen}; j++)); do
        TARGET=${THEMES[$i]}/locale/`basename ${LOCALES[$j]} '{}'`.yaml.local
        sed -i -e '/^CGP/d' ${TARGET}
    done
done
# Update Feature List
rm -f /usr/local/cpanel/whostmgr/addonfeatures/cgpro
/usr/local/cpanel/bin/rebuild_sprites
/usr/local/cpanel/bin/build_locale_databases
