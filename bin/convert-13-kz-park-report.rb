#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rdf'
require 'rdf/turtle'
require 'csv'
require 'securerandom'


INPUT_FILE="../original/13-kz-park-report_utf8.csv"
OUTPUT_FILE="../ttl/13-kz-park-report.ttl"

PARK = RDF::Vocabulary.new("http://kanazawa.openpark.jp/parks/")
IC = RDF::Vocabulary.new("http://imi.ipa.go.jp/ns/core/210#")

PREFIXES = {
  :rdf => RDF.to_s,
  :rdfs => RDF::RDFS.to_s,
  :schema => RDF::SCHEMA.to_s,
  :geo => RDF::GEO.to_s,
  :dcterms => RDF::DC.to_s,
  :xsd => RDF::XSD.to_s,
  :park => PARK.to_s,
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
    graph.from_ttl("park:#{row[1]} dcterms:description \"#{row[2]}\"@ja .", :prefixes => PREFIXES)

    writer << graph
  end
end
