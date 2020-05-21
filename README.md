# maeq-linky_exporter

[![Build Status Travis](https://img.shields.io/travis/com/syberalexis/puppet-linky_exporter/master?label=build%20travis)](https://travis-ci.com/syberalexis/puppet-linky_exporter)
[![Puppet Forge](https://img.shields.io/puppetforge/v/maeq/linky_exporter.svg)](https://forge.puppetlabs.com/maeq/linky_exporter)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/maeq/linky_exporter.svg)](https://forge.puppetlabs.com/maeq/linky_exporter)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/maeq/linky_exporter.svg)](https://forge.puppetlabs.com/maeq/linky_exporter)
[![Apache-2 License](https://img.shields.io/github/license/syberalexis/puppet-linky_exporter.svg)](LICENSE)

#### Table of Contents

- [Description](#description)
- [Usage](#usage)
- [Examples](#examples)
- [Development](#development)

## Description

This module automates the install of [linky Exporter](https://github.com/syberalexis/linky-exporter).  

## Usage

For more information see [REFERENCE.md](REFERENCE.md).

### Install linky Exporter

#### Puppet
```puppet
include linky_exporter
```

## Examples

#### Change device file

```yaml
linky_exporter::serial_device: '/dev/ttyAMA0'
```

## Development

This project contains tests for [rspec-puppet](http://rspec-puppet.com/).

Quickstart to run all linter and unit tests:
```bash
bundle install --path .vendor/
bundle exec rake test
```
