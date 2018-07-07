package PGDX::Mayo::SummarySheet::File::Converter;

use Moose;
use Cwd;
use Data::Dumper;
use File::Path;
use File::Copy;
use FindBin;
use Term::ANSIColor;
use JSON::Parse 'json_file_to_perl';

use PGDX::Logger;
use PGDX::Config::Manager;
use PGDX::Mayo::SummarySheet::Source::File::CSV::Parser;
use PGDX::Mayo::SummarySheet::Source::File::CSV::Validator;
use PGDX::Mayo::SummarySheet::Target::File::CSV::Writer;
use PGDX::Mayo::SummarySheet::Target::Record;

# extends 'PGDX::SummarySheet::Converter';

use constant TRUE  => 1;

use constant FALSE => 0;

use constant DEFAULT_TEST_MODE => TRUE;

use constant DEFAULT_OUTDIR => '/tmp/' . File::Basename::basename($0) . '/' . time();

## Singleton support
my $instance;

has 'infile' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setInfile',
    reader   => 'getInfile',
    required => FALSE
    );

has 'outdir' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setOutdir',
    reader   => 'getOutdir',
    required => FALSE,
    default  => DEFAULT_OUTDIR
    );

has 'outfile' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setOutfile',
    reader   => 'getOutfile',
    required => FALSE
    );


has 'batch_number' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setBatchNumber',
    reader   => 'getBatchNumber',
    required => FALSE
    );

has 'next_pgdx_id' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setNextPGDXId',
    reader   => 'getNextPGDXId',
    required => FALSE
    );

sub getInstance {

    if (!defined($instance)){

        $instance = new PGDX::Mayo::SummarySheet::File::Converter(@_);

        if (!defined($instance)){

            confess "Could not instantiate PGDX::Mayo::SummarySheet::File::Converter";
        }
    }
    return $instance;
}

sub BUILD {

    my $self = shift;

    $self->_initLogger(@_);

    $self->_initConfigManager(@_);

    $self->{_logger}->info("Instantiated ". __PACKAGE__);
}

sub _initLogger {

    my $self = shift;

    my $logger = Log::Log4perl->get_logger(__PACKAGE__);

    if (!defined($logger)){
        confess "logger was not defined";
    }

    $self->{_logger} = $logger;
}

sub _initConfigManager {

    my $self = shift;
    
    my $config_manager = PGDX::Config::Manager::getInstance();
    if (!defined($config_manager)){
        $self->{_logger}->logconfess("Could not instantiate PGDX::Config::Manager");
    }

    $self->{_config_manager} = $config_manager;
}

sub run {

    my $self = shift;
    

    $self->_validate_source_file();

    $self->_parse_source_file();

    $self->_run_conversion();

    $self->_write_target_file();

    $self->_write_report();
}

sub _validate_source_file {

    my $self = shift;
    
    my $infile = $self->getInfile();

    my $validator = new PGDX::Mayo::SummarySheet::Source::File::CSV::Validator(infile => $infile);
    if (!defined($validator)){
        $self->{_logger}->logconfess("Could not instantiate PGDX::Mayo::SummarySheet::Source::File::CSV::Validator");
    }

    if ($validator->isValid()){
        printGreen("Mayo source summarysheet file '$infile' is valid");
        $self->{_logger}->info("Mayo source summarysheet file '$infile' is valid");
    }
    else {
        printBoldRed("Mayo source summarysheet file '$infile' is NOT valid");
        $self->{_logger}->logconfess("Mayo source summarysheet file '$infile' is NOT valid");        
    }
}

sub _parse_source_file {

    my $self = shift;
    
    my $infile = $self->getInfile();

    my $parser = PGDX::Mayo::SummarySheet::Source::File::CSV::Parser::getInstance(infile => $infile);
    if (!defined($parser)){
        $self->{_logger}->logconfess("Could not instantiate PGDX::Mayo::SummarySheet::Source::File::CSV::Parser");
    }

    my $record_list = $parser->getRecordList();

    if (!defined($record_list)){
        $self->{_logger}->logconfess("record_list was not defined for file '$infile'");
    }

    $self->{_source_record_list} = $record_list;
}


sub _run_conversion {

    my $self = shift;

    $self->{_source_record_ctr} = 0;

    foreach my $source_record (@{$self->{_source_record_list}}){

        $self->{_source_record_ctr}++;        

        my $target_record = new PGDX::Mayo::SummarySheet::Target::Record();
        if (!defined($target_record)){
            $self->{_logger}->logconfess("Could not instantiate PGDX::Mayo::SummarySheet::Target::Record");
        }

        $target_record->setFCID($source_record->getFCID());

        $target_record->setLane($source_record->getLane());

        $target_record->setSampleId($source_record->getSampleId());

        $target_record->setSampleRef($source_record->getSampleRef());

        $target_record->setIndex($source_record->getIndex());

        $target_record->setDescriptor($source_record->getDescriptor());

        $target_record->setControl($source_record->getY());

        $target_record->setRecipe($source_record->getRecipe());

        $target_record->setOperator($source_record->getOperator());

        $target_record->setSampleProject($source_record->getSampleProject());

        push(@{$self->{_target_record_list}}, $target_record);
    }

    $self->{_logger}->info("Processed '$self->{_source_record_ctr}' records");
}

sub _write_target_file {

    my $self = shift;

    my $outfile = $self->_getOutfile();

    my $writer = new PGDX::Mayo::SummarySheet::Target::File::CSV::Writer(outfile => $outfile);
    if (!defined($writer)){
        $self->{_logger}->logconfess("Could not instantiate PGDX::Mayo::SummarySheet::Target::File::CSV::Writer");
    }

    $writer->writeRecords($self->{_target_record_list});
}

sub _write_report {

    my $self = shift;
    
    $self->{_logger}->warn("NOT YET IMPLEMENTED");
}

sub _getOutfile {

    my $self = shift;
    
    my $outfile = $self->getOutfile();

    if (!defined($outfile)){

        my $outdir = $self->getOutdir();

        if (!defined($outdir)){

            mkpath($outdir) || $self->{_logger}->logconfess("Could not create directory '$outdir' : $!");
            
            $self->{_logger}->info("Created output directory '$outdir'");
        }


        my $ext = $self->{_config_manager}->getTargetFileNameExtension();
        if (!defined($ext)){
            $self->{_logger}->logconfess("target file name extension was not defined");
        }

        $outfile = $outdir . '/new_summarysheet.' . $ext;
        
        $self->setOutfile($outfile);
    }

    return $outfile;
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

sub printBrightBlue {

    my ($msg) = @_;
    print color 'bright_blue';
    print $msg . "\n";
    print color 'reset';
}


no Moose;

__PACKAGE__->meta->make_immutable;

__END__


=head1 NAME

 PGDX::Mayo::SummarySheet::File::Converter
 
=head1 VERSION

 1.0

=head1 SYNOPSIS

 use PGDX::Mayo::SummarySheet::File::Converter;
 my $converter = PGDX::Mayo::SummarySheet::File::Converter::getInstance(infile => $infile, outfile => $outfile);
 $converter->run();

=head1 AUTHOR

 Jaideep Sundaram

 Copyright Jaideep Sundaram

=head1 METHODS

=over 4

=cut