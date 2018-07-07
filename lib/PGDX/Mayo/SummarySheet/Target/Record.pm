package PGDX::Mayo::SummarySheet::Target::Record;

use Moose;

use constant TRUE  => 1;

use constant FALSE => 0;

use constant DEFAULT_VERBOSE => TRUE;

has 'fcid' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setFCID',
    reader   => 'getFCID',
    required => FALSE,
    );

has 'lane' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setLane',
    reader   => 'getLane',
    required => FALSE,
    );

has 'sample_id' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setSampleId',
    reader   => 'getSampleId',
    required => FALSE,
    );

has 'sample_ref' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setSampleRef',
    reader   => 'getSampleRef',
    required => FALSE,
    );

has 'index' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setIndex',
    reader   => 'getIndex',
    required => FALSE,
    );

has 'descriptor' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setDescriptor',
    reader   => 'getDescriptor',
    required => FALSE,
    );

has 'control' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setControl',
    reader   => 'getControl',
    required => FALSE,
    );

has 'recipe' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setRecipe',
    reader   => 'getRecipe',
    required => FALSE,
    );

has 'operator' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setOperator',
    reader   => 'getOperator',
    required => FALSE,
    );

has 'sample_project' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setSampleProject',
    reader   => 'getSampleProject',
    required => FALSE,
    );


sub BUILD {

    my $self = shift;

    $self->_initLogger(@_);


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


no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

 PGDX::Mayo::SummarySheet::Target::Record
 

=head1 VERSION

 1.0

=head1 SYNOPSIS

 use PGDX::Mayo::SummarySheet::Target::Record;
my $record = new PGDX::Mayo::SummarySheet::Target::Record(
            fcid           => $row->[FCID_IDX],
            lane           => $row->[LANE_IDX],
            sample_id      => $row->[SAMPLE_ID_IDX],
            sample_ref     => $row->[SAMPLE_REF_IDX],
            index          => $row->[INDEX_IDX],
            descriptor     => $row->[DESCRIPTOR_IDX],
            control        => $row->[CONTROL_IDX],
            recipe         => $row->[RECIPE_IDX],
            operator       => $row->[OPERATOR_IDX],
            sample_project => $row->[SAMPLE_PROJECT_IDX]
            );

        if (!defined($record)){
            $self->{_logger}->logconfess("Could not instantiate PGDX::Mayo::SummarySheet::Target::Record");
        }

=head1 AUTHOR

 Jaideep Sundaram

 Copyright Jaideep Sundaram

=head1 METHODS

=over 4

=cut