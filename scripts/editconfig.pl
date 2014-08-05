#!/usr/bin/perl

use strict;
use warnings;
use lib '/usr/local/cpanel';
use Cpanel::CachedDataStore ();

my $data = Cpanel::CachedDataStore::fetch_ref( '/var/cpanel/communigate.yaml' ) || {};
my $newdata = $data;
my $cgprohost = $data->{cgprohost};
my $cgproport = $data->{cgproport};
my $cgprouser = $data->{cgprouser};
my $cgpropass = $data->{cgpropass};
  # Enter Hostname
my $hostname = `hostname`;
$hostname =~ s/\..*?$//g;
$hostname =~ s/\n//g;
$cgprohost = $hostname . ".cmailpro.net\n";
# Enter port
$cgproport = '106';
# Enter user
$cgprouser = 'postmaster';
Cpanel::CachedDataStore::store_ref( '/var/cpanel/communigate.yaml', $newdata );
