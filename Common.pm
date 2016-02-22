package Common;

use strict;

use XML::Simple;
use File::Type;
use Digest::MD5;

BEGIN 
{   
    use Exporter;
    our @ISA = qw( Exporter );
    our @EXPORT = qw(
        &remove_prefix              &remove_duplicates
        &trim                       &root_dir					
        &date_time_stamp            &file_mod_time
        &read_file					        &file_title 
        &list_max                   &file_mime_type                                 
        &time_stamp                 &md5sum
        &run_command				       
        );    
}

# Function to return the root directory of the passed in file path
# e.g. c:\test\somefile should return c:\test
#
sub root_dir
{
	my $path = shift;
	
	$path =~ s/\\/\//g;

	return $path if -d $path;

	my @dirs = split "/", $path;
	
	$dirs[$#dirs] = undef;
	
	return join "/", @dirs;
}

# Function to calculate md5sum of the specified file
#
sub md5sum
{
    my $file = shift;
    my $digest = undef;

    eval
    {
        open(FILE, $file) or die "Can't open file $file\n";
        my $ctx = Digest::MD5->new;
        $ctx->addfile(*FILE);
        $digest = $ctx->hexdigest;
        close(FILE);
    };

    $@ ? return undef : return $digest;
}

# Function to return the MIME type of a file
#
sub file_mime_type
{
    my $file = shift;
    my $ft = File::Type->new();
    my $type = $ft->checktype_filename($file);
    chomp $type;
    return trim($type);
}

# Function to read a file and copy the contents of the file in the variable to
# which a reference is provided. Note: Memory usage depends on file size.
#
sub read_file
{
    my ($file, $ref) = @_;
	
    my $msg = (caller 0)[3] . "(): Bad function call from " . (caller 1)[3] . "()\n";
    my $ref_type = ref $ref;
    
    eval
    {
        die $msg . "$file does not exist." if not -e $file;
        die $msg . "Reference not passed in." if (not $ref);
        die $msg . "Need reference to a list." if (not $ref_type =~ /ARRAY/);
        
        open IN, "<$file" or die "Open failed. " . $!;
        @$ref = <IN>;
        close IN;
    };
    
    $@ ? return undef : return 1 ;
}

# Functions to return the current date/time and the current time
#
sub date_time_stamp
{
    my ($sec, $min, $hour, $mday, $mon, $year) = localtime(time);
    return sprintf "%04d%02d%02d-%02d%02d%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec;
}
sub time_stamp
{
    my ($sec, $min, $hour, $mday, $mon, $year) = localtime(time);
    return sprintf "%02d:%02d:%02d", $hour, $min, $sec;
}

# Function to remove :: and preceeding string from param
#
sub remove_prefix
{
    my $str = shift;
    ($str =~ /::/) ? return remove_prefix(substr($str, (index $str, "::") + 2)) : return $str; 
}

# Function to remove duplicates from a list
# WARNING order of list will be disregarded
#
sub remove_duplicates
{
    my %hash = map { $_ => 1 } @_;
    return keys %hash;
}

# Function to remove whitespace from the start and end of the string
# Also remove combinations of newline and white spaces
#
sub trim
{   
	my @in = @_;
	my @out = ();
	
	foreach my $str (@in)
	{
		$str =~ s/^\s+//;
		$str =~ s/\s+$//;
		push @out, $str;
	}
	
	return wantarray ? @out : $out[0];
}
	
# Function to return the modification time of a file
#
sub file_mod_time
{
    my ($file) = @_;
    my $mod = (stat($file))[9];
    return scalar localtime $mod;
}

# Function to return the filename when a full/relative is path is passed in.
# E.g. c:/somedir/somefile.txt or ../somefile.txt should return somefile.txt
#
sub file_title
{
    my $path = shift;
    $path =~ s/\\/\//g; # convert all \ to /
    my @temp = split "/", $path;
    return $temp[$#temp];
}

# Function to return maximum value in a list
#
sub list_max
{
    my $max = shift;
    my @list = @_;
    foreach (@list)
    {
        $max = $_ if ($_ > $max);
    }
    return $max;
}

# Function to run a command.
# Timeout can be optionally passsed in with command string.
# Returns exit code and output as scalars in a list of 2 elements.
# Returns undef as exit code if command failed. The error message (if any) is in output.
# Error message is "Timeout" if timeout is reached.
#
sub run_command
{
    local $SIG{ALRM} = sub { die "Timeout" };
    
    my ($cmd, $timeout) = @_;
    my $output;
    my $msg = (caller 0)[3] . ": Bad function call from " . (caller 1)[3] . "()\n";
    
    $timeout = 0 if not $timeout;
	
    eval
    {
        die $msg . "Command not passed in.\n" if not $cmd;
        alarm($timeout);
        $output = qx{$cmd 2>&1};
        alarm(0);
    };

    $@ ? return (undef, $@) : return ($? >> 8, $output);
}


1;