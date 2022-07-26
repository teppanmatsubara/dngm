#!/usr/bin/perl
#
# dangumi script - perl version
#

use strict;
use utf8;
use POSIX 'ceil';

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

use open IN => ":utf8";
# use open OUT => ":utf8";

################ Config params

my $delimiter = "\t%s";
my $tab = "\t";
my $tablen = 4;
my $enja_ratio = 1.5;
my $ascii_weight = 0.5;
my $japanese_weight = 1;
my $default_comp = 25;

################


my($leftRef, $rightRef); # Ref to array of text lines

my @params;
my $mode = "tab";
my $spacer_char = " ";
my $delim_char = "";
my $compress = "0";

foreach (@ARGV) {
    $compress = ($1 || $default_comp), next if /^-z(\d*)$/;
    $mode = "tab", next if /^-t$/;
    $mode = "space", next if /^-s$/;
    $spacer_char = $1, next if /^-c(\S)$/;
    $delim_char = $1, next if /^-d(.)$/;
    push(@params, $_);
}

$delimiter = sprintf($delimiter, $delim_char);

if ($#params == 1) {
    die "cannot read $params[0]" unless -r $params[0];
    die "cannot read $params[1]" unless -r $params[1];

    ($leftRef, $rightRef) = read_files(@params[0,1]);
} else {
    ($leftRef, $rightRef) = read_stdin();
}


my $maxlen = get_maxlen(@{$leftRef});
my $lmaxrow = get_num_rows(@{$leftRef});
my $rmaxrow = get_num_rows(@{$rightRef});
my $numrows = $lmaxrow > $rmaxrow ? $lmaxrow : $rmaxrow;

for(my $i; $i<$numrows; $i++) {
    if ($mode eq "tab") {
	print_row_tab($leftRef->[$i], $rightRef->[$i], $maxlen);
    } elsif ($mode eq "space") {
	print_row_space($leftRef->[$i], $rightRef->[$i], $maxlen);
    }
}

sub print_row_space {
    my($l, $r, $maxlen) = @_;
    my $l = substr($l . $spacer_char x $maxlen, 0, $maxlen);

    print $l, $delimiter, $r, "\n";
}

sub print_row_tab {
    my($l, $r, $maxlen) = @_;
    my $len = length($l);

    my $target_numtab = ceil(($maxlen + $tablen) / $tablen);
    my $self_numtab = ceil($len / $tablen);
    my $numtab = $target_numtab - $self_numtab;

    my $debug = "";
    # $ debug = "[len=$len, tgt=$target_numtab, self=$self_numtab, numtab=$numtab]";

    print $l, $tab x $numtab, $delimiter, $r, "$debug\n";
}

sub get_num_rows {
    $#_ + 1;
}

sub get_maxlen {
    my $max;
    
    foreach (@_) {
	$max = length($_) if length($_) > $max;
    }

    $max;
}

sub read_files {
    my ($left, $right) = @_;
    my (@l, @r);

    open(F, $left) || die;
    @l = <F>;
    chomp(@l);
    close(F);

    open(F, $right) || die;
    @r = <F>;
    chomp(@r);
    close(F);

    @l = compress(@l) if $compress;
    @r = compress(@r) if $compress;

    (\@l, \@r);
}

sub read_stdin {
    my @l;
    my @r;
    my $x = \@l;
    while ($_ = <STDIN>) {
	chomp;
	$x = \@r, next if /^\|\|/; # sitching to a right section
	push(@{$x}, $_);
    }

    @l = compress(@l) if $compress;
    @r = compress(@r) if $compress;

    (\@l, \@r);
}

sub compress {
    return compress_by_token(@_) if is_english(@_);

    my $s = join("", @_);

    my $maxcnt = int($compress / $enja_ratio);
    my $cnt = 0;
    my @ret;
    my @chars;
    
    foreach (split(//, $s)) {
     	push(@chars, $_);
	if (/[A-z]/) {
	    $cnt += $ascii_weight;
	} else {
	    $cnt += $japanese_weight;
	}
     	if ($cnt >= $maxcnt) {
     	    push(@ret, join("", @chars));
     	    @chars = ();
     	    $cnt = 0;
     	}
     }
     push(@ret, join("", @chars)) if @chars;

     @ret;
}

sub compress_by_token {
    return @_ unless $compress;

    my @words = split(/\s+/, join(" ", @_));
    my @ret;

    my $len;
    my @line;

    foreach my $l (@words) {
	push(@line, $l);
	$len += length($l);
	if ($len >= $compress) {
	    push(@ret, join(" ", @line));
	    @line = ();
	    $len = 0;
	}
    }
    push(@ret, join(" ", @line)) if @line;

    @ret;
}

sub is_english {
    my @s = split(/[\s\W]/, join(" ", @_));
    my @x = grep(/^([A-z\d]+)$/, @s);

    my $total = $#s + 1;
    my $token = $#x + 1;

    my $threshold = 0.6;
    my $english = $token > $total * $threshold ? 1 : 0;


    # print "total=$total\n";
    # print "token=$token\n";
    # print "english=$english\n";

    $english;
}
