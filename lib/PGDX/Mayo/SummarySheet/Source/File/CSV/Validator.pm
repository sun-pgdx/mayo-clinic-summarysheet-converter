package PGDX::Mayo::SummarySheet::Source::File::CSV::Validator;

use Moose;
use Data::Dumper;

extends 'PGDX::Mayo::SummarySheet::Source::File::Validator';

use constant TRUE  => 1;

use constant FALSE => 0;

use constant DEFAULT_VERBOSE => TRUE;


sub BUILD {

    my $self = shift;

    $self->_initLogger(@_);

    $self->_initConfigManager(@_);

    $self->{_logger}->info("Instantiated ". __PACKAGE__);
}

sub isValid {

    my $self = shift;

    $self->{_error_ctr} = 0;
    
    $self->_validate_headers(@_);

    $self->_validate_records(@_);

    if ($self->{_error_ctr} > 0){
        return FALSE;
    }

    return TRUE;
}

sub _get_parser {

    my $self = shift;

    if (! exists $self->{_parser}){    

        my $infile = $self->getInfile();

        my $parser = PGDX::Mayo::SummarySheet::Source::File::CSV::Parser::getInstance(infile => $infile);

        if (!defined($parser)){
            $self->{_logger}->logconfess("Could not instantiate PGDX::Mayo::SummarySheet::Source::File::CSV::Parser");
        }

        $self->{_parser} = $parser;
    }

    return $self->{_parser};
}

sub _get_expected_header_list {

    my $self = shift;
    
    if (! exists $self->{_expected_header_list}){

        my $list = $self->{_config_manager}->getSourceFileOrderedHeaderList();
        if (!defined($list)){
            $self->{_logger}->logconfess("list was not defined");
        }

        my @parts = split(',', $list);

        $self->{_expected_header_list} = \@parts;

        foreach my $part (@parts){
            $self->{_expected_header_lookup}->{$part}++;
        }
    }

    return $self->{_expected_header_list};
}

sub _get_expected_header_lookup {

    my $self = shift;
    
    if (! exists $self->{_expected_header_lookup}){

        my $list = $self->{_config_manager}->getSourceFileOrderedHeaderList();
        if (!defined($list)){
            $self->{_logger}->logconfess("list was not defined");
        }

        my @parts = split(',', $list);

        $self->{_expected_header_list} = \@parts;

        foreach my $part (@parts){
            $self->{_expected_header_lookup}->{$part}++;
        }
    }

    return $self->{_expected_header_lookup};
}

sub _validate_headers {

    my $self = shift;

    my $parser = $self->_get_parser(@_);

    ##
    ## Check for the expected order of the headers
    ##
    my $header_list = $parser->getHeaderList();
    if (!defined($header_list)){
        my $infile = $self->getInfile();
        $self->{_logger}->logconfess("header_list was not defined fror infile '$infile'");
    }

    my $expected_header_list = $self->_get_expected_header_list();

    for (my $i=0; $i < scalar(@{$expected_header_list}) ; $i++){
        
        my $expected = $expected_header_list->[$i];
        
        my $header = $header_list->[$i];
        
        if ($expected ne $header){

            $self->{_error_ctr}++;

            $self->{_header_mismatch_ctr}++;
        
            push(@{$self->{_header_mismatch_list}}, [$i, $expected, $header]);

            $self->{_logger}->error("expected header '$expected' but found '$header' instead");
        }
    }

    ##
    ## Check for the presence of the expected headers
    ##
    my $header_lookup = $parser->getHeaderLookup();
    
    if (!defined($header_lookup)){
    
        my $infile = $self->getInfile();
    
        $self->{_logger}->logconfess("header_lookup was not defined fror infile '$infile'");
    }

    my $expected_header_lookup = $self->_get_expected_header_lookup();

    foreach my $header (sort keys %{$expected_header_lookup}){
    
        if (!exists $header_lookup->{$header}){
            
            $self->{_error_ctr}++;
            
            $self->{_missing_header_ctr}++;
            
            push(@{$self->{_missing_header_list}}, $header);

            $self->{_logger}->error("Expected header '$header' was not found");
        }
    }
}

sub _validate_records {

    my $self = shift;

    my $infile = $self->getInfile();

    my $parser = $self->_get_parser(@_);

    my $record_list = $parser->getRecordList();
    if (!defined($record_list)){       
        $self->{_logger}->logconfess("record_list was not defined for infile '$infile'");
    }

    $self->{_logger}->info("Validating records in summarysheet source file '$infile'");


    foreach my $record (@{$record_list}){

        my $lineNumber = $record->getLineNumber();
        if (!defined($lineNumber)){
            $self->{_logger}->logconfess("lineNumber was not defined for record :". Dumper $record);
        }

        my $fcid = $record->getFCID();
        if (!defined($fcid)){
            $self->{_logger}->logconfess("fcid was not defined for record : ". Dumper $record);
        }

        if ($self->hasNonPrintableChar($fcid)){
            $self->{_logger}->error("FCID '$fcid' at line '$lineNumber' contains a non-printable character");
            $self->{_error_ctr}++;
        }

        if ($self->hasNonAsciiChar($fcid)){
            $self->{_logger}->error("FCID '$fcid' at line '$lineNumber' contains a non-ascii character");
            $self->{_error_ctr}++;
        }

        my $lane = $record->getLane();
        if (!defined($lane)){
            $self->{_logger}->logconfess("lane was not defined for record : ". Dumper $record);
        }

        if ($self->hasNonPrintableChar($lane)){
            $self->{_logger}->error("Lane '$lane' at line '$lineNumber' contains a non-printable character");
            $self->{_error_ctr}++;
        }

        if ($self->hasNonAsciiChar($lane)){
            $self->{_logger}->error("Lane '$lane' at line '$lineNumber' contains a non-ascii character");
            $self->{_error_ctr}++;
        }

        my $sample_id = $record->getSampleId();
        if (!defined($sample_id)){
            $self->{_logger}->logconfess("sample_id was not defined for record : ". Dumper $record);
        }

        if ($self->hasNonPrintableChar($sample_id)){
            $self->{_logger}->error("SampleID '$sample_id' at line '$lineNumber' contains a non-printable character");
            $self->{_error_ctr}++;
        }

        if ($self->hasNonAsciiChar($sample_id)){
            $self->{_logger}->error("SampleID '$sample_id' at line '$lineNumber' contains a non-ascii character");
            $self->{_error_ctr}++;
        }

        my $sample_ref = $record->getSampleRef();
        if (!defined($sample_ref)){
            $self->{_logger}->logconfess("sample_ref was not defined for record : ". Dumper $record);
        }

        if ($self->hasNonPrintableChar($sample_ref)){
            $self->{_logger}->error("SampleRef '$sample_ref' at line '$lineNumber' contains a non-printable character");
            $self->{_error_ctr}++;
        }

        if ($self->hasNonAsciiChar($sample_ref)){
            $self->{_logger}->error("SampleRef '$sample_ref' at line '$lineNumber' contains a non-ascii character");
            $self->{_error_ctr}++;
        }

        my $index = $record->getIndex();
        if (!defined($index)){
            $self->{_logger}->logconfess("index was not defined for record : ". Dumper $record);
        }

        if ($self->hasNonPrintableChar($index)){
            $self->{_logger}->error("Index '$index' at line '$lineNumber' contains a non-printable character");
            $self->{_error_ctr}++;
        }

        if ($self->hasNonAsciiChar($index)){
            $self->{_logger}->error("Index '$index' at line '$lineNumber' contains a non-ascii character");
            $self->{_error_ctr}++;
        }

        my $descriptor = $record->getDescriptor();
        if (!defined($descriptor)){
            $self->{_logger}->logconfess("descriptor was not defined for record : ". Dumper $record);
        }

        if ($self->hasNonPrintableChar($descriptor)){
            $self->{_logger}->error("Descriptor'$descriptor' at line '$lineNumber' contains a non-printable character");
            $self->{_error_ctr}++;
        }

        if ($self->hasNonAsciiChar($descriptor)){
            $self->{_logger}->error("Descriptor'$descriptor' at line '$lineNumber' contains a non-ascii character");
            $self->{_error_ctr}++;
        }

        my $y = $record->getY();
        if (!defined($y)){
            $self->{_logger}->logconfess("y was not defined for record : ". Dumper $record);
        }

        if ($self->hasNonPrintableChar($y)){
            $self->{_logger}->error("Y '$y' at line '$lineNumber' contains a non-printable character");
            $self->{_error_ctr}++;
        }

        if ($self->hasNonAsciiChar($y)){
            $self->{_logger}->error("Y '$y' at line '$lineNumber' contains a non-ascii character");
            $self->{_error_ctr}++;
        }

        my $recipe = $record->getRecipe();
        if (!defined($recipe)){
            $self->{_logger}->logconfess("Recipe was not defined for record : ". Dumper $record);
        }

        if ($self->hasNonPrintableChar($recipe)){
            $self->{_logger}->error("Recipe '$recipe' at line '$lineNumber' contains a non-printable character");
            $self->{_error_ctr}++;
        }

        if ($self->hasNonAsciiChar($recipe)){
            $self->{_logger}->error("Recipe '$recipe' at line '$lineNumber' contains a non-ascii character");
            $self->{_error_ctr}++;
        }


        my $operator = $record->getOperator();
        if (!defined($operator)){
            $self->{_logger}->logconfess("Recipe was not defined for record : ". Dumper $record);
        }

        if ($self->hasNonPrintableChar($operator)){
            $self->{_logger}->error("Operator '$operator' at line '$lineNumber' contains a non-printable character");
            $self->{_error_ctr}++;
        }

        if ($self->hasNonAsciiChar($operator)){
            $self->{_logger}->error("Operator '$operator' at line '$lineNumber' contains a non-ascii character");
            $self->{_error_ctr}++;
        }


        my $sample_project = $record->getSampleProject();
        if (!defined($sample_project)){
            $self->{_logger}->logconfess("SampleProject was not defined for record : ". Dumper $record);
        }

        if ($self->hasNonPrintableChar($sample_project)){
            $self->{_logger}->error("SampleProject '$sample_project' at line '$lineNumber' contains a non-printable character");
            $self->{_error_ctr}++;
        }

        if ($self->hasNonAsciiChar($sample_project)){
            $self->{_logger}->error("SampleProject '$sample_project' at line '$lineNumber' contains a non-ascii character");
            $self->{_error_ctr}++;
        }
    }
}


no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

 PGDX::Mayo::SummarySheet::Source::File::CSV::Validator
 

=head1 VERSION

 1.0

=head1 SYNOPSIS

 use PGDX::Mayo::SummarySheet::Source::File::CSV::Validator;
 my $manager = PGDX::Mayo::SummarySheet::Source::File::CSV::Validator::getInstance();
 $manager->runBenchmarkTests($infile);

=head1 AUTHOR

 Jaideep Sundaram

 Copyright Jaideep Sundaram

=head1 METHODS

=over 4

=cut