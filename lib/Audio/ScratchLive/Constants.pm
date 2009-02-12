{
	package Audio::ScratchLive::Constants;
	use strict;
	use warnings;
	use Carp;
	use constant DB => 0;
	use constant CRATE => 1;

	BEGIN {
		use vars qw( %VRSN %TRACK $VERSION );
		$VERSION = '0.1';
		%VRSN = (
			CRATE => '1.0/Serato ScratchLive Crate',
			DB => '2.0/Serato Scratch LIVE Database',
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
