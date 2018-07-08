package PGDX::Mayo::SummarySheet::Target::File::CSV::Writer;

use Moose;
use Text::CSV;
use Data::Dumper;

use PGDX::Logger;

extends 'PGDX::File::Writer';

use constant TRUE  => 1;
use constant FALSE => 0;

use constant DEFAULT_EOL => "\r\n";

sub BUILD {

    my $self = shift;

    $self->_initLogger(@_);

    $self->_initConfigManager(@_);

    $self->{_logger}->info("Instantiated ". __PACKAGE__);
}

sub writeRecords_with_text_csv {

    my $self = shift;
    my ($record_list) = @_;

    if (!defined($record_list)){
        $self->{_logger}->logconfess("record_list was not defined");
    }

    my $eol = $self->{_config_manager}->getTargetFileEOL();
    if (!defined($eol)){
        $eol = DEFAULT_EOL;
        $self->{_logger}->warn("Could not retrieve eol from the configuration file and so it was set to default '$eol'");
    }

    my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
                or $self->{_logger}->logconfess("Could not instantiate Text::CSV : ".Text::CSV->error_diag ());

    $csv->eol($eol);
 
    my $outfile = $self->getOutfile();

    my $fh;
    
    open $fh, ">:encoding(utf8)", "$outfile" or $self->{_logger}->logconfess("Could not open output file '$outfile' : $!");

    my $header_list = $self->{_config_manager}->getTargetFileOrderedHeaderList();
    if (!defined($header_list)){
        $self->{_logger}->logconfess("header_list was not defined");
    }

    my @headers = split(',', $header_list);

    $csv->print ($fh, \@headers);
    # print $fh $header_list . $eol;

    $self->{_record_ctr} = 0;

    foreach my $record (@{$record_list}){

        $self->{_record_ctr}++;

        my $row = [
            $record->getFCID(),
            $record->getLane(),
            $record->getSampleId(),
            $record->getSampleRef(),
            $record->getIndex(),
            $record->getDescriptor(),
            $record->getControl(),
            $record->getRecipe(),
            $record->getOperator(),
            $record->getSampleProject()
        ];
        
        $csv->print ($fh, $row);
    }

    close $fh or $self->{_logger}->logconfess("Encountered some error while atttempting to close file '$outfile' : $!");

    $self->{_logger}->info("Wrote '$self->{_record_ctr}' rows to output file '$outfile'");

    print ("Wrote '$self->{_record_ctr}' rows to output file '$outfile'\n");
}

sub writeRecords {

    my $self = shift;
    my ($record_list) = @_;

    if (!defined($record_list)){
        $self->{_logger}->logconfess("record_list was not defined");
    }

    my $header_list = $self->{_config_manager}->getTargetFileOrderedHeaderList();
    if (!defined($header_list)){
        $self->{_logger}->logconfess("header_list was not defined");
    }

    my $outfile = $self->getOutfile();

    open (OUTFILE, ">$outfile") || $self->{_logger}->logconfess("Could not open '$outfile' in write mode : $!");

    print OUTFILE $header_list . "\n";

    $self->{_record_ctr} = 0;

    foreach my $record (@{$record_list}){

        $self->{_record_ctr}++;

        my $row = [
            $record->getFCID(),
            $record->getLane(),
            $record->getSampleId(),
            $record->getSampleRef(),
            $record->getIndex(),
            $record->getDescriptor(),
            $record->getControl(),
            $record->getRecipe(),
            $record->getOperator(),
            $record->getSampleProject()
        ];
        
        print OUTFILE join(',', @{$row}). "\n";
    }

    close OUTFILE;    

    $self->{_logger}->info("Wrote '$self->{_record_ctr}' rows to output file '$outfile'");

    print ("Wrote '$self->{_record_ctr}' rows to output file '$outfile'\n");
}


no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

 PGDX::ImmunoSELECT::Trigger::File::Writer
 

=head1 VERSION

 1.0

=head1 SYNOPSIS

 use PGDX::Mayo::SummarySheet::Target::File::CSV::Writer;
 my $writer = new PGDX::Mayo::SummarySheet::Target::File::CSV::Writer();
 $writer->writeFile($outfile);

=head1 AUTHOR

 Jaideep Sundaram

 Copyright Jaideep Sundaram

=head1 METHODS

=over 4

=cut