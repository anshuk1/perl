use strict;

use MP3::Tag;

my @mp3s = <*.mp3>;
my ($title, $track, $artist, $album);
my $mp3;
my $newname;

foreach (@mp3s)
{
    $mp3 = MP3::Tag->new($_);
    ($title, $track, $artist, $album) = $mp3->autoinfo();
    (length($track) == 1)? $newname = "0$track - $title" : $newname = "$track  - $title";
    print "Renaming $_ to $newname";
    if(rename $_, "\"" . ucfirst $newname . ".mp3\"")
    {
        print " - Successful\n";
    }
    else
    {
        print " - Failed\n";
    }
}


