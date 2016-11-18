package MooseX::Fastly::Role;

use Moose::Role;
use Carp;
use HTTP::Tiny;

requires 'config';    # Where we can read our config from?!?

sub _cdn_service_ids {
    my $self = $_[0];
    my @service_ids;

    my $service_ids = $self->config->{fastly_service_id};

    return \@service_ids unless $service_ids;

    @service_ids
        = ref($service_ids) eq 'ARRAY' ? @{$service_ids} : ($service_ids);
    return \@service_ids;
}

has '_fastly_http_client' => (
    is         => 'ro',
    lazy_build => '_build__fastly_http_client',
);

sub _build__fastly_http_client {
    my $self = $_[0];

    my $token = $self->config->{fastly_api_key};
    return unless $token;

    my $http_requester = HTTP::Tiny->new(
        default_headers => {
            'Fastly-Key' => $token,
            'Accept'     => 'application/json'
        },
    );
    return $http_requester;
}

=head1 NAME

MooseX::Fastly::Role - Instantiate Net::Fastly api from config and purge methods

=head1 SYSOPSIS

  package My::App::CDN::Manager;

  use Moose;

  has config => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        {
              fastly_api_key => 'XXXXX',
              fastly_service_id => 'YYYYY',
        };
    },
  );

  with 'MooseX::Fastly::Role';

  $self->cdn_purge_now({
    keys => [ 'foo', 'bar' ],
    soft_purge => 1,
  });

  $self->cdn_purge_all();

=head1 DESCRIPTION

L<Fastly|https://www.fastly.com/> is a global CDN (Content Delivery Network),
used by many companies. This module requires a C<config> method to return
a hashref.

=head1 METHODS

=head2 cdn_purge_now

  $self->cdn_purge_now({
    keys => [ 'foo', 'bar' ],
    soft_purge => 1,
  });

Purge is called on all services, for each key.

=cut

sub cdn_purge_now {
    my ( $self, $args ) = @_;

    my $services = $self->_cdn_service_ids();

    foreach my $service_id ( @{$services} ) {
        foreach my $key ( @{ $args->{keys} || [] } ) {
            my $url = "/service/${service_id}/purge/${key}";
            $self->_call_fastly( $url, $args->{soft_purge} );
        }
    }

    return 1;
}

sub _call_fastly {
    my ( $self, $url, $soft_purge ) = @_;
    $soft_purge ||= '0';

    my $full_url = 'https://api.fastly.com' . $url;

    $self->_log_fastly_call("Purging ${url}");

    my $http_requester = $self->_fastly_http_client();
    return unless $http_requester;

    my $response = $http_requester->post( $full_url,
        { 'Fastly-Soft-Purge' => $soft_purge, } );

    if ( !$response->{success} || $response->{content} !~ '"status": "ok"' ) {
        $self->_log_fastly_call(
            "Failed to purge: $full_url" . $response->{content} || '' );
    }

}

sub _log_fastly_call {
    if ( $ENV{DEBUG_FASTLY_CALLS} ) {
        warn $_[1];
    }
}

=head2 cdn_purge_all

  $self->cdn_purge_all();

Purge all is called on all services

=cut

sub cdn_purge_all {
    my ( $self, $args ) = @_;

    my $services = $self->_cdn_service_ids();

    foreach my $service_id ( @{$services} ) {
        foreach my $key ( @{ $args->{keys} || [] } ) {
            my $url = "/service/${service_id}/purge_all";
            $self->_call_fastly( $url, $args->{soft_purge} );
        }
    }

    return 1;
}

=head2 cdn_api

This no longer works, heavily depreciated!

=cut

sub cdn_api {
    warn "cdn_api - Not implimented any more, use Net::Fastly directly";
    return 0;
}

=head2 cdn_services

This no longer works, heavily depreciated!

=cut

sub cdn_services {
    warn "cdn_services does not work any more";
    return 0;
}

=head1 AUTHOR

Leo Lapworth <LLAP@cpan.org>

=cut

1;
