package PXR::NS;

use strict;
use warnings;

use constant {
	XMLNS_STREAM => 'http://etherx.jabber.org/streams',
	
	NS_SERVICE => 'jabber:service',
	NS_JABBER => 'jabber:client',

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

	NS_XMPP_LIMIT => 'xmpp:x:limit',

	IQ_GET => 'get',
	IQ_SET => 'set',
	IQ_ERROR => 'error',
	IQ_RESULT => 'result',
};

require Exporter;
our @ISA = qw/ Exporter /;

our @EXPORT_OK = qw/ NS_SERVICE NS_AUTH NS_REGISTER NS_JID NS_ROUTE NS_STATE
	NS_JABBER_DISCOINFO NS_JABBER_DISCOITEMS NS_XMPP_LIMIT 	IQ_GET IQ_SET 
	IQ_ERROR IQ_RESULT NS_JABBER_AUTH NS_JABBER_REGISTER NS_DISCOINFO 
	NS_DISCOITEMS XMLNS_STREAM/;

our %EXPORT_TAGS = (
	SERVICE	=> [
		qw/ NS_SERVICE NS_AUTH NS_REGISTER NS_JID NS_DISCOINFO NS_DISCOITEMS
		NS_ROUTE NS_STATE XMLNS_STREAM/
	],
	JABBER	=> [
		qw/ NS_JABBER_DISCOINFO NS_JABBER_DISCOITEMS NS_JABBER_AUTH 
		NS_JABBER_REGISTER NS_XMPP_LIMIT NS_JABBER XMLNS_STREAM/
	],
	IQ		=> [
		qw/ IQ_GET IQ_SET IQ_ERROR IQ_RESULT /
	]);
	
my %seen;
		
push @{$EXPORT_TAGS{'all'}}, 
	grep {!$seen{$_}++} @{$EXPORT_TAGS{$_}} foreach keys %EXPORT_TAGS;

1;
