#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rdf'
require 'rdf/turtle'
require 'csv'
require 'securerandom'


#INPUT_FILE="../original/playground-equipment_utf8.csv"
INPUT_FILE="../original/4-kz-doboku_utf8.csv"
OUTPUT_FILE="../ttl/playground-equipment.ttl"

PARK_RESOURCE = RDF::Vocabulary.new("http://yokohama.openpark.jp/parks/")
EQUIPMENT_RESOURCE = RDF::Vocabulary.new("http://yokohama.openpark.jp/equipment/")
ORGANIZATION_RESOURCE = RDF::Vocabulary.new("http://yokohama.openpark.jp/organizations/")
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
    upper_age_limit, lower_age_limit = row[9].split(/〜/) if row[9] and !row[9].empty?
    equipment_name = row[4].dup
    equipment_name << " - #{row[5]}" if row[5] and !row[5].empty?
    equipment_uri = EQUIPMENT_RESOURCE[id.to_s]
    park_uri = PARK_RESOURCE[row[3]]
    park_class = PARK[row[2]]
    equipment_class = PARK[row[4]]

    graph = RDF::Graph.new
    graph << [park_uri, IC["地点_設備"], equipment_uri]
    graph << [park_uri, RDF.type, park_class]
    graph << [park_class, RDF.type, RDF::RDFS.Class]
    graph << [park_class, RDF::RDFS.label, RDF::Literal(row[2], :language => :ja)]
    graph << [park_class, RDF::RDFS.subClassOf, PARK["公園"]]
    graph << [equipment_uri, RDF.type, IC["設備"]]
    graph << [equipment_uri, RDF.type, equipment_class]
    graph << [equipment_class, RDF.type, RDF::RDFS.Class]
    graph << [equipment_class, RDF::RDFS.label, RDF::Literal(row[4], :language => :ja)]
    graph << [equipment_class, RDF::RDFS.subClassOf, PARK["遊戯施設"]]
    graph << [equipment_uri, RDF::DC.identifier, RDF::Literal(id.to_s)]
    graph << [equipment_uri, RDF::RDFS.label, RDF::Literal(equipment_name, :language => :ja)]
    graph << [equipment_uri, IC["設備_名称"], RDF::Literal(equipment_name, :language => :ja)]
    graph << [equipment_uri, IC["設備_設置地点"], park_uri]
    graph << [equipment_uri, IC["設備_管理者"], ORGANIZATION_RESOURCE[row[0]]]
    graph << [equipment_uri, IC["利用者"], RDF::Literal("対象年齢: #{row[9]}", :language => :ja)] if row[9]
    graph << [equipment_uri, PARK["年齢下限"], RDF::Literal(upper_age_limit, :datatype => RDF::XSD.integer)] if upper_age_limit
    graph << [equipment_uri, PARK["年齢上限"], RDF::Literal(lower_age_limit, :datatype => RDF::XSD.integer)] if lower_age_limit
    graph << [equipment_uri, PARK["数量"], RDF::Literal(row[6], :datatype => RDF::XSD.integer)] if row[6]
    graph << [equipment_uri, PARK["仕様・規格"], RDF::Literal(row[5], :language => :ja)] if row[5]

    writer << graph
    id = id.succ
  end
  writer << [PARK["遊戯施設"], RDF::RDFS.subClassOf, IC["設備"]]
  ["金沢土木事務所", "南部公園緑地事務所"].each do |name|
    writer << [ORGANIZATION_RESOURCE[name], RDF.type, IC["組織"]]
    writer << [ORGANIZATION_RESOURCE[name], RDF::RDFS.label, RDF::Literal(name, :language => :ja)]
    writer << [ORGANIZATION_RESOURCE[name], IC["組織_名称"], RDF::Literal(name, :language => :ja)]
  end
end
