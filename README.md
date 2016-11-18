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

    $self->cdn_purge_now({
      keys => [ 'foo', 'bar' ],
      soft_purge => 1,
    });

    $self->cdn_purge_all();

# DESCRIPTION

[Fastly](https://www.fastly.com/) is a global CDN (Content Delivery Network),
used by many companies. This module requires a `config` method to return
a hashref.

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

## cdn\_api

This no longer works, heavily depreciated!

## cdn\_services

This no longer works, heavily depreciated!

# AUTHOR

Leo Lapworth <LLAP@cpan.org>
