package PGDX::Smartsheet::File::Tab::Writer;

use Moose;
use Data::Dumper;

use PGDX::Logger;

extends 'PGDX::File::Writer';

use constant TRUE  => 1;
use constant FALSE => 0;

has 'record_list' => (
    is       => 'rw',
    isa      => 'ArrayRef',
    writer   => 'setRecordList',
    reader   => 'getRecordList',
    required => FALSE
    );


sub BUILD {

    my $self = shift;

    $self->_initLogger(@_);

    $self->_initConfigManager(@_);

    $self->{_logger}->info("Instantiated ". __PACKAGE__);
}

sub writeFile {

    my $self = shift;
    my ($record_list) = @_;
    
    if (!defined($record_list)){
    
        $record_list = $self->getRecordList();
    
        if (!defined($record_list)){
            $self->{_logger}->logconfess("record_list was not defined");
        }
    }

    my $outfile = $self->getOutfile();

    open (OUTFILE, ">$outfile") || $self->{_logger}->logconfess("Could not open '$outfile' in write mode : $!");
    
    print OUTFILE "PGDXID\tAlternate ID\tBatch\n";

    foreach my $list (@{$record_list}){

        print OUTFILE join("\t", @{$list}) . "\n";
    }

    close OUTFILE;
    
    $self->{_logger}->info("Wrote smartsheet records to '$outfile'");
    
    print ("Wrote smartsheet records to '$outfile'\n");    
}


no Moose;
__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

 PGDX::Smartsheet::File::Tab::Writer
 

=head1 VERSION

 1.0

=head1 SYNOPSIS

 use PGDX::Smartsheet::File::Tab::Writer;
 my $writer = new PGDX::Smartsheet::File::Tab::Writer(outfile => $outfile, record_list => $record_list);
 $writer->writeFile();

=head1 AUTHOR

 Jaideep Sundaram

 Copyright Jaideep Sundaram

=head1 METHODS

=over 4

=cut