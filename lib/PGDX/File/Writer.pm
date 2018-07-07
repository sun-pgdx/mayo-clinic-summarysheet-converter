package PGDX::File::Writer;

use Moose;

use PGDX::Logger;


use constant TRUE  => 1;
use constant FALSE => 0;

use constant DEFAULT_TEST_MODE => TRUE;

use constant DEFAULT_VERBOSE => TRUE;

has 'verbose' => (
    is       => 'rw',
    isa      => 'Bool',
    writer   => 'setVerbose',
    reader   => 'getVerbose',
    required => FALSE,
    default  => DEFAULT_VERBOSE
    );

has 'outfile' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setOutfile',
    reader   => 'getOutfile',
    required => FALSE
    );

has 'header_list' => (
    is       => 'rw',
    isa      => 'ArrayRef',
    writer   => 'setHeaderList',
    reader   => 'getHeaderList',
    required => FALSE
    );

has 'delimiter' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setDelimiter',
    reader   => 'getDelimiter',
    required => FALSE
    );

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



no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

 PGDX::ImmunoSELECT::Trigger::File::Writer
 

=head1 VERSION

 1.0

=head1 SYNOPSIS

 use PGDX::File::Writer;
 my $writer = new PGDX::File::Writer();
 $writer->writeFile($outfile);

=head1 AUTHOR

 Jaideep Sundaram

 Copyright Jaideep Sundaram

=head1 METHODS

=over 4

=cut