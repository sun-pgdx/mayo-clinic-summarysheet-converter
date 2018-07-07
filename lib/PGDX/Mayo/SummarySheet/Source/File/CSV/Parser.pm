package PGDX::Mayo::SummarySheet::Source::File::CSV::Parser;

use Moose;
use Data::Dumper;
use Text::CSV;
use File::Slurp;

use PGDX::Mayo::SummarySheet::Source::File::Record;

extends 'PGDX::Mayo::SummarySheet::Source::File::Parser';

use constant TRUE  => 1;

use constant FALSE => 0;

use constant DEFAULT_VERBOSE => TRUE;

use constant DEFAULT_EOL => "\r\n";

use constant FCID_IDX           => 0;
use constant LANE_IDX           => 1;
use constant SAMPLE_ID_IDX      => 2;
use constant SAMPLE_REF_IDX     => 3;
use constant INDEX_IDX          => 4;
use constant DESCRIPTOR_IDX     => 5;
use constant Y_IDX              => 6;
use constant RECIPE_IDX         => 7;
use constant OPERATOR_IDX       => 8;
use constant SAMPLE_PROJECT_IDX => 9;

has 'header_list' => (
    is       => 'rw',
    isa      => 'ArrayRef',
    writer   => 'setHeaderList',
    reader   => 'getHeaderList',
    required => FALSE
    );

has 'header_lookup' => (
    is       => 'rw',
    isa      => 'HashRef',
    writer   => 'setHeaderLookup',
    reader   => 'getHeaderLookup',
    required => FALSE
    );


my $instance;

sub getInstance {

    if (!defined($instance)){

        $instance = new PGDX::Mayo::SummarySheet::Source::File::CSV::Parser(@_);
        
        if (!defined($instance)){
            confess "Could not instantiate PGDX::Mayo::SummarySheet::Source::File::CSV::Parser";
        }
    }
    return $instance;
}

sub BUILD {

    my $self = shift;

    $self->_initLogger(@_);

    $self->_initConfigManager(@_);

    my $infile = $self->getInfile();
    if (defined($infile)){
        $self->_parse_file($infile);
    }

    $self->{_logger}->info("Instantiated ". __PACKAGE__);
}

sub _parse_file_with_text_csv {

    my $self = shift;
    my ($infile) = @_;

    if (!defined($infile)){

        $infile = $self->getInfile();

        if (!defined($infile)){        
            $self->{_logger}->logconfess("infile was not defined");
        }
    }

    my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
                    or $self->{_logger}->logconfess("Cannot use CSV: ".Text::CSV->error_diag ());
     
    open my $fh, "<:encoding(utf8)", "$infile" or $self->{_logger}->logconfess("Could not open file 'CSV file '$infile' : $!");

    my $eol = $self->{_config_manager}->getSourceFileEOL();
    if (!defined($eol)){
        $eol = DEFAULT_EOL;
        $self->{_logger}->warn("Could not retrieve eol from the configuration file and so it was set to default '$eol'");
    }

    # $csv->eol($eol);
    $csv->eol("\n");

    my $line_ctr = 0;

    while ( my $row = $csv->getline( $fh ) ) {

        $line_ctr++;

        if ($line_ctr == 1){
            
            $self->setHeaderList($row);
            
            $self->_set_header_lookup($row);
        }
        else {
            my $record = new PGDX::Mayo::SummarySheet::Source::File::Record(
                line_number    => $line_ctr,
                fcid           => $row->[FCID_IDX],
                lane           => $row->[LANE_IDX],
                sample_id      => $row->[SAMPLE_ID_IDX],
                sample_ref     => $row->[SAMPLE_REF_IDX],
                index          => $row->[INDEX_IDX],
                descriptor     => $row->[DESCRIPTOR_IDX],
                y              => $row->[Y_IDX],
                recipe         => $row->[RECIPE_IDX],
                operator       => $row->[OPERATOR_IDX],
                sample_project => $row->[SAMPLE_PROJECT_IDX]
                );

            if (!defined($record)){
                $self->{_logger}->logconfess("Could not instantiate PGDX::Mayo::SummarySheet::Source::File::Record");
            }
       
            push(@{$self->{_record_list}}, $record);   
        }
    }

    close $fh;

    $self->{_is_file_parsed} = TRUE;
}

sub _parse_file {

    my $self = shift;
    my ($infile) = @_;

    if (!defined($infile)){

        $infile = $self->getInfile();

        if (!defined($infile)){        
            $self->{_logger}->logconfess("infile was not defined");
        }
    }

    my $lines = read_file($infile, array_ref => 1 ) ;


    my $line_ctr = 0;

    foreach my $line (@{$lines}){

        # if ($line =~ m/\r\n$/){
        #     $line =~ s/\r\n$//;
        # }

        chomp $line;

        $line_ctr++;

        if ($line_ctr == 1){

            my @headers = split(',', $line);

            $self->setHeaderList(\@headers);
            
            $self->_set_header_lookup(\@headers);
        }
        else {
            my @parts = split(',', $line);
            
            my $record = new PGDX::Mayo::SummarySheet::Source::File::Record(
                line_number    => $line_ctr,
                fcid           => $parts[FCID_IDX],
                lane           => $parts[LANE_IDX],
                sample_id      => $parts[SAMPLE_ID_IDX],
                sample_ref     => $parts[SAMPLE_REF_IDX],
                index          => $parts[INDEX_IDX],
                descriptor     => $parts[DESCRIPTOR_IDX],
                y              => $parts[Y_IDX],
                recipe         => $parts[RECIPE_IDX],
                operator       => $parts[OPERATOR_IDX],
                sample_project => $parts[SAMPLE_PROJECT_IDX]
                );

            if (!defined($record)){
                $self->{_logger}->logconfess("Could not instantiate PGDX::Mayo::SummarySheet::Source::File::Record");
            }
       
            push(@{$self->{_record_list}}, $record);   
        }
    }

    $self->{_is_file_parsed} = TRUE;
}

sub _set_header_lookup {

    my $self = shift;
    my ($row) = @_;

    foreach my $header (@{$row}){
        $self->{_header_lookup}->{$header}++;
    }

    $self->setHeaderLookup($self->{_header_lookup});

    $self->{_logger}->info("header lookup has been set-up");
}


no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

 PGDX::Mayo::SummarySheet::Source::File::CSV::Parser
 

=head1 VERSION

 1.0

=head1 SYNOPSIS

 use PGDX::Mayo::SummarySheet::Source::File::CSV::Parser;
 my $parser= PGDX::Mayo::SummarySheet::Source::File::CSV::Parser::getInstance(infile => $infile);
 $list->getRecordList();

=head1 AUTHOR

 Jaideep Sundaram

 Copyright Jaideep Sundaram

=head1 METHODS

=over 4

=cut