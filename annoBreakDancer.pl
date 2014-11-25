#!/usr/bin/perl
use strict; 

my $Usage = "[Usage] ./anno_BreakDancer.pl [refGene.txt] [ctx: breakdancer] [output: anno_ctx]\n";
my ($ref_fname, $in_ctx, $out_ctx,) = @ARGV;
if ($#ARGV != 2) {
    die $Usage;
}

my %Gene;
#738     NM_033196       chr19   -       20115226        20150277        20116813        20150154        4       20115226,20133812,20135058,20150151,    20118084,20133908,20135185,20150277,    0       ZNF682  cmpl    cmpl    1,1,0,0,
#892     NM_033194       chr17   +       40274755        40275371        40274868        40275348        1       40274755,       40275371,       0       HSPB9   cmpl    cmpl    0,

open(IN, "<$ref_fname") or die "Can't open $ref_fname\n";
my $num=0;
while(<IN>){
    my @chunks = split /\s+/, $_;
    $num++;
    $Gene{$chunks[1]}->{'chr'} = $chunks[2];
    $Gene{$chunks[1]}->{'begin'} = $chunks[4];
    $Gene{$chunks[1]}->{'end'} = $chunks[5];
    $Gene{$chunks[1]}->{'name'} = $chunks[12];
}
close(IN);
print "$num lines were loaded.\n";

#bam/SNUH_OvCa_index12.recal.bam        mean:193.580    std:49.730      uppercutoff:449.350     lowercutoff:45.400      readlen:150.000 library:SureSelectV4+UTR        reflen:3012286985       seqcov:4.936x   phycov:3.185x   32:280342
#Chr1   Pos1    Orientation1    Chr2    Pos2    Orientation2    Type    Size    Score   num_Reads       num_Reads_lib   Allele_frequency        Version Run_Param
#2       91766906        0+3-    4       4239376 0+2-    CTX     -193    44      2       SureSelectV4+UTR|2      1.00    BreakDancerMax-1.0r112  |t1|q10|dindex4.ctx|f1
#1       214656762       3+0-    5       115177631       4+0-    CTX     -193    73      3       SureSelectV4+UTR|3      1.00    BreakDancerMax-1.0r112  |t1|q10|dindex4.ctx|f1

open(IN, "<$in_ctx") or die "Can't open $in_ctx\n";;
open(OUT, ">$out_ctx");
my $cur;
$num=0;
while(<IN>){
    my @chunks = split /\s+/, $_;
    if (substr($_, 0, 4) eq "#Chr1"){
	print OUT join("\t", @chunks[0..2], "Gene1", @chunks[3..5], "Gene2", @chunks[6..12]), "\n";
	next;
    }elsif(substr($_, 0, 1) eq "#"){
	print OUT $_;
	next;
    }
    $chunks[0] = "chr" . $chunks[0];
    $chunks[3] = "chr" . $chunks[3];

    my $cur_pos1 = "intergenic";
    my $cur_pos2 = "intergenic";
    foreach my $k (keys %Gene){
	if (($Gene{$k}->{'chr'} eq $chunks[0])&&($Gene{$k}->{'begin'}<=$chunks[1])&&($Gene{$k}->{'end'}>=$chunks[1])){
	    $cur_pos1 = $Gene{$k}->{'name'};
	}
	if (($Gene{$k}->{'chr'} eq $chunks[3])&&($Gene{$k}->{'begin'}<=$chunks[4])&&($Gene{$k}->{'end'}>=$chunks[4])){
	    $cur_pos2 = $Gene{$k}->{'name'};
	}
    }
    print OUT join("\t", @chunks[0..2], $cur_pos1, @chunks[3..5], $cur_pos2, @chunks[6..12]), "\n";
    $num++;
}
close(IN);
close(OUT);
print "$num lines were processed.\n";
exit;

