#!/usr/bin/perl

package PXR::Utils;

use strict;
use warnings;

use IO::File;
use POE::Filter::XML;
use PXR::Node;
use PXR::NS qw/ :IQ /;

require Exporter;

our $VERSION = '0.1';
our @ISA = qw/ Exporter /;
our @EXPORT = qw/ &get_config &get_reply &get_error &get_user &get_host /;

my $hash;

sub get_config()
{
	my $path = shift;
	my $file;
	
	if(defined($path))
	{
		$file = IO::File->new($path);

	} else {
		
		$file = IO::File->new('./config.xml');
	}
	my $filter = POE::Filter::XML->new(undef,undef);
	my @lines = $file->getlines();
	my $nodes = $filter->get(\@lines);
	my $node = splice(@$nodes,0,1); undef $nodes;
	$hash = &get_hash_from_node($node);
	$node->free();

	return $hash;

}

sub get_hash_from_node()
{
	my $node = shift;
	my $hash = {};
	return $node->data() unless keys %{$node->[3]} > 0;
	foreach my $kid (keys %{$node->[3]})
	{
		$hash->{$node->[3]->{$kid}->name()} 
			= &get_hash_from_node($node->[3]->{$kid});

	}
	return $hash;

}

sub get_reply()
{
	my $node = shift;
	my $empty = shift;

	my $attribs = $node->get_attrs();
	my $to = $attribs->{'to'};
	my $from = $attribs->{'from'};
	my $xmlns = $node->get_tag('query')->attr('xmlns');

	if($empty)
	{
		my $blank = PXR::Node->new('iq');
		$blank->insert_tag('query', $xmlns);
		$blank->attr('to' => $from);
		$blank->attr('from' => $to);
		$blank->attr('type' => IQ_RESULT());
		$blank->attr('id' => $attribs->{'id'}) if exists($attribs->{'id'});
		
		$node->free();

		return $blank;
		
	} else {

		$node->attr('to' => $from);
		$node->attr('from' => $to);
		$node->attr('type' => 'result');

		return $node;
	}
}

sub get_error()
{
	my ($node, $error, $code) = @_;

	my $from = $node->attr('from');

	$node->attr('to' => $from);
	$node->attr('from' => $hash->{'router'}->{'hostname'});
	$node->attr('type' => IQ_ERROR);

	my $err = $node->insert_tag('error');
	$err->attr('code' => $code);
	$err->data($error);

	return $node;
	
}

sub get_user()
{
	my $jid = shift;
	$jid =~ s/\@\S+$//;
	return $jid;
}

sub get_host()
{
	my $jid = shift;
	$jid =~ s/^\S+\@//;
	return $jid;
}

1;
