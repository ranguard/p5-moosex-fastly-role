# NAME

MooseX::Fastly::Role - Instantiate Net::Fastly api from config and purge methods

# SYSOPSIS

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

# DESCRIPTION

[Fastly](https://www.fastly.com/) is a global CDN (Content Delivery Network),
used by many companies. This module is a Moosification around [Net::Fastly](https://metacpan.org/pod/Net::Fastly)
and requires a `config` method to return a hashref (see `cdn_api` below).

Method names have been kept generic **cdn\_..** so that if another CDN's api
can support the same sorts of methods, a drop in replacement could be created.

# METHODS

## cdn\_api

    my $cdn_api = $self->cdn_api;

If there is a **fastly\_api\_key** in `config` a `Net::Fastly` instance is
created and returned. Otherwise undef is returned (so you can develope
safely if you do not set **fastly\_api\_key** in the `config`).

## cdn\_services

    my $services = $self->cdn_services;

An array reference of `Net::Fastly::Service` objects, based on the
`fastly_service_id` id(s) set in `config`.

The array reference will be empty if `fastly_service_id` is not found
in `config`.

## cdn\_purge\_now

    $self->cdn_purge_now({
      keys => [ 'foo', 'bar' ],
      soft_purge => 1,
    });

Purge is called on all `cdn_services`, for each key.

## cdn\_purge\_all

    $self->cdn_purge_all();

Purge all is called on all `cdn_services`!

# SEE ALSO

[Net::Fastly](https://metacpan.org/pod/Net::Fastly)

# AUTHOR

Leo Lapworth <LLAP@cpan.org>
