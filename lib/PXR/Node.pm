package PXR::Node;

use warnings;
use strict;

use constant tagname => 0;
use constant attrs => 1;
use constant tagdata => 2;
use constant kids => 3;
use constant tagparent => 4;
use constant id => 5;

our $VERSION = '0.1';

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
	my $self = shift;
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

	my $self = shift;
	
	if (my $data = shift) 
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

	my $self = shift;
	if (my $data = shift) {
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
