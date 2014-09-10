# build contains:
# - ubuntu-14.04
# - runit configured for service supervision
# - git
# - ruby MRI 2.1.2
# - rubygems
# - bundler

FROM ubuntu:14.04

MAINTAINER Dan Corrigan <dcorrigan@scribenet.com>
# based on nepalez/ruby, minus some things we don't need

# Ensure UTF-8 locale
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8
RUN dpkg-reconfigure locales

# update package manager cache
RUN apt-get update -qq

# Install build dependencies
RUN apt-get install -y -qq \
  build-essential \
  curl \
  libffi-dev \
  libgdbm-dev \
  libssl-dev \
  libtool \
  libxml2-dev \
  libxslt-dev \
  libyaml-dev \
  runit \
  software-properties-common \
  wget \
  zlib1g-dev

# ==============================================================================
# configure Runit 
# ==============================================================================
ADD runsvdir.conf /etc/init/runsvdir.conf
RUN start runsvdir

# ==============================================================================
# Git
# ==============================================================================

# Add official git APT repositories
RUN apt-add-repository ppa:git-core/ppa

# Install git
RUN apt-get install -y -qq git

# ==============================================================================
# Ruby 
# ==============================================================================

# Set $PATH so that non-login shells will see the Ruby binaries
ENV PATH $PATH:/opt/rubies/ruby-2.1.2/bin

# Install MRI Ruby 2.1.2
RUN curl -O http://ftp.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz && \
  tar -zxvf ruby-2.1.2.tar.gz && \
  cd ruby-2.1.2 && \
  ./configure --disable-install-doc && \
  make && \
  make install && \
  cd .. && \
  rm -r ruby-2.1.2 ruby-2.1.2.tar.gz

# ==============================================================================
# rubygems
# ==============================================================================

# Install rubygems
ADD http://production.cf.rubygems.org/rubygems/rubygems-2.3.0.tgz /tmp/
RUN cd /tmp && tar -zxf /tmp/rubygems-2.3.0.tgz
RUN cd /tmp/rubygems-2.3.0 && ruby setup.rb

# ==============================================================================
# bundler 
# ==============================================================================

# Install bundler gem globally
RUN /bin/bash -l -c 'gem install bundler --no-rdoc --no-ri'

# ==============================================================================
# cleanup 
# ==============================================================================

RUN apt-get clean -qq && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
