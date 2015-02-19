## Pragmatic ONIX 3.0 parser for Ruby

### Low level API
Whole structure is accessible through ONIX::ONIXMessage object :
```ruby
message=ONIX::ONIXMessage.new
message.parse("onix_file.xml")
# first product
pp message.products.first
# first identifier of first product
pp message.products.first.identifiers.first
```

Ruby elements variables are underscored, lowercase of ONIX tags (Product -> product, DescriptiveDetail -> descriptive_detail) and pluralized in case of array (ProductSupply -> product_supplies).

### High level API
High level methods give abstracted and simplified access to the most important data.
See http://nu.immateriel.fr/im_onix/doc/ONIX/Product.html for high level API rdoc and onix_pp.rb, onix3_to_onix2.rb and onix3_to_onix3.rb sample in bin/

Usage :
```shell
onix_pp.rb onix.xml
onix3_to_onix2.rb onix.xml
onix3_to_onix3.rb onix.xml
```
### Development

#### Running the tests

Launch this command:

```
ruby -Ilib:test test/test_im_onix.rb
```


### License
Copyright (C) 2013 immatériel.fr

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
