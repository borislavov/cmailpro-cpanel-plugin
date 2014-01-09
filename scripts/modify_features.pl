#!/bin/sh
eval 'if [ -x /usr/local/cpanel/3rdparty/bin/perl ]; then exec /usr/local/cpanel/3rdparty/bin/perl -x -- $0 ${1+"$@"}; else exec /usr/bin/perl -x $0 ${1+"$@"}; fi;'
    if 0;
#!/usr/bin/perl

use strict;
use Cpanel::Features ();

# if the file does not exist, create it.
if (! -f '/var/cpanel/features/default' ) {
    open(FO, ">>", '/var/cpanel/features/default');
    close(FO);
}
my @stop_features = ();
my @feature_lists = Cpanel::Features::get_feature_lists();
my @addonfeatures = Cpanel::Features::load_addon_feature_names();
@stop_features = grep {/^(cgpro|itoolabs)\_/} @addonfeatures;
my @cmail_stop_features = grep {/^noncgpro\_/} @addonfeatures;
push @cmail_stop_features, "googleappswizard";
my @cmail_start_features = ("cgpro_backup", "cgpro_dnssrv", "cgpro_helpers", "cgpro_autoresponders", "cgpro_pronto", "cgpro_autoloaders", "cgpro_groupware", "cgpro_forwardersemail", "cgpro_spamassassin", "cgpro_maillist", "cgpro_groupmail", "cgpro_filters", "cgpro_defaultaddress", "cgpro_emailarchive", "cgpro_pronto_html5", "cgpro_emailverify", "cgpro_account_defaults", "cgpro_xmpp_clients", "cgpro_popaccts", "cgpro_contacts", "cgpro_xmpp_history", "cgpro_xmpp_roster", "cgpro_account_types", "cgpro_rpop", "cgpro_airsync", "cgpro_prontodrive", "cgpro_prontodrive_settings", "cgpro_legacy_webmail", "cgpro_emailtrace", "cgpro_changemx", "cgpro_emailauth", "cgpro_csvimport", "cgpro_migration_wizard", "cgpro_energy_webmail");
foreach my $feature_list_name (@feature_lists) {
    if ($feature_list_name ne 'disabled') {
	next if $feature_list_name =~ m/\-cMailPro$/;
	unless (-f "/var/cpanel/features/" . $feature_list_name . "-cMailPro") {
	    system("cp","/var/cpanel/features/" . $feature_list_name, "/var/cpanel/features/" . $feature_list_name . "-cMailPro");
	    foreach my $feature (@cmail_stop_features) {
		Cpanel::Features::modify_feature((
		    'feature' => $feature,
		    'value' => '0',
		    'list' => $feature_list_name . "-cMailPro"
						 ));
		print "Stopping feature \"" . $feature . "\" in \"".$feature_list_name."-cMailPro\" by default\n";
	    }
	    foreach my $feature (@cmail_start_features) {
		Cpanel::Features::modify_feature((
		    'feature' => $feature,
		    'value' => '1',
		    'list' => $feature_list_name . "-cMailPro"
						 ));
		print "Starting feature \"" . $feature . "\" in \"".$feature_list_name."-cMailPro\" by default\n";
	    }
	}
	foreach my $feature (@stop_features) {
	    Cpanel::Features::modify_feature((
	    	'feature' => $feature,
	    	'value' => '0',
	    	'list' => $feature_list_name
	    				     ));
	    print "Stopping feature \"" . $feature . "\" in \"".$feature_list_name."\" by default\n";
	}
    }
}
