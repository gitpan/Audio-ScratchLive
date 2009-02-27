{
    package Audio::ScratchLive::Constants;
    use strict;
    use warnings;
    use Carp;
    use constant DB => 0;
    use constant CRATE => 1;

    BEGIN {
        use vars qw( %VRSN %HEADER %TRACK $VERSION );
        $VERSION = '0.03';
        %VRSN = (
            CRATE => '1.0/Serato ScratchLive Crate',
            DB => '2.0/Serato Scratch LIVE Database',
        );
        %HEADER = (
            CRATE => {
                tvcn => {type => 'string', description => '', default => 'song',},
                brev => {type => 'int(1)', description => '', default => 1,},
                tvcw => {type => 'char', description => '', default => ' ',},
            },
            DB => {},
        );
        %TRACK = (
            CRATE => {
                ptrk => {type => 'string', description => 'path to the track', default => 'C:/mp3/test.mp3',},
            },
            DB => {
                ttyp => {type => 'string', description => 'file type (ie: mp3)', default => 'mp3',},
                pfil => {type => 'string', description => 'file path', default => 'C:/mp3/test.mp3',},
                tsng => {type => 'string', description => 'Song name', default => 'test',},
                tart => {type => 'string', description => 'artist name', default => '',},
                tgen => {type => 'string', description => 'genre', default => '',},
                talb => {type => 'string', description => 'album name', default => '',},
                tcom => {type => 'string', description => 'comments from ID3 tag', default => '',},
                ttyr => {type => 'string', description => 'year released', default => '',},
                tlbl => {type => 'string', description => 'label released on', default => '',},
                tcmp => {type => 'string', description => 'Composer', default => '',},
                tgrp => {type => 'string', description => 'Group', default => '',},
                tlen => {type => 'string', description => 'length', default => '',},
                tbpm => {type => 'string', description => 'Beats Per Minute', default => '',},
                tsiz => {type => 'string', description => 'File size', default => '0MB',},
                tbit => {type => 'string', description => 'Bitrate', default => '128.0kbps',},
                tsmp => {type => 'string', description => '', default => '44.1k',},
                tadd => {type => 'string', description => 'Date and Time added to SL', default => '1/01/1990 12:30:00 PM',},
                uadd => {type => 'int(4)', description => '', default => 1232238714,},
                utkn => {type => 'int(4)', description => '', default => 0,},
                ulbl => {type => 'int(4)', description => '', default => 16777215,},
                ufsb => {type => 'int(4)', description => '', default => 2822441,},
                utme => {type => 'int(4)', description => '', default => 1232252053,},
                udsc => {type => 'int(4)', description => '', default => 0,},
                sbav => {type => 'char', description => '', default => ' ',},
                bhrt => {type => 'int(1)', description => '', default => 1,},
                bmis => {type => 'int(1)', description => '', default => 0,},
                bply => {type => 'int(1)', description => '', default => 0,},
                blop => {type => 'int(1)', description => '', default => 0,},
                bitu => {type => 'int(1)', description => '', default => 0,},
                bovc => {type => 'int(1)', description => '', default => 1,},
                bcrt => {type => 'int(1)', description => '', default => 0,},
                biro => {type => 'int(1)', description => '', default => 0,},
                bwlb => {type => 'int(1)', description => '', default => 0,},
                bwll => {type => 'int(1)', description => '', default => 0,},
                buns => {type => 'int(1)', description => '', default => 0,},
            },
        );
    }

    sub header_default {
        my ($class, $key, $type) = @_;
        $key = '' unless defined($key) and length($key);
        $type = -1 unless defined($type) and length($type);
        $key = lc($key);
        $type = ($type == CRATE)? 'CRATE': 'DB';
        if ( exists($HEADER{$type}->{$key}->{'default'}) and defined($HEADER{$type}->{$key}->{'default'}) ) {
            return $HEADER{$type}->{$key}->{'default'};
        }
        carp( "Error, no such $key.  Notify author or add to Constants.pm" );
        return 0;
    }
    sub header_description {
        my ($class, $key, $type) = @_;
        $type = -1 unless defined($type) and length($type);
        $key = '' unless defined($key) and length($key);
        $type = ($type == CRATE)? 'CRATE': 'DB';
        $key = lc($key);
        if ( exists($HEADER{$type}->{$key}->{'description'}) and defined($HEADER{$type}->{$key}->{'description'}) ) {
            return $HEADER{$type}->{$key}->{'description'};
        }
        carp( "Error, no such $key.  Notify author or add to Constants.pm" );
        return 0;
    }
    sub header_keys {
        my ($class, $type) = @_;
        $type = -1 unless defined($type) and length($type);
        $type = ($type == CRATE)? 'CRATE': 'DB';
        my @array = sort keys %{$HEADER{$type}};
        return \@array;
    }
    sub header_type {
        my ($class, $key, $type) = @_;
        $key = '' unless defined($key) and length($key);
        $type = -1 unless defined($type) and length($type);
        $key = lc($key);
        $type = ($type == CRATE)? 'CRATE': 'DB';
        if ( exists($HEADER{$type}->{$key}->{'type'}) and defined($HEADER{$type}->{$key}->{'type'}) ) {
            return $HEADER{$type}->{$key}->{'type'};
        }
        carp( "Error, no such $key. Notify author or add to Constants.pm" );
        return 0;
    }
    sub track_default {
        my ($class, $key, $type) = @_;
        $key = '' unless defined($key) and length($key);
        $type = -1 unless defined($type) and length($type);
        $key = lc($key);
        $type = ($type == CRATE)? 'CRATE': 'DB';
        if ( exists($TRACK{$type}->{$key}->{'default'}) and defined($TRACK{$type}->{$key}->{'default'}) ) {
            return $TRACK{$type}->{$key}->{'default'};
        }
        carp( "Error, no such $key.  Notify author or add to Constants.pm" );
        return 0;
    }
    sub track_description {
        my ($class, $key, $type) = @_;
        $type = -1 unless defined($type) and length($type);
        $key = '' unless defined($key) and length($key);
        $type = ($type == CRATE)? 'CRATE': 'DB';
        $key = lc($key);
        if ( exists($TRACK{$type}->{$key}->{'description'}) and defined($TRACK{$type}->{$key}->{'description'}) ) {
            return $TRACK{$type}->{$key}->{'description'};
        }
        carp( "Error, no such $key.  Notify author or add to Constants.pm" );
        return 0;
    }
    sub track_keys {
        my ($class, $type) = @_;
        $type = -1 unless defined($type) and length($type);
        $type = ($type == CRATE)? 'CRATE': 'DB';
        my @array = sort keys %{$TRACK{$type}};
        return \@array;
    }
    sub track_type {
        my ($class, $key, $type) = @_;
        $type = -1 unless defined($type) and length($type);
        $type = ($type == CRATE)? 'CRATE': 'DB';
        $key = '' unless defined($key) and length($key);
        $key = lc($key);
        if ( exists($TRACK{$type}->{$key}->{'type'}) and defined($TRACK{$type}->{$key}->{'type'}) ) {
            return $TRACK{$type}->{$key}->{'type'};
        }
        carp( "Error, no such $key.  Notify author or add to Constants.pm" );
        return 0;
    }
    sub version_default {
        my ($class, $type) = @_;
        $type = -1 unless defined($type) and length($type);
        $type = ($type == CRATE)? 'CRATE': 'DB';
        if ( exists($VRSN{$type}) and defined($VRSN{$type}) ) {
            return $VRSN{$type};
        }
        return '';
    }
}
1;
__END__

=head1 NAME

Audio::ScratchLive::Constants - Some information needed by the Audio::ScratchLive module

=head1 SYNOPSIS

    use Audio::ScratchLive::Constants;

    Two constants directly usable:
    Audio::ScratchLive::Constants::DB
    Audio::ScratchLive::Constants::CRATE

    Since there are two types of files ScratchLIVE creates for their database of
    information, we need to know which one we're dealing with. 
    This helps us resolve that issue.

    Each type of database has its own information that gets stored that the other
    type does not.  To find out what should be getting stored in each of these
    types of database, we use the accessors available below.

=head1 DESCRIPTION

This library provides some constants and some accessor subroutines needed for all types of ScratchLIVE database information.

=head2 METHODS

=over 

=item header_default( $key, $type )

The C<header_default> function returns a scalar value representing what I've found to be a default value for the key->value pairs supplied at the beginning of some database files.  Upon error it warns and returns 0.

=over

=item key

Defaults to ''.  Looks in the constants for the key matching the SCALAR you provided here and returns its default value.

=item type

This tells us what type of DB we're dealing with.  Since the key->value pairs are different for each type, we need to know what type we're dealing with: Audio::ScratchLive::Constants::DB or Audio::ScratchLive::Constants::CRATE. DB is default

=back

=item header_description( $key, $type )

The C<header_description> subroutine returns a scalar string value describing what the value of the key->value pair contains in human words.  A lot of the key->value pairs don't have descriptions because I haven't yet found out what they're for.  I will take all corrections and additions on this. Upon error, it warns and returns 0.

=over

=item key

Defaults to ''.  This is the key of the key->value pair you want a description for.

=item type

Defaults to Audio::ScratchLive::Constants::DB.  The other acceptable value is Audio::ScratchLive::Constants::CRATE
 
=back

=item header_keys( $type )

The C<header_keys> method returns a sorted reference to an array of the header field keys for this type of DB.  You can then go through the keys and request the value for that given key.

=over

=item type

Audio::ScratchLive::Constants::DB is default. Audio::ScratchLive::Constants::CRATE is the other choice

=back

=item header_type( $key, $type )

the C<header_type> method tells you the data type of the value for the given key->value pair.  B<char>, B<int(4)>, B<int(1)>, and B<string> are the possible types returned.  Upon error, it warns and returns 0.

=over

=item key

Defaults to ''.  This is the key of the key->value pair you want a data-type for.

=item type

Defaults to Audio::ScratchLive::Constants::DB.  The other acceptable value is Audio::ScratchLive::Constants::CRATE

=back

=item track_default( $key, $type )

The C<track_default> subroutine returns a scalar value representing what I've found to be a default value for the key->value pairs supplied in the database. Upon error it warns and returns 0.

=over

=item key 

Defaults to ''.  Looks in the constants for the key matching the SCALAR you provided here and returns its default value.

=item type

This tells us what type of DB we're dealing with.  Since the key->value pairs are different for each type, we need to know what type we're dealing with: Audio::ScratchLive::Constants::DB or Audio::ScratchLive::Constants::CRATE. DB is default

=back

=item track_description( $key, $type )

The C<track_description> subroutine returns a scalar string value describing what the value of the key->value pair contains in human words.  A lot of the key->value pairs don't have descriptions because I haven't yet found out what they're for.  I will take all corrections and additions on this. Upon error, it warns and returns 0.

=over

=item key

Defaults to ''.  This is the key of the key->value pair you want a description for.

=item type

Defaults to Audio::ScratchLive::Constants::DB.  The other acceptable value is Audio::ScratchLive::Constants::CRATE

=back

=item track_keys( $type )

The C<track_keys> method returns a sorted reference to an array of the field keys for this type of track.  You can then go through the keys and request the value for that given key.

=over

=item type

Audio::ScratchLive::Constants::DB is default. Audio::ScratchLive::Constants::CRATE is the other choice

=back

=item track_type( $key, $type )

the C<track_type> method tells you the data type of the value for the given key->value pair.  B<char>, B<int(4)>, B<int(1)>, and B<string> are the possible types returned.  Upon error, it warns and returns 0.

=over

=item key

Defaults to ''.  This is the key of the key->value pair you want a data-type for.

=item type

Defaults to Audio::ScratchLive::Constants::DB.  The other acceptable value is Audio::ScratchLive::Constants::CRATE

=back

=item version_default( $type )

The C<version_default> subroutine returns the default version string for either a crate or DB file.

=over

=item type

Defaults to Audio::ScratchLive::Constants::DB.  The other acceptable value is Audio::ScratchLive::Constants::CRATE

=back

=back


=head1 SUPPORT

Please visit EFNet #perl for assistance with this module. "genio" is the author.

=head1 CAVEATS

Not enough test cases built into the install yet.  More to be added.

A lot of other problems probably.

Not enough documentation.

=head1 SEE ALSO

    Author's Web site that will eventually contain a cookbook
    L<http://www.cwhitener.org>

    Rane/Serato's ScratchLIVE website with forums
    L<http://www.scratchlive.net>
    
    ScratchTools (Java app)
    L<http://www.scratchtools.de>

    
=head1 AUTHORS

Chase Whitener <cwhitener at gmail dot com>

=head1 COPYRIGHT

Copyright 2009, Chase Whitener. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

