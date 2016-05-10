#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rdf'
require 'rdf/turtle'
require 'rdf/vocab'
require 'csv'
require 'securerandom'


INPUT_FILE="../original/23-kz-park_utf8.csv"
OUTPUT_FILE="../ttl/23-kz-park.ttl"

PARK_RESOURCE = RDF::Vocabulary.new("http://openpark.jp/park/14108/")
IC = RDF::Vocabulary.new("http://imi.ipa.go.jp/ns/core/rdf#")
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
    graph.from_ttl("park_resource:#{row[1]} a ic:施設型 ;
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
                      ] ;
                      ic:地理識別子 [ a ic:座標型 ;
                        ic:緯度 \"#{row[6]}\" ;
                        ic:経度 \"#{row[5]}\" ;
                      ]
                      .
                   ", :prefixes => PREFIXES)

    writer << graph
  end
end
