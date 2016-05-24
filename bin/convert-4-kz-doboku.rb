#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rdf'
require 'rdf/turtle'
require 'rdf/vocab'
require 'csv'
require 'securerandom'


#INPUT_FILE="../original/playground-equipment_utf8.csv"
INPUT_FILE="../data/original/14108/4-kz-doboku_utf8.csv"
OUTPUT_FILE="../data/dumps/park/14108/4-kz-doboku.ttl"

PARK_RESOURCE = RDF::Vocabulary.new("http://openpark.jp/parks/14108/")
EQUIPMENT_RESOURCE = RDF::Vocabulary.new("http://openpark.jp/equipment/14108/")
ORGANIZATION_RESOURCE = RDF::Vocabulary.new("http://openpark.jp/organizations/14108/")
IC = RDF::Vocabulary.new("http://imi.ipa.go.jp/ns/core/rdf#")
PARK = RDF::Vocabulary.new("http://openpark.jp/ns/park#")

PREFIXES = {
  :rdf => RDF.to_s,
  :rdfs => RDF::RDFS.to_s,
  :schema => RDF::Vocab::SCHEMA.to_s,
  :geo => RDF::Vocab::GEO.to_s,
  :dcterms => RDF::Vocab::DC.to_s,
  :skos => RDF::Vocab::SKOS.to_s,
  :xsd => RDF::XSD.to_s,
  :park_resource => PARK_RESOURCE.to_s,
  :equipment_resource => EQUIPMENT_RESOURCE.to_s,
  :organization_resource => ORGANIZATION_RESOURCE.to_s,
  :ic => IC.to_s,
  :park => PARK.to_s
}

def to_western_year(year)
  if /H(\d+)/.match(year)
    1989 + $1.to_i
  else
    1926 + $1.to_i
  end
end

firstline = true
id = 1

RDF::Writer.open(OUTPUT_FILE, :prefixes => PREFIXES) do |writer|
  CSV.foreach(INPUT_FILE) do |row|
    if firstline
      firstline = false
      next
    end
    lower_age_limit, upper_age_limit = row[9].split(/〜/) if row[9] and !row[9].empty?
    equipment_name = row[4].dup
    equipment_name << " - #{row[5]}" if row[5] and !row[5].empty?
    equipment_uri = EQUIPMENT_RESOURCE[id.to_s]
    park_uri = PARK_RESOURCE[row[3]]
    park_concept = PARK[row[2]]
    equipment_concept = PARK[row[4]]

    turtle = "<#{park_uri}> ic:種別 \"#{row[2]}\"@ja ;
        ic:設備 <#{equipment_uri}> .
"
    turtle << "<#{equipment_uri}> a park:遊具型 ;
        ic:ID [ a ic:ID型 ;
          ic:識別値 \"#{id.to_s}\"
        ] ;
        ic:名称 [ a ic:名称型 ;
          ic:表記 \"#{equipment_name}\"@ja
        ] ;
        ic:設置地点 <#{park_uri}> ;
        ic:管理者 <#{ORGANIZATION_RESOURCE[row[0]]}> ;
        ic:利用者 \"対象年齢: #{row[9]}\"@ja ;\n"
    turtle << "        park:年齢下限 \"#{lower_age_limit}\"^^xsd:integer ;\n" if lower_age_limit
    turtle << "        park:年齢上限 \"#{upper_age_limit}\"^^xsd:integer ;\n" if upper_age_limit
    turtle << "        park:数量 \"#{row[6]}\"^^xsd:integer ;\n" if row[6]
    turtle << "        park:仕様・規格 \"#{row[5]}\"@ja ;\n" if row[5]
    turtle << "        ic:種別 \"#{row[4]}\"@ja .\n\n"

    graph = RDF::Graph.new
    graph.from_ttl(turtle, :prefixes => PREFIXES)
    writer << graph
    id = id.succ
  end
  ["金沢土木事務所", "南部公園緑地事務所"].each do |name|
    turtle = "<#{ORGANIZATION_RESOURCE[name]}> a ic:組織型 ;
      ic:名称 [ a ic:名称型 ;
        ic:表記 \"#{name}\"@ja
      ] .
    "
    graph = RDF::Graph.new
    graph.from_ttl(turtle, :prefixes => PREFIXES)
    writer << graph
  end
end
