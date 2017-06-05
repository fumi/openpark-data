#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rdf'
require 'rdf/turtle'
require 'rdf/vocab'
require 'csv'
require 'securerandom'


INPUT_FILE="../data/original/14108/13-kz-park-report_utf8.csv"
OUTPUT_FILE="../data/dumps/park/14108/13-kz-park-report.ttl"

PARK_RESOURCE = RDF::Vocabulary.new("http://openpark.jp/parks/14108/")
IC = RDF::Vocabulary.new("http://imi.go.jp/ns/core/rdf#")

PREFIXES = {
  :rdf => RDF.to_s,
  :rdfs => RDF::RDFS.to_s,
  :geo => RDF::Vocab::GEO.to_s,
  :dcterms => RDF::Vocab::DC.to_s,
  :xsd => RDF::XSD.to_s,
  :park_resource => PARK_RESOURCE.to_s,
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
    graph.from_ttl("park_resource:#{row[0]} ic:説明 \"#{row[2]}\"@ja .", :prefixes => PREFIXES)

    writer << graph
  end
end
