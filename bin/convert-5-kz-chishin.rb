#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rdf'
require 'rdf/turtle'
require 'rdf/vocab'
require 'csv'
require 'securerandom'


INPUT_FILE="../data/original/14108/5-kz-chishin_utf8.csv"
OUTPUT_FILE="../data/dumps/park/14108/5-kz-chishin.ttl"

PARK_RESOURCE = RDF::Vocabulary.new("http://openpark.jp/parks/14108/")
IC = RDF::Vocabulary.new("http://imi.go.jp/ns/core/rdf#")
PARK = RDF::Vocabulary.new("http://openpark.jp/ns/park#")

PREFIXES = {
  :rdf => RDF.to_s,
  :rdfs => RDF::RDFS.to_s,
  :schema => RDF::Vocab::SCHEMA.to_s,
  :geo => RDF::Vocab::GEO.to_s,
  :dcterms => RDF::Vocab::DC.to_s,
  :xsd => RDF::XSD.to_s,
  :park_resource => PARK_RESOURCE.to_s,
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
    turtle = """park_resource:#{row[0]} a park:公園型 ;
  ic:ID [ a ic:ID型 ;
    ic:識別値 \"#{row[0]}\" ;
  ] ;
  ic:名称 [ a ic:名称型; ic:表記 \"#{row[1]}\"@ja ] ;
  ic:住所 [ a ic:住所型;
    ic:表記 \"#{row[4]}\"@ja ;
    ic:郵便番号 \"#{row[3]}\" ;
    ic:都道府県 \"神奈川県\"@ja ;
    ic:市区町村 \"横浜市\"@ja ;
    ic:区 \"金沢区\"@ja ;
  ] ;"""
    if row[5]
      turtle <<  """  park:面積 [ a ic:面積型 ;
    ic:数値 \"#{row[5].gsub(/,/,'')}\"^^xsd:decimal ;
  ] ;"""
    end
    turtle << """  ic:地理座標 [ a ic:座標型 ;
    ic:緯度 \"#{row[7]}\" ;
    ic:経度 \"#{row[6]}\" ;
  ] ."""

    graph.from_ttl(turtle, :prefixes => PREFIXES)
    writer << graph
  end
end
