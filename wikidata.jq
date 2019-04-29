module {
  "name": "wikidata",
  "description": "jq module to process Wikidata JSON format",
  "homepage": "https://github.com/nichtich/jq-wikidata#readme",
  "license": "MIT",
  "author": "Jakob Voß",
  "repository": {
    "type": "git",
    "url": "https://github.com/nichtich/jq-wikidata.git"
  }
};

def ndjson:
  fromstream(1|truncate_stream(inputs))
;

def entity_data_url:
  "https://www.wikidata.org/wiki/Special:EntityData/" + . + ".json"
;

def simplify_labels:
  with_entries(.value |= .value)
;

def simplify_descriptions:
  with_entries(.value |= .value)
;

def simplify_aliases:
  with_entries(.value |= map(.value))
;

def simplify_sitelinks:
  with_entries(.value |= .title)
;

def remove_info:
  del(.pageid,.ns,.title,.lastrevid,.modified)
;

def simplify_value:
  if .datavalue.type == "wikibase-entityid" then
    .datavalue.value.id
  else
    .datavalue.value
  end
;

def reduce_snak(base):
  base as $base |
  if $base.snaktype == "value" then
      .value = ( $base | simplify_value ) 
    | .type = $base.datavalue.type
  else
    .type = $base.snaktype  # somevalue or novalue
  end
;

def simplify_snak:
    del(.hash,.property)
  | reduce_snak(.) | del(.datavalue, .snaktype, .datatype)
;

def simplify_snaks:
  with_entries(.value |= map(simplify_snak))
;

def simplify_references:
  del(.hash) | .snaks |= simplify_snaks
;

def simplify_claim:
    del(.type)  # is always "statement"
  | del(.id)
  | reduce_snak(.mainsnak) | del(.mainsnak)
  | .references[]? |= simplify_references
  |
  if has("qualifiers") then
    .qualifiers |= simplify_snaks
  else
    .
  end
;

def simplify_claims(f):
  with_entries(.value |= map(simplify_claim | f ))
;

def simplify_claims:
  simplify_claims(.)
;

def simplify_entity_claims:
  if (.claims|length>0) then
    .claims |= simplify_claims
  else
    del(.claims)
  end 
;


# Lexemes

def simplify_forms:
  map(
    .representations |= with_entries(.value |= .value)
    | simplify_entity_claims
  )
;

def simplify_senses:
  map(
    .glosses |= with_entries(.value |= .value)
    | simplify_entity_claims
  )
;

def simplify_lexeme:
  simplify_entity_claims |
  .lemmas |= with_entries(.value |= .value) |
  .forms  |= simplify_forms |
  .senses |= simplify_senses
;
