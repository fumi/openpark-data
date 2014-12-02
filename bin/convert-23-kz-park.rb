#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rdf'
require 'rdf/turtle'
require 'csv'
require 'securerandom'


INPUT_FILE="../original/23-kz-park_utf8.csv"
OUTPUT_FILE="../ttl/23-kz-park.ttl"

PARK_RESOURCE = RDF::Vocabulary.new("http://yokohama.openpark.jp/parks/")
IC = RDF::Vocabulary.new("http://imi.ipa.go.jp/ns/core/210#")
PARK = RDF::Vocabulary.new("http://yokohama.openpark.jp/ns/park#")

PREFIXES = {
  :rdf => RDF.to_s,
  :rdfs => RDF::RDFS.to_s,
  :schema => RDF::SCHEMA.to_s,
  :geo => RDF::GEO.to_s,
  :dcterms => RDF::DC.to_s,
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
    year, month, day = row[7].split('/')
    updated_date = "%04d-%02d-%02d" % [year, month, day]
    graph = RDF::Graph.new
    graph.from_ttl("park_resource:#{row[1]} a schema:Park, schema:CivicStructure, schema:Place, schema:Thing, ic:地点, ic:施設, park:公園, geo:SpatialThing ;
                      rdfs:label \"#{row[1]}\"@ja  ;
                      schema:address [ a schema:PostalAddress ;
                        schema:postalCode \"#{row[3]}\" ;
                        schema:streetAddress \"#{row[4].gsub('神奈川県横浜市', '')}\"@ja ;
                        schema:addressLocality \"横浜市\"@ja ;
                        schema:addressRegion \"神奈川県\"@ja ;
                      ] ;
                      geo:lat \"#{row[6]}\"^^xsd:float ;
                      geo:long \"#{row[5]}\"^^xsd:float ;
                      dcterms:identifier \"#{row[0]}\" ;
                      dcterms:updated \"#{updated_date}\"^^xsd:date ;
                      ic:地点_名称 \"#{row[1]}\"@ja ;
                      ic:地点_場所 [ a ic:場所 ;
                        ic:場所_住所 [ a ic:住所 ;
                          ic:住所_郵便番号 \"#{row[3]}\" ;
                          ic:住所_表記 \"#{row[4]}\"@ja ;
                        ] 
                      ]
                      .
                   ", :prefixes => PREFIXES)

    writer << graph
  end
end
