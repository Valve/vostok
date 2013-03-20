# Vostok

[![Build Status](https://travis-ci.org/Valve/vostok.png)](https://travis-ci.org/Valve/vostok)

Sick pg import

## Installation

Add this line to your application's Gemfile:

    gem 'vostok'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vostok

## Usage

Vostok works directly with PG gem, no other dependencies

```ruby

require 'vostok'

import = Vostok::Import.new(dbname: 'test', user: 'developer', password: 'r00t')
data = []
1_000.times do
  data << ['String', 99]
end

import.start(:customers, [:name, :balance], data)

```

What Vostok does not do:

1. Run validations
2. Integrates with your ORM
3. Works with other DBs
4. Sanitizes your data

However, what it does is insert rows at a sick rate.

`
10_000 rows inserted with AR - 18 seconds
`

`
10_000 rows inserted with Vostok - 0.2 seconds
`


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add your tests and run them with `rspec spec`
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request


## License


Copyright (c) 2013 Valentin Vasilyev

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
