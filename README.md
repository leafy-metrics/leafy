# Port of Dropwizard Metrics-Core

This is literal port of [http://metrics.dropwizard.io/3.1.0/](http://metrics.dropwizard.io/3.1.0/). as the naming convention of Java is slightly different some internal variable names still following the Java naming convention. all public method names are using Ruby naming conventions.

There are also serveral parts missing, they are easy to add to contributions here are welcome.

Most work was only possible to excelant [concurrency-ruby gem](https://github.com/ruby-concurrency/concurrent-ruby) which allows to copy most concurrency semantic one to one over to ruby. This gem really made the port a `copy and paste` and then `find and replace` job.

## State of the Code

Currently no Reporters are there. once they are in place things are ready to be used.

## Rubygems/Bundler

```
gem install metrics-core
```

or Gemfile:
```
gem 'metrics-core'
```

## Getting Started

TBD

## Misssing Bits from Dropwizard

### Gauge

none of the is done.

### Reservoir

only the `SlidingWindowReservoir` and its `UniformSnapshot` is implemented.

### MetricRegistry

* no listeners
* no MetricSet
* no MetricFilters on collection methods
* no customer builder via Supplier
* no Gauge factory methods

## Contributing

Bug reports and pull requests are welcome.

## Alternative Libraries

* [Ruby-Metrics](https://github.com/johnewart/ruby-metrics)
* maybe others

## Meta-Foo

be happy and enjoy.
