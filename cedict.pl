#!/usr/bin/perl -w

open FILE, "<cedict_ts.u8";
my @lines = <FILE>;

# The clean solution was to provide a generic interface to map Perl arrays onto sexps
# unfortunetaly my knowledge about Perl is too limited.

print "'(\n";
foreach (@lines)
{
    #remove comments
    my ($line) = $_ =~ /^([^#]*).*$/;
    if ( ! ($line =~ /^$/) )
    {
	# Not very efficient, but needs to be done only once
	$line =~ s/\"/\\\"/g;
	my ($zh,$py,$en) = $line =~ /^\s*([^\[]+)\[\s*([^\]]+)\]\s*\/(.*)\/?$/;
	my @zh = split(/\s+/, $zh);
	my @py = split(/\s+/, $py);
	my @en = split(/\//, $en);
	@zh = map { "\"$_\"" } @zh;
	@py = map { "\"$_\"" } @py;
	@en = map { "\"$_\"" } @en;
	$zh = "(".join(" ",@zh).")";
	$py = "(".join(" ",@py).")";
	$en = "(".join(" ",@en).")";
	my $all = "(".join(" ", ($zh, $py, $en)).")";
	print "$all\n";
    }
}

print ")\n";

