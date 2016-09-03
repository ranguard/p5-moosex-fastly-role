package MooseX::Fastly::Role;

use Moose::Role;

use Net::Fastly 1.05;
use Carp;

requires 'config';    # Where we can read our config from?!?

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

  my $cdn_api = $self->cdn_api;

  my $services = $self->cdn_services;

  $self->cdn_purge_now({
    keys => [ 'foo', 'bar' ],
    soft_purge => 1,
  });

  $self->cdn_purge_all();

=head1 DESCRIPTION

L<Fastly|https://www.fastly.com/> is a global CDN (Content Delivery Network),
used by many companies. This module is a Moosification around L<Net::Fastly>
and requires a C<config> method to return a hashref (see C<cdn_api> below).

Method names have been kept generic B<cdn_..> so that if another CDN's api
can support the same sorts of methods, a drop in replacement could be created.

=head1 METHODS

=head2 cdn_api

  my $cdn_api = $self->cdn_api;

If there is a B<fastly_api_key> in C<config> a C<Net::Fastly> instance is
created and returned. Otherwise undef is returned (so you can develope
safely if you do not set B<fastly_api_key> in the C<config>).

=cut

has 'cdn_api' => (
    is         => 'ro',
    lazy_build => '_build_cdn_api',
);

sub _build_cdn_api {
    my $self = $_[0];

    my $api_key = $self->config->{fastly_api_key};
    return undef unless $api_key;

    # We have the credentials, so must be on production
    my $fastly = Net::Fastly->new( api_key => $api_key );
    return $fastly;
}

=head2 cdn_services

   my $services = $self->cdn_services;

An array reference of C<Net::Fastly::Service> objects, based on the
C<fastly_service_id> id(s) set in C<config>.

The array reference will be empty if C<fastly_service_id> is not found
in C<config>.

=cut

has 'cdn_services' => (
    is         => 'ro',
    lazy_build => '_build_cdn_services',
);

sub _build_cdn_services {
    my ( $self, $args ) = @_;

    my @services;

    my $service_ids = $self->config->{fastly_service_id};
    return \@services unless $service_ids;

    my $cdn_api = $self->cdn_api();
    return \@services unless $cdn_api;

    my @service_ids
        = ref($service_ids) eq 'ARRAY' ? @{$service_ids} : ($service_ids);

    @services = map { $cdn_api->get_service($service_ids) } @service_ids;

    return \@services;
}

=head2 cdn_purge_now

  $self->cdn_purge_now({
    keys => [ 'foo', 'bar' ],
    soft_purge => 1,
  });

Purge is called on all C<cdn_services>, for each key.

=cut

sub cdn_purge_now {
    my ( $self, $args ) = @_;

    my $services = $self->cdn_services();

    foreach my $service ( @{$services} ) {
        foreach my $key ( @{ $args->{keys} || [] } ) {
            $service->purge_by_key( $key, $args->{soft_purge} );
        }
    }

    return 1;
}

=head2 cdn_purge_all

  $self->cdn_purge_all();

Purge all is called on all C<cdn_services>!

=cut

sub cdn_purge_all {
    my $self = $_[0];

    my $services = $self->cdn_services();

    foreach my $service ( @{$services} ) {
        $service->purge_all;
    }

    return 1;
}

=head1 SEE ALSO

L<Net::Fastly>

=head1 AUTHOR

Leo Lapworth <LLAP@cpan.org>

=cut

1;
