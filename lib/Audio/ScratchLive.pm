package Audio::ScratchLive;
{
    use strict;
    use warnings;
    use Carp;
    use File::Spec;
    use File::Slurp;
    
    use Audio::ScratchLive::Constants;
    use Audio::ScratchLive::Track;
    
    use vars qw( $VERSION );
    $VERSION = '0.04';
    
    #**************************************************************************
    # constructor
    #   -- takes in a hash of parameter values
    #**************************************************************************
    sub new {
        my ( $class, %args ) = @_;
        
        my $self = {
            _version => '',
            _header => [],
            _type => Audio::ScratchLive::Constants::DB,
            _file => '',
            _tracks => [],
        };
        unless ( bless $self, $class ) {
            carp( "Error creating new Audio::ScratchLive object" );
            return 0;
        }

        unless ( exists($args{'filename'}) ) {
            carp( "Must supply a hash keyed 'filename'." );
            return 0;
        }
        return 0 unless $self->set_filename( $args{'filename'} );
        return $self;
    }
    
    #**************************************************************************
    # get_headers()
    #   -- returns the header info in this particular file
    #**************************************************************************
    sub get_headers {
        my $self = shift;
        return $self->{_header};
    }

    #**************************************************************************
    # get_num_tracks()
    #   -- returns the number of tracks found in this particular file
    #**************************************************************************
    sub get_num_tracks {
        my $self = shift;
        return scalar(@{$self->{_tracks}});
    }

    #**************************************************************************
    # get_tracks()
    #   -- returns a reference to an array of ScratchLive::Track objects
    #**************************************************************************
    sub get_tracks {
        my $self = shift;
        return $self->{_tracks};
    }

    #**************************************************************************
    # get_type()
    #   -- returns the type (DB/crate)
    #**************************************************************************
    sub get_type {
        my $self = shift;
        return 'crate' if $self->{_type} == Audio::ScratchLive::Constants::CRATE;
        return 'database';
    }

    #**************************************************************************
    # get_version()
    #   -- returns the version info for the file
    #**************************************************************************
    sub get_version {
        my $self = shift;
        return $self->{_version};
    }

    #**************************************************************************
    # parse()
    #   -- goes through and parses the file for its contents.  0 on fail
    #**************************************************************************
    sub parse {
        my $self = shift;
        
        #slurp the file
        my $buffer = read_file( $self->{'_file'}, binmode => ':raw' );
        
        #what we'll use to store stuff
        my $key = q(); #store the key of the key->value pairs
        my $len = 0; #store the length of the value
        my $val = q(); #store the value of the key->value pairs
        
        #read the version (first in all files) 4 bytes = 'vrsn'
        return premature_eof() unless length $buffer >= 4;
        $key = substr( $buffer, 0, 4, '' );
        unless ( lc($key) eq 'vrsn' ) {
            carp( "File doesn't start with 'vrsn' are you sure it's a SL file?" );
            return 0;
        }
        return premature_eof() unless length $buffer >= 4;
        $len = unpack( 'N', substr( $buffer, 0, 4, '' ) );
        return premature_eof() unless length $buffer >= $len;
        $val = substr( $buffer, 0, $len, '' );
        $self->{'_version'} .= sprintf( '%c', $_ ) for unpack( 'n*', $val );
        $self->{'_version'} = '' unless $self->{'_version'};
        unless ( $self->{'_version'} =~ /(?:Crate|Database)/ ) {
            carp( "File's version doesn't look right to me!" );
            return 0;
        }
        $self->{_type} = Audio::ScratchLive::Constants::CRATE
            if $self->{_version} =~ /Crate/;
            
        #now we know if we're dealing with a crate or the DB, get the info
        while ( length( $buffer ) > 4 ) {
            $key = substr( $buffer, 0, 4, '' );
            return premature_eof() unless length $buffer >= 4;
            $len = unpack( 'N', substr( $buffer, 0, 4, '' ) );
            return premature_eof() unless length $buffer >= $len;
            $val = substr( $buffer, 0, $len, '' );
            if ( $key eq 'otrk' ) {
                ##get the length of the track data
                my $track = Audio::ScratchLive::Track->new(
                    'buffer' => $val,
                    'type' => $self->{_type}
                );
                unless ( $track ) {
                    carp( "Error creating new track record. $!" );
                    return 0;
                }
                push @{$self->{'_tracks'}}, $track;
            }
            elsif ( $key eq 'osrt' or $key eq 'ovct' ) {
                unless ( $self->parse_crate_info( $key, $val ) ) {
                    carp( "Error parsing osrt info: $!" );
                    return 0;
                }
            }
            else {
                carp( "unknown key: $key" );
                return 0;
            }
        }
        return 1;
    }

    #**************************************************************************
    # parse_crate_info( $key, $buffer )
    #   -- parse some of the crate header information...
    #**************************************************************************
    sub parse_crate_info {
        my ( $self, $key, $buffer ) = @_;
        $key = lc(_trim($key));
        unless ( length($key) == 4 ) {
            carp("Invalid key: $key for crate header info");
            return 0;
        }
        unless( defined($buffer) and length($buffer) ) {
            carp( "Value buffer has no size" );
            return 0;
        }
        my $href = {
            $key => {},
        };
        while ( length($buffer) > 4 ) {
            #get the key
            my $k = substr( $buffer, 0, 4, '' );
            #now we need the length in bytes of the value
            my $len = unpack('N',substr($buffer,0,4,''));
            my $val = '';
            my $type = Audio::ScratchLive::Constants->header_type($k, $self->{_type});
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
                carp( "Unknown type:\n $!" );
                return 0;
            }
            $href->{$key}->{$k} = $val;
        }
        push @{$self->{'_header'}}, $href;
        return 1;
    }

    #**************************************************************************
    # premature_eof()
    #   -- set a common error and return 0
    #**************************************************************************
    sub premature_eof {
        carp( "We reached the end of the file before we expected. Bad file?" );
        return 0;
    }
    
    #**************************************************************************
    # set_filename( $file )
    #   -- takes in a filename and makes sure it exists. if so, sets it
    #**************************************************************************
    sub set_filename {
        my ( $self, $file ) = @_;
        unless ( defined($file) and length($file) ) {
            carp( "No file provided" );
            return 0;
        }
        $file = File::Spec->rel2abs( $file );
        unless ( -e $file and -f $file ) {
            carp( "File doesn't exist or is not a regular file." );
            return 0;
        }
        unless ( -r $file and -s $file ) {
            carp( "File can't be read or has no size." );
            return 0;
        }
        $self->{'_file'} = $file;
        $self->{'_tracks'} = [];
        $self->{'_version'} = '';
        $self->{'_type'} = Audio::ScratchLive::Constants::DB;
        return 1;
    }

    #**************************************************************************
    #  _trim( $input )
    #   -- trims the beginning and trailing spaces
    #**************************************************************************
    sub _trim {
        my $input = shift;
        return '' unless defined($input) and length($input);
        $input =~ s/^\s+//;
        $input =~ s/\s+$//;
        return $input;
    }

}
1;
__END__

=head1 NAME

Audio::ScratchLive - Simple way to read/write ScratchLIVE crates and databases

=head1 SYNOPSIS

    use Audio::ScratchLive;
    my $sl = WWW::ScratchLive->new( filename => '/path/Reggae.crate' )
        or die $!;

=head1 DESCRIPTION

This class provides a way to open and parse ScratchLIVE's binary crate and database files.

=head2 METHODS

=over 

=item new( HASH )

The C<new> method returns an object of type Audio::Scratchlive if everything was successful, and 0 otherwise. Upon failure, $! is set containing the error and a 0 is returned.

The following are the accepted input parameters:

=over

=item filename

The path to a crate or database file

=back

=item parse()

The C<parse> method reads through the file you provided, getting the header and track information. 1 on success, 0 otherwise. $! is set containing any error messages.

=over

=back

=item get_headers()

Returns the header info (array-ref) found in the file you provided after using C<parse>

=over

=back

=item get_num_tracks()

Returns the number of tracks found in the file you provided after using C<parse>

=over

=back

=item get_tracks()

Returns a reference to an array of Audio::ScratchLive::Track objects. Provided after using C<parse>

=over

=back

=item get_type()

After running C<parse>, this will tell you whether you provided a 'crate' or a 'database' file.

=over 

=back

=item get_version()

Returns the string version of the database or crate file you provided after using C<parse>

=over

=back



=item set_filename( $path )

Provides a way to clear any parsed information and setup the object again like new for parsing a new file. Returns 0 and sets $! on failure.

=over 

=back

=back


=head1 EXAMPLES

=head2 parse a file

    #!/usr/bin/perl
    use strict;
    use warnings;
    use Audio::ScratchLive;
    my $sl = Audio::ScratchLive->new( 'filename' => '/path/to/Reggae.crate' )
        or die $!;
    $sl->parse() or die $!
    
    print "Found ", $sl->get_num_tracks(), " tracks\n";
    
    #each track is an Audio::ScratchLive::Track object
    my $count = 0;
    my $a_tracks = $sl->get_tracks();
    for my $track ( @{$a_tracks} ) {
        print "Info for track ", ++$count, "\n";
        my $a_keys = $track->get_keys();
        for my $key ( @{$a_keys} ) {
            print $key, " == ", $track->get_value($key), "\n";
        }
        print "\n";
    }

=head1 SUPPORT

Please visit EFNet #perl for assistance with this module. "genio" is the author.

=head1 CAVEATS

Not enough test cases built into the install yet.  More to be added.

No way yet to cleanly access the tracks.

A few of the fields for the tracks in a DB file are still unknown as to what they do.

The fields at the beginning of a crate file aren't yet parsed, I kind of skip them to just get the track information.

No way to write crate or DB files yet.

A lot of other problems probably.

Not enough documentation.

=head1 SEE ALSO

    Author's Web site that will eventually contain a cookbook
    L<http://www.cwhitener.org>
    
    Rane/Serato's ScratchLIVE web site (with forums)
    L<http://www.scratchlive.net>

    ScratchTools (Java app)
    L<http://www.scratchtools.de>

    
=head1 AUTHORS

Chase Whitener <cwhitener at gmail dot com>

Thanks to:

q[Caelum] (EFNet #perl) - Finding and fixing the Solaris problem.

=head1 COPYRIGHT

Copyright 2009, Chase Whitener. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

