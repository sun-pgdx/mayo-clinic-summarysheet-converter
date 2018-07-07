package PGDX::File::Parser;

use Moose;
use Data::Dumper;

use PGDX::Logger;

use constant TRUE  => 1;

use constant FALSE => 0;

use constant DEFAULT_VERBOSE => TRUE;

has 'verbose' => (
    is       => 'rw',
    isa      => 'Bool',
    writer   => 'setVerbose',
    reader   => 'getVerbose',
    required => FALSE,
    default  => DEFAULT_VERBOSE
    );

has 'infile' => (
    is       => 'rw',
    isa      => 'Str',
    writer   => 'setInfile',
    reader   => 'getInfile',
    required => FALSE
    );

my $instance;

sub getInstance {

    if (!defined($instance)){

        $instance = new PGDX::File::Parser(@_);
        
        if (!defined($instance)){
            confess "Could not instantiate PGDX::File::Parser";
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

sub getRecordList {

    my $self = shift;
    
    if (! exists $self->{_record_list}){

        $self->_parse_file(@_);
    }

    return $self->{_record_list};
}

sub _checkInfileStatus {

    my $self = shift;
    my ($infile) = @_;

    if (!defined($infile)){
        $self->{_logger}->logconfess("infile was not defined");
    }

    my $errorCtr = 0 ;

    if (!-e $infile){
        $self->{_logger}->fatal("input file '$infile' does not exist");
        $errorCtr++;
    }
    else {
        if (!-f $infile){
            $self->{_logger}->fatal("'$infile' is not a regular file");
            $errorCtr++;
        }
        
        if (!-r $infile){
            $self->{_logger}->fatal("input file '$infile' does not have read permissions");
            $errorCtr++;
        }
        
        if (!-s $infile){
            $self->{_logger}->warn("input file '$infile' does not have any content");            
        }
    }

    if ($errorCtr > 0){
        $self->{_logger}->logconfess("Encountered issues with input file '$infile'");
    }
}


no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

 PGDX::File::Parser
 

=head1 VERSION

 1.0

=head1 SYNOPSIS

 use PGDX::File::Parser;
 my $parser = PGDX::File::Parser::getInstance(infile => $infile);
 $record_list->getRecordList();

=head1 AUTHOR

 Jaideep Sundaram

 Copyright Jaideep Sundaram

=head1 METHODS

=over 4

=cut