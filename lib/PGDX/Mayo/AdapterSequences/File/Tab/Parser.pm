package PGDX::Mayo::AdapterSequences::File::Tab::Parser;

use Moose;
use Data::Dumper;
use Text::CSV;
use File::Slurp;

use PGDX::Config::Manager;
use PGDX::Mayo::AdapterSequences::File::Record;

extends 'PGDX::File::Parser';

use constant TRUE  => 1;

use constant FALSE => 0;

use constant DEFAULT_VERBOSE => TRUE;

use constant KIT_NAME_IDX         => 0;

use constant SUPPLY_ITEM_NAME_IDX => 1;

use constant SEQUENCE_IDX         => 2;

my $instance;

sub getInstance {

    if (!defined($instance)){

        $instance = new PGDX::Mayo::AdapterSequences::File::Tab::Parser(@_);
        
        if (!defined($instance)){
            confess "Could not instantiate PGDX::Mayo::AdapterSequences::File::Tab::Parser";
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

sub _initConfigManager {

    my $self = shift;
    
    my $config_manager = PGDX::Config::Manager::getInstance();
    if (!defined($config_manager)){
        $self->{_logger}->logconfess("Could not instantiate PGDX::Config::Manager");
    }

    $self->{_config_manager} = $config_manager;
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

    $infile = File::Spec->rel2abs($infile);

    my $lines = read_file($infile, array_ref => 1 ) ;


    my $line_ctr = 0;

    my $current_record;

    my $current_adapter;

    my $current_sequence;

    foreach my $line (@{$lines}){

        chomp $line;

        $line_ctr++;

        my @parts = split("\t", $line);
        
        my $kit_name = $parts[KIT_NAME_IDX];        
        
        my $supply_item_name = $parts[SUPPLY_ITEM_NAME_IDX];

        $current_sequence = $parts[SEQUENCE_IDX];

        if ($line_ctr == 1){

            next;
        }
                  
        if ($kit_name =~ m/^Custom Adapter/){

            if (defined($current_record)){

                $self->_load_current_record($current_record, $current_adapter);                
            }                

            if ($kit_name =~ m/^Custom Adapter P_([A-Z]{2}\s*\-\s*[A-Z]{1})\s*$/){

                $current_adapter = $1;
                
                $current_adapter =~ s/\s+//g;
            }
            else {
                $self->{_logger}->logconfess("Could not parse '$kit_name'");
            }

            $current_record = $self->_create_next_record($kit_name, $supply_item_name, $current_adapter);
        }

        $current_record->addSequence($current_sequence);
    }

    # $current_record->addSequence($current_sequence);

    $self->_load_current_record($current_record, $current_adapter);

    $self->{_is_file_parsed} = TRUE;
}

sub _load_current_record {

    my $self = shift;
    my ($current_record, $current_adapter) = @_;

    push(@{$self->{_record_list}}, $current_record);                    

    $self->{_adapter_to_record_lookup}->{$current_adapter} = $current_record;

}

sub _create_next_record {

    my $self = shift;
    my ($kit_name, $supply_item_name, $adapter) = @_;

    my $record = new PGDX::Mayo::AdapterSequences::File::Record(                  
        kit_name           => $kit_name,
        supply_item_name   => $supply_item_name,                        
        adapter            => $adapter
    );

    if (!defined($record)){
        $self->{_logger}->logconfess("Could not instantiate PGDX::Mayo::SummarySheet::Source::File::Record");
    }

    return $record;
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

sub getAdapterLookup {

    my $self = shift;
    
    if (exists $self->{_adapter_to_record_lookup}){
        return $self->{_adapter_to_record_lookup};
    }

    return undef;
}


no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

 PGDX::Mayo::AdapterSequences::File::Tab::Parser
 

=head1 VERSION

 1.0

=head1 SYNOPSIS

 use PGDX::Mayo::AdapterSequences::File::Tab::Parser;
 my $parser= PGDX::Mayo::AdapterSequences::File::Tab::Parser::getInstance(infile => $infile);
 $list->getRecordList();

=head1 AUTHOR

 Jaideep Sundaram

 Copyright Jaideep Sundaram

=head1 METHODS

=over 4

=cut