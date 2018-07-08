package PGDX::Mayo::AdapterSequences::File::Record;

use Moose;

use constant TRUE  => 1;

use constant FALSE => 0;

use constant DEFAULT_VERBOSE => TRUE;


has 'kit_name' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setKitName',
    reader   => 'getKitName',
    required => FALSE,
    );

has 'supply_item_name' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setSupplyItemName',
    reader   => 'getSupplyItemName',
    required => FALSE,
    );

has 'adapter' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setAdapter',
    reader   => 'getAdapter',
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

sub addSequence {

    my $self = shift;
    my ($sequence) = @_;

    if (!defined($sequence)){
        $self->{_logger}->logconfess("sequence was not defined");
    }

    push(@{$self->{_sequence_list}}, $sequence);
}

sub getSequenceList {

    my $self = shift;
    
    return $self->{_sequence_list};
}

sub hasSequences {

    my $self = shift;
    
    if (exists $self->{_sequence_list}){

        return $self->{_sequence_list};
    }
}


no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

 PGDX::Mayo::AdapterSequences::File::Record
 

=head1 VERSION

 1.0

=head1 SYNOPSIS

 use PGDX::Mayo::AdapterSequences::File::Record;
my $record = new PGDX::Mayo::AdapterSequences::File::Record(
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
            $self->{_logger}->logconfess("Could not instantiate PGDX::Mayo::AdapterSequences::File::Record");
        }

=head1 AUTHOR

 Jaideep Sundaram

 Copyright Jaideep Sundaram

=head1 METHODS

=over 4

=cut