# NAME

MooseX::Fastly::Role - Fastly api from config, and purge methods

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

    $self->cdn_purge_now({
      keys => [ 'foo', 'bar' ],
      soft_purge => 1,
    });

    $self->cdn_purge_all();

    my $fastly = $self->cdn_api();
    my $services = $self->cdn_services();

# DESCRIPTION

[Fastly](https://www.fastly.com/) is a global CDN (Content Delivery Network),
used by many companies. This module requires a `config` method to return
a hashref. This packages uses [HTTP::Tiny](https://metacpan.org/pod/HTTP::Tiny) for most calls (so that you can
use Fastly's token authentication for purging keys), but also provides
accessors to [Net::Fastly](https://metacpan.org/pod/Net::Fastly) for convenience.

# METHODS

## cdn\_purge\_now

    $self->cdn_purge_now({
      keys => [ 'foo', 'bar' ],
      soft_purge => 1,
    });

Purge is called on all services, for each key.

## cdn\_purge\_all

    $self->cdn_purge_all();

Purge all is called on all services

# Net::Fastly

Methods below return objects from Net::Fastly.

## cdn\_api

    my $cdn_api = $self->cdn_api();

If there is a **fastly\_api\_key** in `config` a `Net::Fastly` instance is
created and returned. Otherwise undef is returned (so you can develope
safely if you do not set **fastly\_api\_key** in the `config`).

## cdn\_services

    my $services = $self->cdn_services();

An array reference of `Net::Fastly::Service` objects, based on the
`fastly_service_id` id(s) set in `config`.

The array reference will be empty if `fastly_service_id` is not found
in `config`.

# AUTHOR

Leo Lapworth <LLAP@cpan.org>

# LICENSE

This program is free software; you can redistribute it and/or modify it under
the terms same as Perl 5.
