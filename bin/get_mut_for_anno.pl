#!/usr/bin/perl -w
use strict;

my ( $pre ) = @ARGV;

open IN, "$pre.mut.filted.txt";
open IN1, "$pre.mut";
open OUT, ">$pre.mut.filted.anno";
print OUT "chr\tstart\tend\tref\talt\tallele_frq\talt_total_depth\tformat\n";

my %muts;
while (<IN1>) {
    chomp;
    my @info = split;
    my $line = $_;
    $muts{$info[2]}  = $line;
}
close IN1;

my %hash = ('5' => "T", '6' => "C", '7' => "G", '8' => "A");
my %hash1 = ('T' => "5", 'C' => "6", 'G' => "7", 'A' => "8");
for my $k ( sort keys %hash ) {
    print "$k\t$hash{$k}\n";
}
my %nearby;
my $format = "";
while (<IN>) {
    chomp;
    my @info = split;
    my $line = $_;
    next if  ( /Pos/ );
    next if ( $info[4] == 0 and $info[9] == 0 and $info[10] == 0 );
    #next if ( ( $line =~ /[DI]/ and $#info >= 14 ) or $#info < 12 );
    #next if ( $#info >= 14 or $#info < 12 );
    next if ( $info[1] eq "N" );
    my $ftype = ( split /:/, $info[12] )[0];
    for my $i ( 12..$#info ) {
        my @details = split /:/, $info[$i];
        next if ( $details[0] eq $info[1] );
        if ( $details[0] !~ /D/ and $details[0] !~ /I/ and $details[0] !~ /\*/ and $#info < 14 ) {
            my $frq = $info[$hash1{$details[0]}] / $info[3];
            $frq = sprintf("%.8f", $frq);
            next if ( $frq < 0.0007 );
            #if ( ( $info[3] < 5000 and $frq < 0.01 and $details[1] < 0.01 ) or $details[1] < 0.00001 ) {
            if ( $details[1] < 0.001 ) { 
                #next if ( $muts{$info[2]} =~ /[DI]/ );
                $format = "NC_012920.1:m."."$info[2]"."$info[1]".">"."$details[0]";
                print OUT "MT\t$info[2]\t$info[2]\t$info[1]\t$details[0]\t$frq\t$info[$hash1{$details[0]}]:$info[3]\t$format\n";
            }
        }
        elsif ( $details[0] =~ /I/ ) {
            #next if ( $details[1] < $info[4] );
            next if ( $i > 12 and $ftype =~ /I/ );
            my $type = ( split /[+:]/, $info[$i] )[1];
            my $alt = "$info[1]"."$type";
            my $frq = $info[9] / $info[3];
            $frq = sprintf("%.8f", $frq);
            next if ( $frq < 0.0007 );
            my $end = $info[2] + 1;
            $format = "NC_012920.1:m."."$info[2]"."_$end"."ins"."$type";
            my $out = "MT\t$info[2]\t$info[2]\t$info[1]\t$alt\t$frq\t$info[9]:$info[3]\t$format";
            $nearby{$out} = $details[1];
            for my $o ( sort keys %nearby ) {
                my $p = ( split /\t/, $o ) [1];
                if ( abs($p - $info[2]) > 0 and abs($p - $info[2]) < 5 ) {
                    if ( $details[1] < $nearby{$o} ) { delete($nearby{$out}); }
                    else { delete($nearby{$o}); }
                }
            }
        }
        elsif ( $info[$i] =~ /D/ ) {
            #next if ( $details[1] < $info[4] );
            my $type = ( split /[-:]/, $info[$i] )[1];
            my $len = length($type);
            my $start = $info[2] + 1;
            my $end = $info[2] + $len;
            my $frq = $info[10] / $info[3];
            $frq = sprintf("%.8f", $frq);
            next if ( $frq < 0.0007 );
            $format = "NC_012920.1:m."."$start"."_$end"."del";
            my $out = "MT\t$start\t$end\t$type\t-\t$frq\t$info[10]:$info[3]\t$format";
            $nearby{$out} = $details[1];
            for my $o ( sort keys %nearby ) {
                my $p = ( split /\t/, $o ) [1];
                if ( abs($p - $start) > 0 and abs($p - $start) < 5 ) {
                    if ( $details[1] < $nearby{$o} ) { delete($nearby{$out}); }
                    else { delete($nearby{$o}); }
                }
            }
        }
    }
}
for my $indel ( sort keys %nearby ) {
    print OUT "$indel\n";
}
close IN;
close OUT;
