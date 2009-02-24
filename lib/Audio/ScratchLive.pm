package Audio::ScratchLive;
{
    use 5.008001;
    use strict;
    use warnings;
    use Carp;
    use File::Spec;
    use Fcntl ':flock';
    
    use Audio::ScratchLive::Constants;
    use Audio::ScratchLive::Track;
    
    use vars qw( $VERSION );
    $VERSION = '0.02';
    
    #**************************************************************************
    # constructor
    #   -- takes in a hash of parameter values
    #**************************************************************************
    sub new {
        my ( $class, %args ) = @_;
        
        my $self = {
            _version => '',
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
        
        #open, lock, set in binmode
        #Had to add the +< mode for Solaris.  Thanks q[Caelum]!
        open( my $fh, '+<', $self->{'_file'} )
            or carp( "Error opening file. $!" ) && return 0;
        flock( $fh, LOCK_EX ) or carp( "Couldn't aquire lock $!" ) && return 0;
        binmode( $fh );

        #read the version (first in all files) 4 bytes = 'vrsn'
        sysread( $fh, my $buffer, 4 ) or carp("Premature EOF") && return 0;
        if ( lc($buffer) ne 'vrsn' ) {
            carp( "File doesn't start with 'vrsn' are you sure it's a SL file?" );
            return 0;
        }
        sysread( $fh, my $len, 4 ) or carp("Premature EOF") && return 0;
        sysread( $fh, $buffer, unpack('N',$len)) or carp("Premature EOF") && return 0;
        $self->{'_version'} .= sprintf( '%c', $_ ) for unpack('n*',$buffer);
        $self->{'_version'} = '' unless $self->{'_version'};
        if ( $self->{'_version'} !~ /(?:Crate|Database)/ ) {
            carp( "File's version doesn't look right to me!" );
            return 0;
        }
        $self->{_type} = Audio::ScratchLive::Constants::CRATE
            if $self->{_version} =~ /Crate/;
        #now we know if we're dealing with a crate or the DB, get the info
        while ( sysread( $fh, $buffer, 4 ) != 0 ) {
            sysread( $fh, $len, 4 ) or carp("Premature EOF") && return 0;
            sysread( $fh, my $val, unpack('N',$len) ) or carp("Premature EOF") && return 0;
            if ( $buffer eq 'otrk' ) {
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
            
        }
        return 1;
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


}
1;
__END__

=head1 NAME

Audio::ScratchLive v0.02 - this class provides simple way to read/write ScratchLIVE crates and databases

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

