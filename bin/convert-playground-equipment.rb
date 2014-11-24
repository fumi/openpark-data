#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rdf'
require 'rdf/turtle'
require 'csv'
require 'securerandom'


INPUT_FILE="../original/playground-equipment_utf8.csv"
OUTPUT_FILE="../ttl/playground-equipment.ttl"

PARK = RDF::Vocabulary.new("http://yokohama.openpark.jp/parks/")
EQUIPMENT = RDF::Vocabulary.new("http://yokohama.openpark.jp/equipment/")
IC = RDF::Vocabulary.new("http://imi.ipa.go.jp/ns/core/210#")

PREFIXES = {
  :rdf => RDF.to_s,
  :rdfs => RDF::RDFS.to_s,
  :schema => RDF::SCHEMA.to_s,
  :geo => RDF::GEO.to_s,
  :dcterms => RDF::DC.to_s,
  :xsd => RDF::XSD.to_s,
  :park => PARK.to_s,
  :equipment => EQUIPMENT.to_s,
  :ic => IC.to_s
}

def to_western_year(year)
  if /H(\d+)/.match(year)
    1989 + $1.to_i
  else
    1926 + $1.to_i
  end
end

firstline = true

RDF::Writer.open(OUTPUT_FILE, :prefixes => PREFIXES) do |writer|
  CSV.foreach(INPUT_FILE) do |row|
    if firstline
      firstline = false
      next
    end
    year = to_western_year(row[11])
    graph = RDF::Graph.new
    graph.from_ttl("park:#{row[3]} ic:地点_設備 equipment:#{row[4]} .
                    equipment:#{row[4]} a ic:設備 ;
                      rdfs:label \"#{row[6]}\"@ja  ;
                      ic:設備_名称 \"#{row[6]}\"@ja ;
                      dcterms:identifier \"#{row[4]}\" ;
                      ic:設備_ID [ a ic:ID ;
                        ic:値 \"#{row[4]}\" ;
                      ] ;
                      ic:設備_設置地点 park:#{row[3]} ;
                      ic:設備_管理者 [ a ic:組織;
                        ic:組織_名称 \"#{row[0]}\"@ja ; 
                        rdfs:label \"#{row[0]}\"@ja ;
                      ];
                      dcterms:created \"#{year}\"^^xsd:year ;
                      ic:設備_設置日 [ a ic:日時 ;
                        ic:日時_表記-定型 [ a ic:定型日時 ;
                          ic:定型日時_年 #{year} ;
                        ];
                      ] ;
                      ic:利用者 \"対象年齢: #{row[12]}\" ;
                      ic:備考 \"#{row[7]}\"@ja ;
                      .
                   ", :prefixes => PREFIXES)

    writer << graph
  end
end
