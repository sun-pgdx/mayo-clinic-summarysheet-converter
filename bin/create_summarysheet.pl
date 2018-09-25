#!/usr/bin/env perl
use strict;
use Carp;
use Cwd 'abs_path';
use Term::ANSIColor;
use File::Basename;
use File::Path;
use File::Copy;
use File::Slurp;
use Data::Dumper;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev);
use Pod::Usage;
use Cwd;
use FindBin;
use Sys::Hostname;

use lib "$FindBin::Bin/../lib";

use PGDX::Logger;
use PGDX::Config::Manager;
use PGDX::Mayo::SummarySheet::File::Converter;

## Do not buffer output stream
$|=1;

use constant TRUE => 1;

use constant FALSE => 0;

use constant DEFAULT_CONFIG_FILE => "$FindBin::Bin/../conf/mayo_summarysheet_converter.ini";

use constant DEFAULT_VERBOSE => FALSE;

use constant DEFAULT_LOG_LEVEL => 4;

# use constant DEFAULT_IGNORE_NON_PRINTABLE_CHARS => FALSE;

# use constant DEFAULT_IGNORE_NON_ASCII_CHARS => FALSE;

use constant DEFAULT_OUTDIR => '/tmp/' . File::Basename::basename($0). '/' . time();

## Command-line arguments
my (
    $infile,
    $outfile,
    $outdir,
    $log_level, 
    $help, 
    $logfile, 
    $man, 
    $verbose,
    # $ignore_non_printable_chars,
    # $ignore_non_ascii_chars,
    $config_file,
    $batch_number,
    $next_pgdx_id
    );

my $results = GetOptions (
    'log-level|d=s'                  => \$log_level, 
    'logfile=s'                      => \$logfile,
    'infile=s'                       => \$infile,
    'outfile=s'                      => \$outfile,
    'help|h'                         => \$help,
    'man|m'                          => \$man,
    'outdir=s'                       => \$outdir,
    # 'ignore_non_printable_chars'     => \$ignore_non_printable_chars,
    # 'ignore_non_ascii_chars'         => \$ignore_non_ascii_chars,
    'config_file=s'                  => \$config_file,
    'batch_number=s'                 => \$batch_number,
    'next_pgdx_id=s'                 => \$next_pgdx_id,
    );

&checkCommandLineArguments();

my $logger = new PGDX::Logger(
    logfile   => $logfile, 
    log_level => $log_level
    );

if (!defined($logger)){
    die "Could not instantiate PGDX::Logger";
}

my $config_manager = PGDX::Config::Manager::getInstance(config_file => $config_file);
if (!defined($config_manager)){
    $logger->logconfess("Could not instantiate PGDX::Config::Manager");
}

    # my $validator = new PGDX::ImmunoSELECT::Pretrigger::File::Validator(infile => $pretrigger_file);
    # if (!defined($validator)){
    #     $logger->logconfess("Could not instantiate PGDX::ImmunoSELECT::Pretrigger::File::Validator");
    # }

    # if (! $validator->isFileValid()){
    #     $logger->logconfess("pretrigger file '$pretrigger_file' is not valid");
    # }

    # &derive_lims_field_list();

    # &derive_sample_id_list();

my $converter = PGDX::Mayo::SummarySheet::File::Converter::getInstance(
    infile       => $infile,
    outdir       => $outdir,
    batch_number => $batch_number,
    next_pgdx_id => $next_pgdx_id
	);

if (!defined($converter)){
	$logger->logconfess("Could not instantiate PGDX::Mayo::SummarySheet::File::Converter");
}

if (defined($outfile)){
    $converter->setOutfile($outfile);
}

$converter->run();

print File::Spec->rel2abs($0) . " execution completed\n";
print "The log file is '$logfile'\n";
exit(0);

##------------------------------------------------------
##
##  END OF MAIN -- SUBROUTINES FOLLOW
##
##------------------------------------------------------

sub checkCommandLineArguments {
   
    if ($man){
    	&pod2usage({-exitval => 1, -verbose => 2, -output => \*STDOUT});
    }
    
    if ($help){
    	&pod2usage({-exitval => 1, -verbose => 1, -output => \*STDOUT});
    }

    if (!defined($config_file)){

        $config_file = DEFAULT_CONFIG_FILE;
            
        printYellow("--config_file was not specified and therefore was set to default '$config_file'");
    }

    if (!defined($verbose)){

        $verbose = DEFAULT_VERBOSE;

        printYellow("--verbose was not specified and therefore was set to default '$verbose'");
    }


    if (!defined($log_level)){

        $log_level = DEFAULT_LOG_LEVEL;

        printYellow("--log_level was not specified and therefore was set to default '$log_level'");
    }

    if (!defined($outdir)){

        $outdir = DEFAULT_OUTDIR;

        printYellow("--outdir was not specified and therefore was set to default '$outdir'");
    }

    $outdir = File::Spec->rel2abs($outdir);

    if (!-e $outdir){

        mkpath ($outdir) || die "Could not create output directory '$outdir' : $!";

        printYellow("Created output directory '$outdir'");

    }
    
    if (!defined($logfile)){

    	$logfile = $outdir . '/' . File::Basename::basename($0) . '.log';

    	printYellow("--logfile was not specified and therefore was set to '$logfile'");

    }

    $logfile = File::Spec->rel2abs($logfile);


    my $fatalCtr=0;

    if (!defined($infile)){

        printBoldRed("--infile was not specified");

        $fatalCtr++;
    }

    if (!defined($batch_number)){

        printBoldRed("--batch_number was not specified");

        $fatalCtr++;
    }

    if (!defined($next_pgdx_id)){

        printBoldRed("--next_pgdx_id was not specified");

        $fatalCtr++;
    }

    &checkInfileStatus($infile);

    if ($fatalCtr> 0 ){

    	die "Required command-line arguments were not specified\n";
    }
}

sub printBoldRed {

    my ($msg) = @_;
    print color 'bold red';
    print $msg . "\n";
    print color 'reset';
}

sub printYellow {

    my ($msg) = @_;
    print color 'yellow';
    print $msg . "\n";
    print color 'reset';
}

sub printGreen {

    my ($msg) = @_;
    print color 'green';
    print $msg . "\n";
    print color 'reset';
}

sub checkInfileStatus {

    my ($infile) = @_;

    if (!defined($infile)){
        die ("infile was not defined");
    }

    my $errorCtr = 0 ;

    if (!-e $infile){
        print color 'bold red';
        print ("input file '$infile' does not exist\n");
        print color 'reset';
        $errorCtr++;
    }
    else {

        if (!-f $infile){
            print color 'bold red';
            print ("'$infile' is not a regular file\n");
            print color 'reset';
            $errorCtr++;
        }

        if (!-r $infile){
            print color 'bold red';
            print ("input file '$infile' does not have read permissions\n");
            print color 'reset';
            $errorCtr++;
        }
        
        if (!-s $infile){
            print color 'bold red';
            print ("input file '$infile' does not have any content\n");
            print color 'reset';
            $errorCtr++;
        }
    }
     
    if ($errorCtr > 0){
        print color 'bold red';
        print ("Encountered issues with input file '$infile'\n");
        print color 'reset';
        exit(1);
    }
}