package PXR::Node;

use warnings;
use strict;

use constant tagname => 0;
use constant attrs => 1;
use constant tagdata => 2;
use constant kids => 3;
use constant tagparent => 4;
use constant id => 5;

our $VERSION = '0.1.1';

my $id = 0;

sub new() {

	my ($class, $name, $xmlns, $parent) = @_;

	my $node = [
		 $name,		#name
		 {},		#attr
		 '',		#data
		 {},		#kids
		 $parent,	#parent
		 ++$id,		#id
	];

	bless($node, $class);
	$node->attr('xmlns', $xmlns) if $xmlns;
	return $node;

}

sub clone()
{
	my $self = shift;

	my $new_node = PXR::Node->new($self->[+tagname]);
	$new_node->[+tagdata] = $self->[+tagdata];
	my %attrs = %{$self->[+attrs]};
	$new_node->[+attrs] = \%attrs;
	my $kids = $self->[+kids];
	foreach my $key (keys %$kids)
	{
		if(ref($kids->{$key}) eq 'ARRAY')
		{
			my $array = $kids->{$key};
			foreach my $kid (@$array)
			{
				$new_node->insert_tag($kid->clone());
			}
			next;
		}
		$new_node->insert_tag($kids->{$key}->clone());
	}
	return $new_node;
}

sub free()
{
	my $self = shift;

	my $children = $self->get_children();
	foreach my $child (@$children)
	{
		$child->free();
	}

	undef($self->[+tagparent]);
	
}
	
sub get_id()
{
	my $self = shift;

	return $self->[+id];
}

sub name() 
{
	my ($self, $name) = @_;
	
	if(defined $name)
	{
		$self->[+tagname] = $name;
	}
	
	return $self->[+tagname];
}


sub parent() 
{ 
	my $self = shift;
	return $self->[+tagparent];
}


sub attr() 
{

	my ($self, $attr, $val) = @_;
	
	if (defined $val) 
	{
		if ($val eq '') 
		{
			delete $self->[+attrs]->{$attr};
			
		} else {
		
			$self->[+attrs]->{$attr} = $val;
		}
	}

	return $self->[+attrs]->{$attr};
 
}

sub get_attrs()
{
	my $self = shift;

	return $self->[+attrs];
}

						
sub data() {

	my ($self, $data) = @_;
	
	if (defined $data) 
	{
		$self->[+tagdata] = _encode($data);
	}

	return _decode($self->[+tagdata]);
 
}


sub _encode() {

	my $data = shift;

	$data =~ s/&/&amp;/go;
	$data =~ s/</&lt;/go;
	$data =~ s/>/&gt;/go;
	$data =~ s/'/&apos;/go;
	$data =~ s/"/&quot;/go;

	return $data;

}

						
sub _decode() {

	my $data = shift;

	$data =~ s/&amp;/&/go;
	$data =~ s/&lt;/</go;
	$data =~ s/&gt;/>/go;
	$data =~ s/&apos;/'/go;
	$data =~ s/&quot;/"/go;

	return $data;

}

sub rawdata() {

	my ($self, $data) = @_;
	
	if (defined $data) 
	{
		$self->[+tagdata] = $data;
	}

	return $self->[+tagdata];
 
}

sub insert_tag() {

	my ($self, $tagname, $ns) = @_;

	my $tag;
	
	if(ref($tagname) eq ref($self))
	{
		$tag = $tagname;
		$tagname = $tag->[+tagname];
	
	} else {

		$tag = PXR::Node->new($tagname, $ns, $self);
	}
	
	if(exists($self->[+kids]->{$tagname}))
	{
		if(ref($self->[+kids]->{$tagname}) eq 'ARRAY')
		{
			push(@{$self->[+kids]->{$tagname}}, $tag);
			return $tag;
		
		} else {

			my $first = $self->[+kids]->{$tagname};
			$self->[+kids]->{$tagname} = [];

			push(@{$self->[+kids]->{$tagname}}, $first);
			push(@{$self->[+kids]->{$tagname}}, $tag);
			return $tag;
		}
	}
	
	$self->[+kids]->{$tagname} = $tag;
	
	return $tag;

}

sub to_str {

	my $self = shift;
	
	my $str = '<' . $self->[+tagname];
	
	foreach my $attr (keys %{$self->[+attrs]})
	{
		$str .= ' ' . $attr . "='" . $self->[+attrs]->{$attr} . "'";
	}
	
	if ($self->[+tagdata] or keys %{$self->[+kids]})
	{
		$str .= '>' . $self->[+tagdata];
		
		my $kids = $self->[+kids];
		
		foreach my $kid (keys %$kids)
		{
			if(ref($kids->{$kid}) eq 'ARRAY')
			{
				foreach my $subkid (@{$kids->{$kid}})
				{
					$str .= $subkid->to_str();
				}
	
				next;
			}
			
			$str .= $kids->{$kid}->to_str();
		}
		
		$str .= '</'.$self->[+tagname].'>';
	
	} else {
		
		$str .= '/>';
	}
	
	return $str;
 
}


sub get_tag() {

	my ($self, $tagname, $ns) = @_;
	
	my $return = [];

	if(ref($self->[+kids]->{$tagname}) eq 'ARRAY')
	{
		if(defined($ns))
		{
			foreach my $kid (@{$self->[+kids]->{$tagname}})
			{
				push(@$return, $kid) if $kid->attr('xmlns') eq $ns;
			}

			return wantarray ? @$return : $return->[0];
			
		} else {

			return wantarray ? @{$self->[+kids]->{$tagname}} :
				@{$self->[+kids]->{$tagname}}[0];
		}
		
	} else {
		
		return wantarray ? @{[$self->[+kids]->{$tagname}]} :
			$self->[+kids]->{$tagname};
	}

}

sub detach_from_parent()
{
	my ($self) = @_;

	if(ref($self->[+tagparent]->[+kids]->{$self->[+tagname]}) eq 'ARRAY')
	{
		my $index = 0;
		foreach my $kid (@{$self->[+tagparent]->[+kids]->{$self->[+tagname]}})
		{
			if($kid->[+id] eq $self->[+id])
			{
				splice(@{$self->[+tagparent]->[+kids]->{$self->[+tagname]}},
					$index, '1');
				
				undef($self->[+tagparent]);
				return $self;
			}
			++$index;
		}
	}
	
	delete $self->[+tagparent]->[+kids]->{$self->[+tagname]};
	undef($self->[+tagparent]);
	return $self;
}
	

sub get_children() {

	my ($self) = @_;
	my $return = [];
	my $kids = $self->[+kids];
	foreach my $kid (keys %{$kids})
	{
		if(ref($kids->{$kid}) eq 'ARRAY')
		{
			foreach my $subkid (@{$kids->{$kid}})
			{
				push(@$return, $subkid);
			}
		} else {
		
			push(@$return, $kids->{$kid});
		}
	}
	return $return;

}

sub get_children_hash()
{
	my $self = shift;

	return $self->[+kids];
}

1;

__END__

=pod

=head1 NAME

PXR::Node - Fully featured XML node representation.

=head1 SYNOPSIS

use PXR::Node;

my $node = PXR::Node->new('iq'); 

$node->attr('to', 'nickperez@jabber.org'); 

$node->attr('from', 'PXR::Node@jabber.org'); 

$node->attr('type', 'get'); 

my $query = $node->insert_tag('query', 'jabber:iq:foo');
$query->insert_tag('foo_tag')->data('bar');

my $foo = $query->get_tag('foo_tag');

my $foo2 = $foo->clone();
$foo2->data('new_data');

$query->insert_tag($foo2);

print $node->to_str() . "\n";

$node->free();

-- 

(newlines and tabs for example only)

 <iq to='nickperez@jabber.org' from='PXR::Node@jabber.org' type='get'>
   <query xmlns='jabber:iq:foo'>
     <foo_tag>bar</foo_tag>
     <foo_tag>new_data</foo_tag>
   </query>
 </iq>

=head1 DESCRIPTION

PXR::Node aims to be a very simple yet powerful, memory/speed conscious module
that allows PXR or JABBER(tm) developers to have the flexibility they need to
build custom nodes, use it as the basis of their higher level libraries, 
or manipulating XML and then putting it out to a file. Note that this is not
a parser. This is merely the node representation that can be used to build XML
objects that will give stringified versions of themselves.

=head1 METHODS

=over 4

=item new()

new() accepts as arguments the (1) name of the actual tag (ie. 'iq'), (2) an 
XML namespace, and the PXR::Node parent of the node being created. All of the
arguments are optional and can be specified through other methods at a later
time.

=item clone()

clone() does a B<deep> copy of the node and returns it. This includes all of
its children, data, attributes, etc. The returned node stands on its own and 
does not hold and references to the node cloned.

=item free()

free() breaks circular references between parent and node children. It is
necessary to free() a node after its use to prevent memory leaks. Note that
free() is a deep recursive effort. All children will be free()ed.

=item name()

name() with no arguments returns the name of the node. With an argument, the
name of the node is changed.

=item parent()

parent() returns the PXR::Node parent reference.

=item attr()

attr() with one argument returns the value of that attrib (ie. 
my $attrib = $node->attr('x') ). With another argument it sets that attribute
to the value supplie (ie. $node->attr('x', 'value')).

=item get_attrs()

get_attrs() returns an array reference to the stored attribute/value pairs
within the node.

=item data()

data() with no arguments returns the data stored in the node B<decoded>. With
one argument, data is stored into the node B<encoded>. To access raw data with
out going through the encoding mechanism, see rawdata().

=item rawdata()

rawdata() is similar to data() but without the encoding/decocing implictly
occuring. Be cautious with this, because you may inadvertently send malformed
xml over the wire if you are not careful to encode your data for transport.

=item insert_tag()

insert_tag() accepts two arguments, with (1) being either the name as a string 
of a new tag to build and then insert into the parent node, or (1) being a 
PXR::Node reference to add to the parents children, and (2) if (1) is a string
then you pass along an optional xmlns to build built into the new child. 
insert_tag() returns either newly created node, or the reference passed in
originally, respectively.

=item to_str()

to_str() returns a string representation of the entire node structure. Note
there is no caching of stringifying nodes, so each operation is expensive. It
really should wait until it's time to serialized to be sent over the wire.

=item get_tag()

get_tag() takes two arguments, (1) the name of the tag wanted, and (2) an 
optional namespace to filter against. Depending on the context of the return 
value (array or scalar), get_tag() either returns an array of nodes match the 
name of the tag/filter supplied, or a single PXR::Node reference that matches,
respectively.

=item detach_from_parent()

detach_from_parent() takes the current node and all of its children and 
separates from its parent node. Returns itself.

=item get_children()

get_children() returns an array reference to all the children of that node.

=item get_children_hash()

get_children_hash() returns a hash reference to all the children of that node.
Note: for more than one child with the same name, the entry in the hash will be
an array reference.

=back

=head1 BUGS AND NOTES

Currently nodes are not ordered because they are stored in a hash. For 
sufficiently large node structures the hash O(1) access times will outweigh 
memory and speed of arrays, especially for linear searches. Each node is tagged
with an internal ID number that will of course cause conflicts around integer 
limit on your specific platforms. These IDs are to provide ordering upon 
stringifying, but current to_str() does not take that into account. Order 
B<is> preserved for multiple tags of the same name since they are stored in an
array. Implementation may one day move to a pseudohash (ordered associative
array usually by index being in the first element of the array) to preserve
order intrinsicly instead of by some unreliable ID method (And also if there is
a strong enough implementation that doesn't slow down regular hashes/arrays).

=head1 AUTHOR

Copyright (c) 2003 Nicholas Perez. Released and distributed under the GPL.

=cut

