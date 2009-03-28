package Audio::ScratchLive::Track;
{
    use strict;
    use warnings;
    use Exporter;
    use Carp;
    use Audio::ScratchLive::Constants;
    
    use vars qw( @ISA $VERSION @EXPORT @EXPORT_OK );
    
    @ISA = qw( Exporter );
    $VERSION = '0.03';
    
    #**************************************************************************
    # new( %hash )
    #    -- CONSTRUCTOR
    #**************************************************************************
    sub new {
        my ( $class, %args ) = @_;
        my $buffer = '';
        my $empty = 0;
        my $type = -1;
        $type = $args{'type'}
            if exists($args{type}) and defined($args{type});
        $buffer = $args{'buffer'}
            if exists($args{'buffer'}) and defined($args{'buffer'});
        $empty = $args{'empty'}
            if exists($args{'empty'}) and defined($args{'empty'});
        $type = Audio::ScratchLive::Constants::DB
            unless ( $type == Audio::ScratchLive::Constants::CRATE );
            
        unless ( $empty or length($buffer) ) {
            carp( "Hash key 'empty' or 'buffer' required! $!" );
            return 0;
        }
        my $self = {
            _fields => {},
            _type => $type,
        };
        unless( bless $self, $class ) {
            carp( "Trouble creating new Audio::ScratchLive::Track object" );
            return 0;
        }
        $self->create_empty();
        unless ( $empty ) {
            unless ( $self->parse_buffer( $buffer ) ) {
                carp( "Error parsing buffer: $!" );
                return 0;
            }
        }
        return $self;
    }
    
    #**************************************************************************
    # create_empty()
    #    -- creates a default track object based on the Constants.pm
    #**************************************************************************
    sub create_empty {
        my $self = shift;
        my $aref = Audio::ScratchLive::Constants->track_keys($self->{_type});
        for my $key (@{$aref}) {
            $self->{_fields}->{$key} =
                Audio::ScratchLive::Constants->track_default( $key, $self->{_type});
        }
        return 1;
    }
    
    #**************************************************************************
    # get_keys()
    #    -- returns a sorted list of the keys for this track
    #**************************************************************************
    sub get_keys {
        my $self = shift;
        my @array = sort keys %{$self->{_fields}};
        return \@array;
    }

    #**************************************************************************
    # get_value( $key )
    #    -- looks at one of the track's keys and returns its value
    #**************************************************************************
    sub get_value {
        my ( $self, $fld ) = @_;
        $fld = '' unless defined($fld) and length($fld);
        $fld = lc($fld);
        if ( exists($self->{_fields}->{$fld}) and defined($self->{_fields}->{$fld}) ) {
            return $self->{_fields}->{$fld};
        }
        warn( "No field called $fld for this track." );
        return '';
    }    

    #**************************************************************************
    # parse_buffer( $buffer )
    #    -- takes the binary data from the file and builds a track object
    #**************************************************************************
    sub parse_buffer {
        my ( $self, $buffer ) = @_;
        unless ( defined($buffer) && length($buffer) ) {
            carp( "buffer has no size" );
            return 0;
        }
        while ( length($buffer) > 4 ) {
            #get the key
            my $key = substr( $buffer, 0, 4, '' );
            #now we need the length in bytes of the value
            my $len = unpack('N',substr($buffer,0,4,''));
            my $val = '';
            my $type = Audio::ScratchLive::Constants->track_type($key, $self->{_type});
            if ( $type eq 'string' ) {
                $val .= sprintf( '%c', $_ )
                    for unpack('n*',substr($buffer,0,$len,''));
            }
            elsif ( $type eq 'int(1)' ) {
                $val = ord(substr($buffer,0,$len,''));
            }
            elsif ( $type eq 'char' ) {
                $val = sprintf('%c',unpack('n',substr($buffer,0,$len,'')) );
            }
            elsif ( $type eq 'int(4)' ) {
                $val = unpack('N',substr($buffer,0,$len,''));
            }
            else {
                carp( "Unknown type: $!" );
                return 0;
            }
            $self->{_fields}->{$key} = $val;
        } 
        return 1;
    }    
}
1;
__END__

=head1 NAME

Audio::ScratchLive::Track - Store Track information from a crate/DB file

=head1 SYNOPSIS

    use Audio::ScratchLive::Track;
    use Audio::ScratchLive::Constants;
    my $slt = WWW::ScratchLive::Track->new(
        empty => 1,
        type => Audio::ScratchLive::Constants::DB
    ) or die $!;

    -OR-

    my $slt = WWW::ScratchLive::Track->new(
        empty => 1,
        type => Audio::ScratchLive::Constants::CRATE
    ) or die $!;
    
    -OR-
    
    my $slt = WWW::ScratchLive::Track->new(
        buffer => $buffer_from_db_file,
        type => Audio::ScratchLive::Constants::DB
    ) or die $!;

    -OR-
    
    my $slt = WWW::ScratchLive::Track->new(
        buffer => $buffer_from_crate_file,
        type => Audio::ScratchLive::Constants::CRATE
    ) or die $!;

=head1 DESCRIPTION

This class provides a way to store track information from ScratchLIVE's binary crate and database files.

=head2 METHODS

=over 

=item new( HASH )

The C<new> method returns an object of type Audio::Scratchlive::Track if everything was successful, and 0 otherwise. Upon failure, $! is set containing the error and a 0 is returned.

The following are the accepted input parameters:

=over

=item empty

Defaults to 0. Provide a true value to create an empty shell of a track and return it.  Otherwise, we'll create the empty shell and then fill in the info from the buffer.

=item buffer

This is the binary information for this particular track from the file. This is required unless you're creating an empty shell of a track.

=item type

This tells us what type of track object we're creating.  DB tracks contain lots of information, CRATE tracks contain only a file path. See Audio::ScratchLive::Constants or the listing of fields.

=back

=item get_keys()

The C<get_keys> method returns a sorted reference to an array of the field keys for this track.  You can then go through the keys and request the value for that given key.

=over

=back

=item get_value( $key )

The C<get_value> method returns the value stored for the requested $key.  If it can't find the $key you've requested, it generates a warning and returns an empty string ''.

=over

=back

=back


=head1 SUPPORT

Please visit EFNet #perl for assistance with this module. "genio" is the author.

=head1 CAVEATS

Not enough test cases built into the install yet.  More to be added.

No way yet to create tracks other than from the crate or DB file.

A few of the fields for the tracks in a DB file are still unknown as to what they do.

No way to output the track data back in binary form for the crate or DB file.

A lot of other problems probably.

Not enough documentation.

=head1 SEE ALSO

    Author's Web site that will eventually contain a cookbook
    L<http://www.cwhitener.org>
    
    Rane/Serato's ScratchLIVE web site and forums
    L<http://www.scratchlive.net>

    ScratchTools (Java app)
    L<http://www.scratchtools.de>

    
=head1 AUTHORS

Chase Whitener <cwhitener at gmail dot com>

=head1 COPYRIGHT

Copyright 2009, Chase Whitener. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

