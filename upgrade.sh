#!/bin/bash

PACKSRC=`pwd`

#################################################
#		cPanel Specific			#
#################################################

# Register installed hooks
/usr/local/cpanel/bin/manage_hooks delete module CGPro::Hooks

# iPhone provisioning using default httpd
if [ -d '/var/CommuniGate/' ]
then
    cp ${PACKSRC}/iphone/iphonetemplate.mobileconfig /var/CommuniGate/apple/
fi

# Install CGP Logo
cp ${PACKSRC}/whm/communigate.gif /usr/local/cpanel/whostmgr/docroot/images/communigate.gif

# Install cPanel CommuniGate Custom Module
cp ${PACKSRC}/module/CommuniGate.pm /usr/local/cpanel/Cpanel/

# Lets add CGPro perl lib
cp ${PACKSRC}/library/CLI.pm /usr/local/cpanel/perl/
if [ ! -L /usr/local/cpanel/CLI.pm ]
then
    rm -f /usr/local/cpanel/CLI.pm
    ln -s /usr/local/cpanel/perl/CLI.pm /usr/local/cpanel
fi
PERL_VERSION=`perl -v | grep 'This is perl' | perl -pe 's/^.*?v(\d+\.\d+\.\d+).*?$/$1/g'`
MY_PERL_PATHS="/usr/local/lib/perl5/$PERL_VERSION /usr/local/lib/perl/$PERL_VERSION /usr/local/share/perl/$PERL_VERSION /usr/local/share/perl5"
DEFAULT_PERL_PATHS=`perl -e "print join ' ', @INC"`
PERL_PATH=""
found=
for i in ${MY_PERL_PATHS[@]}; do
    for j in ${DEFAULT_PERL_PATHS[@]}; do
	[[ $i == $j ]] && { PERL_PATH=$i; found=1; break; }
    done
    [[ -n $skip ]] && { break; }
done
if [ ! -d $PERL_PATH ]
then
    mkdir -p $PERL_PATH
fi
ln -s /usr/local/cpanel/perl/CLI.pm $PERL_PATH/

cp ${PACKSRC}/library/XIMSS.pm /usr/local/cpanel/

# CGPro cPanel Wrapper
cp ${PACKSRC}/cpwrap/ccaadmin /usr/local/cpanel/bin/
cp ${PACKSRC}/cpwrap/ccawrap /usr/local/cpanel/bin/
cp -r ${PACKSRC}/cpwrap/CGPro /usr/local/cpanel/bin/admin/

# install Perl dependencies
if [ -d '/var/CommuniGate/' -a `perldoc -l Mail::DKIM::Verifier | wc -l` == 0 ]
then
    perl -MCPAN -e 'install Mail::DKIM::Verifier'
fi

if [ -d '/var/CommuniGate/' -a `perldoc -l Mail::DKIM::Signer | wc -l` == 0 ]
then
    perl -MCPAN -e 'install Mail::DKIM::Signer'
fi
if [ -d '/var/CommuniGate/' -a `perldoc -l IO::Scalar | wc -l` == 0 ]
then
    perl -MCPAN -e 'install IO::Scalar'
fi
if [ -d '/var/CommuniGate/' -a `perldoc -l Archive::Zip | wc -l` == 0 ]
then
    perl -MCPAN -e 'install Archive::Zip'
fi
if [ -d '/var/CommuniGate/' -a `perldoc -l GD::Barcode::QRcode | wc -l` == 0 ]
then
    perl -MCPAN -e 'install GD::Barcode::QRcode'
fi
if [ `perldoc -l YAML::Syck | wc -l` == 0 ]
then
    /usr/local/cpanel/bin/cpanm -f -q YAML::Syck
fi
chmod +x ${PACKSRC}/scripts/install_cpanel_module.pl
${PACKSRC}/scripts/install_cpanel_module.pl MIME::QuotedPrint::Perl
${PACKSRC}/scripts/install_cpanel_module.pl XML::SAX
${PACKSRC}/scripts/install_cpanel_module.pl GD::Barcode::QRcode

# Install cPanel Function hooks
if [ ! -d /var/cpanel/perl5/lib/ ]
then
    mkdir -p /var/cpanel/perl5/lib/
fi
cp -rf ${PACKSRC}/hooks/CGPro /var/cpanel/perl5/lib/
# Register installed hooks
/usr/local/cpanel/bin/manage_hooks add module CGPro::Hooks

# Install CommuniGate Webmail in cPanel
rm -f /var/cpanel/webmail/webmail_communigate*
# cp ${PACKSRC}/cgpro-webmail/webmail_communigate.yaml /var/cpanel/webmail/
# cp ${PACKSRC}/cgpro-webmail/webmail_communigatepronto.yaml /var/cpanel/webmail/
cp -r ${PACKSRC}/cgpro-webmail/CommuniGate /usr/local/cpanel/base/3rdparty/
cp -r ${PACKSRC}/cgpro-webmail/CommuniGatePronto /usr/local/cpanel/base/3rdparty/

# Install SSO for Webmail
if [ -d '/var/CommuniGate/' ]
then
    if [ ! -d /var/CommuniGate/cgi ]
    then
	mkdir -p /var/CommuniGate/cgi
    fi
    cp ${PACKSRC}/sso/login.pl /var/CommuniGate/cgi/
    chmod +x /var/CommuniGate/cgi/login.pl
    chmod +x ${PACKSRC}/cgi/*pl
    cp ${PACKSRC}/cgi/*.pl /var/CommuniGate/cgi/
    if [ ! -f /var/CommuniGate/cgi/DuoWeb.pm ]
    then
	wget -O /var/CommuniGate/cgi/DuoWeb.pm https://raw2.github.com/duosecurity/duo_perl/master/DuoWeb.pm
    fi
    chmod u+s /opt/CommuniGate/mail
fi

# chkservd for CGServer & spamd
cp ${PACKSRC}/chkservd/CommuniGate /etc/chkserv.d/
cp ${PACKSRC}/chkservd/CommuniGate_spamd /etc/chkserv.d/

# Check the scripts have executable flag
chmod +x /usr/local/cpanel/whostmgr/docroot/cgi/addon_cgpro*
chmod +x /usr/local/cpanel/Cpanel/CommuniGate.pm
chmod +x /usr/local/cpanel/bin/ccaadmin
chmod +s+x /usr/local/cpanel/bin/ccawrap
chmod +x /usr/local/cpanel/bin/admin/CGPro/cca

# Install CommuniGate Plugin
BASEDIR='/usr/local/cpanel/base/frontend';
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
THEMES=($(find ${BASEDIR} -maxdepth 1 -mindepth 1 -type d))
LOCALES=($(find ${PACKSRC}/locale -maxdepth 1 -mindepth 1))
IFS=$OLDIFS

tLen=${#THEMES[@]}
lLen=${#LOCALES[@]}

for (( i=0; i<${tLen}; i++ ));
do
    if [ "${THEMES[$i]}" == "${BASEDIR}/CommuniGate" ]
    then
        continue
    fi
    rm -rf ${THEMES[$i]}/cgpro
    cp -r "${PACKSRC}/theme/cgpro" "${THEMES[$i]}/"
    rm -f ${THEMES[$i]}/branding/cgpro_*
    cp "${PACKSRC}/icons/"* "${THEMES[$i]}/branding"
    cp "${PACKSRC}/plugin/dynamicui_cgpro.conf" "${THEMES[$i]}/dynamicui/"
    if [ ! -d ${THEMES[$i]}/js2-min/cgpro ]
    then
	mkdir -p ${THEMES[$i]}/js2-min/cgpro
    fi
    if [ ! -L ${THEMES[$i]}/js2-min/cgpro/mail ]
    then
	ln -s ${THEMES[$i]}/js2-min/mail ${THEMES[$i]}/js2-min/cgpro/
    fi
    if [ ! -d ${THEMES[$i]}/css2-min/cgpro ]
    then
	mkdir -p ${THEMES[$i]}/css2-min/cgpro
    fi
    if [ ! -L ${THEMES[$i]}/css2-min/cgpro/mail ]
    then
	ln -s ${THEMES[$i]}/css2-min/mail ${THEMES[$i]}/css2-min/cgpro/
    fi
    chmod +x ${THEMES[$i]}/cgpro/backup/getaccbackup.live.cgi
    chmod +x ${THEMES[$i]}/cgpro/backup/getaliasesbackup.live.cgi
    chmod +x ${THEMES[$i]}/cgpro/backup/getfiltersbackup.live.cgi
    chmod +x ${THEMES[$i]}/cgpro/mail/checkDomainSettings.live.cgi
    chmod +x ${THEMES[$i]}/cgpro/mail/getDomainAccounts.live.cgi
    chmod +x ${THEMES[$i]}/cgpro/mail/getVCARD.live.cgi
    chmod +x ${THEMES[$i]}/cgpro/mail/getQR.live.cgi
    chmod +x ${THEMES[$i]}/cgpro/mail/contactsimport.live.cgi
    chmod +x ${THEMES[$i]}/cgpro/getXmppHistory.live.cgi
    chmod +x ${THEMES[$i]}/cgpro/playwav.live.cgi
    chmod +x ${THEMES[$i]}/cgpro/getwav.live.cgi

    if [ -f ${THEMES[$i]}cgpro/mail/groupware.html ]
    then
	rm -f ${THEMES[$i]}cgpro/mail/groupware.html
    fi
    for ((j=0; j<${lLen}; j++)); do
        TARGET=${THEMES[$i]}/locale/`basename ${LOCALES[$j]} '{}'`.yaml.local
        if [ ! -f ${TARGET} ]
        then
            echo "---" > ${TARGET}
        else
	    sed -i -e '/^"*CGP/d' ${TARGET}
        fi
        cat ${LOCALES[$j]} >> ${TARGET}
    done
done

# Install CommuniGate Plugin Webmail
BASEDIR='/usr/local/cpanel/base/webmail';
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
THEMES=($(find ${BASEDIR} -maxdepth 1 -mindepth 1 -type d))
IFS=$OLDIFS
tLen=${#THEMES[@]}

for (( i=0; i<${tLen}; i++ ));
do
    rm -rf ${THEMES[$i]}/cgpro
    cp -r "${PACKSRC}/theme_webmail/cgpro" "${THEMES[$i]}/"
    chmod +x ${THEMES[$i]}/cgpro/energy.live.cgi
    chmod +x ${THEMES[$i]}/cgpro/pronto.live.cgi
done



chmod +x ${PACKSRC}/scripts/*

if [ -d '/var/CommuniGate/' ]
then
# Migrating groupware accounts
    if [ -f /var/CommuniGate/cPanel/limits ]
    then
	${PACKSRC}/scripts/migrate_groupware.pl
	echo "!!! Please delete /var/CommuniGate/cPanel/limits by hand if seetings are OK !!!"
    fi
fi

# Purge unneeded files
if [ -f /usr/local/cpanel/whostmgr/docroot/cgi/addon_cgpro-gwcontrol.cgi ]
then
    rm -f /usr/local/cpanel/whostmgr/docroot/cgi/addon_cgpro-gwcontrol.cgi
fi
if [ -f /usr/local/cpanel/scripts/postwwwacct ]
then
    rm -f /usr/local/cpanel/scripts/postwwwacct
fi


${PACKSRC}/scripts/init_pbx.pl

# Update Feature List
cp ${PACKSRC}/featurelists/cgpro /usr/local/cpanel/whostmgr/addonfeatures/
/usr/local/cpanel/bin/rebuild_sprites
/usr/local/cpanel/bin/build_locale_databases

if [ -d '/var/CommuniGate/' ]
then
# install DKIM tools FOR CGPro server Only
    chmod +x ${PACKSRC}/tools/*
    cp ${PACKSRC}/tools/helper_DKIM_sign.pl /var/CommuniGate/
    cp ${PACKSRC}/tools/helper_DKIM_verify.pl /var/CommuniGate/
#    ${PACKSRC}/scripts/install_dkim_signer.pl
    chmod +x ${PACKSRC}/corn_scripts/*
    cp ${PACKSRC}/tools/authMigrate.pl /var/CommuniGate/
    cp ${PACKSRC}/corn_scripts/migrateMail.sh /var/CommuniGate/
#    ${PACKSRC}/scripts/install_migration.pl

# Install Active Queue Scripts
    cp ${PACKSRC}/PBXApps/*spp* /var/CommuniGate/PBXApps/
# Install WebSkins
    chmod +x ${PACKSRC}/cgi/*
    cp -r ${PACKSRC}/WebSkins/* /var/CommuniGate/WebSkins/
    cp ${PACKSRC}/cgi/* /var/CommuniGate/cgi/
    /etc/init.d/CommuniGate stop
    /etc/init.d/CommuniGate start
fi
# Install the WHM plugins (administration and groupware control)
if [ `ls /var/cpanel/apps/addon_cgpro*.conf | wc -l` -gt 0 ]
then
    chmod +x ${PACKSRC}/scripts/unregister_apps.sh
    ${PACKSRC}/scripts/unregister_apps.sh
fi
rm -f /usr/local/cpanel/whostmgr/docroot/templates/cgpro_*
rm -rf /usr/local/cpanel/whostmgr/docroot/cgi/cgpro*
cp ${PACKSRC}/whm/templates/* /usr/local/cpanel/whostmgr/docroot/templates/
cp -rf ${PACKSRC}/whm/cgi/* /usr/local/cpanel/whostmgr/docroot/cgi/
if [ -f /usr/local/cpanel/bin/register_appconfig ]
then
    chmod +x ${PACKSRC}/scripts/register_apps.sh
    ${PACKSRC}/scripts/register_apps.sh
fi

echo "Upgrade Finished!"
