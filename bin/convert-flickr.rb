#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rdf'
require 'rdf/turtle'
require 'csv'
require 'securerandom'


INPUT_FILE="../original/flickr.csv"
OUTPUT_FILE="../ttl/flickr.ttl"

PARK = RDF::Vocabulary.new("http://yokohama.openpark.jp/parks/")
OPENPARK = RDF::Vocabulary.new("http://openpark.jp/ns/openpark#")
IC = RDF::Vocabulary.new("http://imi.ipa.go.jp/ns/core/210#")

PREFIXES = {
  :rdf => RDF.to_s,
  :rdfs => RDF::RDFS.to_s,
  :schema => RDF::SCHEMA.to_s,
  :geo => RDF::GEO.to_s,
  :dcterms => RDF::DC.to_s,
  :xsd => RDF::XSD.to_s,
  :park => PARK.to_s,
  :openpark => OPENPARK.to_s,
  :ic => IC.to_s
}

firstline = true

RDF::Writer.open(OUTPUT_FILE, :prefixes => PREFIXES) do |writer|
  CSV.foreach(INPUT_FILE) do |row|
    if firstline
      firstline = false
      next
    end
    graph = RDF::Graph.new
    if row[10] && ! row[10].empty?
      graph.from_ttl("park:#{row[1]} openpark:flickrID \"#{row[10]}\"@ja .", :prefixes => PREFIXES)
    end

    writer << graph
  end
end
