## Pragmatic ONIX 3.0 parser for Ruby

### Low level API
Whole structure is accessible through ONIX::ONIXMessage object :
```ruby
message = ONIX::ONIXMessage.new
message.parse("onix_file.xml")
# first product
pp message.products.first
# first identifier of first product
pp message.products.first.identifiers.first
```

Ruby elements variables are underscored, lowercase of ONIX tags (Product -> product, DescriptiveDetail -> descriptive_detail) and pluralized in case of array (ProductSupply -> product_supplies).

#### Using reader

Able to optionally stream each product rather than read the full ONIX file at once. This can be helpful for large ONIX files.

nb. The version will need to be explicitly, and each `product` is yielded exactly once. For more info on this pattern see [Nokogiri::XML::Reader](https://nokogiri.org/rdoc/Nokogiri/XML/Reader.html)

```ruby
onix_message = ONIX::ONIXMessage.new
onix_message.set_release_from_xml({}, '3.0')
onix_message.reader("onix_file.xml")
onix_message.each { |product| ...handle product... }
```

### High level API
High level methods give abstracted and simplified access to the most important data.  
See https://www.rubydoc.info/gems/im_onix/ONIX/Product for high level API rdoc and onix_pp.rb, onix3_to_onix2.rb and onix3_to_onix3.rb sample in bin/

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
bundle exec rake test
```

### Contributors
TEA "The Ebook Alternative" : http://www.tea-ebook.com/

Bookmate : https://bookmate.com/
