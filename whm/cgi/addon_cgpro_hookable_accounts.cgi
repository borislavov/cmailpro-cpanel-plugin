#!/bin/sh
 eval 'if [ -x /usr/local/cpanel/3rdparty/bin/perl ]; then exec /usr/local/cpanel/3rdparty/bin/perl -x -- $0 ${1+"$@"}; else exec /usr/bin/perl -x $0 ${1+"$@"}; fi;'
    if 0;
#!/usr/bin/perl
#WHMADDON:appname:CGPro <strong>Hookable Accounts</strong>

use Cpanel::Form            ();
use Whostmgr::HTMLInterface ();
use Whostmgr::ACLS          ();
use CLI;
use Cpanel::CachedDataStore;

print "Content-type: text/html\r\n\r\n";

Whostmgr::ACLS::init_acls();
if ( !Whostmgr::ACLS::hasroot() ) {
  print "You need to be root to see the hello world example.\n";
  exit();
}

my $conf = Cpanel::CachedDataStore::fetch_ref( '/var/cpanel/communigate.yaml' ) || {};
my $cli = new CGP::CLI( { PeerAddr => $conf->{cgprohost},
                            PeerPort => $conf->{cgproport},
                            login => $conf->{cgprouser},
                            password => $conf->{cgpropass} } );
unless($cli) {
  print STDERR "Can't login to CGPro: ".$CGP::ERR_STRING,"\n";
   exit(0);
}

my $cgproversion = $cli->getversion();
my %FORM = Cpanel::Form::parseform();
Whostmgr::HTMLInterface::defheader( "CGPro Hookable Accounts",'', '/cgi/addon_cgpro_hookable_accounts.cgi' );

if ($FORM{'save'}) {
    if ($FORM{'accounts'} =~ /\w/) {
	open(FO, ">", '/var/cpanel/communigate_hooked_accounts');
	print FO $FORM{'accounts'};
	close(FO);
    } else {
	unlink '/var/cpanel/communigate_hooked_accounts';
    }
}
my $accounts = "";
if (-f '/var/cpanel/communigate_hooked_accounts') {
    open(FI, "<", '/var/cpanel/communigate_hooked_accounts');
    my @accounts = <FI>;
    $accounts = join "", @accounts;
    close(FI);
}
Cpanel::Template::process_template(
    'whostmgr',
    {
	'template_file' => 'addon_cgpro_hookable_accounts.tmpl',
	cgproversion => $cgproversion,
	accounts => $accounts,
	FORM => \%FORM
	},
);


$cli->Logout();
1;


sub get_account_details {
    my ($user) = @_;
    if ( $Cpanel::FileLookup::REVERSE_FILELOOKUPCACHE{$Cpanel::ConfigFiles::TRUEUSERDOMAINS_FILE}{$user} ) {
        return $Cpanel::FileLookup::REVERSE_FILELOOKUPCACHE{$Cpanel::ConfigFiles::TRUEUSERDOMAINS_FILE}{$user};
    }
    return unless Cpanel::Config::LoadCpUserFile::has_cpuser_file($user);
    my $cpuser_ref = Cpanel::Config::LoadCpUserFile::loadcpuserfile($user);
    return $cpuser_ref;
}
