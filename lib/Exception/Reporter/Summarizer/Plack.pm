use strict;
use warnings;
package Exception::Reporter::Summarizer::Plack;

use parent 'Exception::Reporter::Summarizer';
# ABSTRACT: a summarizer for Plack applications

use Plack::Request;

=head1 OVERVIEW

If added as a summarizer to an L<Exception::Reporter>, this plugin will
summarize L<Plack::Request> objects, adding a summary for the request.

=cut

use Try::Tiny;

sub new {
  my ($class, $arg) = @_;
  $arg ||= {};

  return bless { } => $class;
}

sub can_summarize {
  my ($self, $entry) = @_;
  return try { $entry->[1]->isa('Plack::Request') };
}

sub summarize {
  my ($self, $entry) = @_;
  my ($name, $req, $arg) = @$entry;

  my @summaries;

  push @summaries, $self->summarize_request($req);

  return @summaries;
}

sub summarize_request {
  my ($self, $req) = @_;

  my %to_dump = map {
    $_ => defined($req->$_) ? ($req->$_ . "") : undef,
  } qw(
    address
    content_length
    content_type
    content_encoding
    remote_host
    protocol
    method
    port
    user
    request_uri
    path_info
    path
    query_string
    referer
    user_agent
    script_name
    scheme
    secure
  );

  $to_dump{upload} = [ $req->upload ];
  $to_dump{cookies} = $req->cookies;

  return {
    filename => 'request.txt',
    %{ $self->dump(\%to_dump, { basename => 'request' })  },
    ident    => 'plack request',
  };
}

1;
