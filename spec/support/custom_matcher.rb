require 'rspec/expectations'

RSpec::Matchers.define :validate_against do |xsd|
  match do |actual|
    schema_doc = XML::Document.file("spec/fixtures/#{xsd}")
    schema = XML::Schema.document(schema_doc)
    actual.validate_schema(schema)
  end
end
