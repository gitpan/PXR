package PXR::NS;

use strict;
use warnings;

our $VERSION = '0.1.1';

use constant {
	XMLNS_STREAM => 'http://etherx.jabber.org/streams',
	
	NS_SERVICE => 'jabber:service',
	NS_JABBER_CLIENT => 'jabber:client',
	NS_JABBER_ACCEPT => 'jabber:component:accept',
	NS_JABBER_CONNECT => 'jabber:component:connect',

	NS_AUTH => 'jabber:service:auth',
	NS_REGISTER => 'jabber:service:register',
	NS_JID => 'jabber:service:jid',
	NS_ROUTE => 'jabber:service:route',
	NS_STATE => 'jabber:service:state',
	NS_DISCOINFO => 'jabber:iq:disco#info',
	NS_DISCOITEMS => 'jabber:iq:disco#items',
	
	NS_JABBER_AUTH => 'jabber:iq:auth',
	NS_JABBER_REGISTER => 'jabber:iq:register',
	NS_JABBER_DISCOINFO => 'jabber:iq:disco#info',
	NS_JABBER_DISCOITEMS => 'jabber:iq:disco#items',
	NS_JABBER_ROSTER => 'jabber:iq:roster',

	NS_XMPP_LIMIT => 'xmpp:x:limit',

	IQ_GET => 'get',
	IQ_SET => 'set',
	IQ_ERROR => 'error',
	IQ_RESULT => 'result',
};

require Exporter;
our @ISA = qw/ Exporter /;

our @EXPORT_OK = qw/ NS_JABBER_CLIENT NS_JABBER_ACCEPT NS_JABBER_CONNECT 
	NS_SERVICE NS_AUTH NS_REGISTER NS_JID NS_ROUTE 
	NS_STATE NS_JABBER_DISCOINFO NS_JABBER_DISCOITEMS NS_XMPP_LIMIT
	IQ_GET IQ_SET IQ_ERROR IQ_RESULT NS_JABBER_AUTH NS_JABBER_REGISTER
	NS_DISCOINFO NS_DISCOITEMS XMLNS_STREAM NS_JABBER_ROSTER/;

our %EXPORT_TAGS = (
	SERVICE	=> [
		qw/ NS_SERVICE NS_AUTH NS_REGISTER NS_JID NS_DISCOINFO NS_DISCOITEMS
		NS_ROUTE NS_STATE XMLNS_STREAM/
	],
	JABBER	=> [
		qw/ NS_JABBER_DISCOINFO NS_JABBER_DISCOITEMS NS_JABBER_AUTH 
		NS_JABBER_REGISTER NS_XMPP_LIMIT NS_JABBER_CLIENT XMLNS_STREAM
		NS_JABBER_ROSTER NS_JABBER_ACCEPT NS_JABBER_CONNECT/
	],
	IQ		=> [
		qw/ IQ_GET IQ_SET IQ_ERROR IQ_RESULT /
	]);
	
my %seen;
		
push @{$EXPORT_TAGS{'all'}}, 
	grep {!$seen{$_}++} @{$EXPORT_TAGS{$_}} foreach keys %EXPORT_TAGS;

1;

__END__

=pod

=head1 NAME

PXR::NS - Namespace support for PXR, JABBER(tm)

=head1 SYNOPSIS

use PXR::NS qw/ :SERVICE :JABBER :IQ /;

=head1 DESCRIPTION

PXR::NS provides namespace constants for use within PXR::Nodes (or any other
representation) that requires namespace matching. The following export tags
are explained below:

=over 4

=item :SERVICE

":SERVICE" tag will import constants for use within the PXR Service environment
such as the XML namespace jabber:service and its relatives.

=item :JABBER

":JABBER" tag will import various useful constants for use within a normal 
Jabber client and component(to reference implementation server) situation.

=item ":IQ"

":IQ" tag imports convenience <iq/> packet types such as set, get, result, and
error

=item ":all"

":all" will import every tag available within the package.

=back

Please reference the source file to know which namespaces are explictly
supported and exported.

=head1 BUGS

XMPP support needs to thought about.

=head1 AUTHOR

Copyright (c) 2003 Nicholas Perez. Released and distributed under the GPL.

=cut

