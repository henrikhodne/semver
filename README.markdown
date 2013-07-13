# semver

semver is a version parsing library for Ruby.

## Usage

``` Ruby
version = Semver.new("1.2.3")
version.to_s                      # => "1.2.3"
version.major                     # => 1
version.minor                     # => 2
version.patch                     # => 3
version.included_in?("~> 1.2.0")  # => true
```

## Installation

Coming soon. For now, just clone the repository and drop it in your load path.

## Requirements

semver requires ruby 2.0.0 or higher.

## Contributing

See CONTRIBUTING file.

## Running the tests

    ruby test/test_semver.rb

## License

semver is released under the MIT License. See the bundled LICENSE file  for
details.
