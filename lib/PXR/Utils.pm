#!/usr/bin/perl

package PXR::Utils;

use strict;
use warnings;

use IO::File;
use POE::Filter::XML;
use PXR::Node;
use PXR::NS qw/ :IQ /;

require Exporter;

our $VERSION = '0.1.1';
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
		$blank->attr('type' => +IQ_RESULT);
		$blank->attr('id' => $attribs->{'id'}) if exists($attribs->{'id'});
		
		$node->free();

		return $blank;
		
	} else {

		$node->attr('to' => $from);
		$node->attr('from' => $to);
		$node->attr('type' => +IQ_RESULT);

		return $node;
	}
}

sub get_error()
{
	my ($node, $error, $code) = @_;

	my $from = $node->attr('from');

	$node->attr('to' => $from);
	$node->attr('from' => $hash->{'router'}->{'hostname'});
	$node->attr('type' => +IQ_ERROR);

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

__END__

=pod

=head1 NAME

PXR::Utils - General purpose utilities for PXR Tools

=head1 SYNOPSIS

 use PXR::Utils; # exports functions listed below

 my $hash_ref_to_config = &get_config($absolute_path_to_config);
 my $hash_ref_to_config = &get_config();  # defaults to ./config.xml

 my $node = get_reply($node);  # swaps to and from and sets 'type' to IQ_RESULT
 my $new_node = get_reply($node, 'blank');  # makes and returns blank result
 
 my $node = get_error($node, $text_error, $code_number); # add error and reply

 my $user = get_user('nickperez@jabber.org'); # gets 'nickperez'
 my $domain = get_host('nickperez@jabber.org'); # gets 'jabber.org'

=head1 DESCRIPTION

PXR::Utils provides some common use utilities for use with PXR Tools such as
XML configuration files, make nodes replies, add errors for error replies, and
gather things from jids.

=head1 AUTHOR

Copyright (c) 2003 Nicholas Perez. Released and distributed under the GPL.

=cut

