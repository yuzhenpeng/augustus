#!/usr/bin/perl
use strict;
use warnings;
use File::Basename qw(basename);

die "Usage:$0 <all.out.pair> <all.out.pair.gff> <dog.fa.len> <outdir,default:./>\n\n" if @ARGV<3;

my $pair=shift;
my $pair_gff=shift;
my $pep=shift;
my $Outdir=shift;

$Outdir ||='.';
$Outdir =~s/\/$//;

my %Status;
read_pair($pair,\%Status);

my %Len;
read_len($pep,\%Len);

my %Gene;
read_gff($pair_gff,\%Gene);

foreach my $chr ( sort keys %Gene ){
	@{$Gene{$chr}}=sort {$a->[1]<=>$b->[1]} @{$Gene{$chr}};
	print join("\t",$chr,$Len{$chr},@{$Gene{$chr}[0]},@{$Gene{$chr}[-1]})."\n";
}

sub read_gff{
	my ($file,$p)=@_;
	open IN,$file or die "$!";
	while(<IN>){
		next if /^#/;
		my @c=split(/\t/);
		@c[3,4]=@c[4,3] if $c[3]>$c[4];
		if ($c[2] eq 'mRNA' && $c[8]=~/ID=([^;]+)/){
			push @{$p->{$c[0]}},[$1,@c[3,4],$c[6],$Status{$1}];
		}
	}
	close IN;
}

sub read_pair{
	my ($file,$p)=@_;
	open IN,$file or die "$!";
	while(<IN>){
		chomp;
		my @c=split(/\s+/);
		$p->{$c[2]}=$c[1];
	}
	close IN;
}

sub read_len{
	my ($file,$p)=@_;
	open IN,$file or die "$!";
	while(<IN>){
		if (/^(\S+)\s+(\d+)/){
			$p->{$1}=$2;
		}
	}
	close IN;
}
