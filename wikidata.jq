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


# labels, descriptions, aliases, sitelinks

def reduceLabels:
  with_entries(.value |= .value)
;

def reduceDescriptions:
  with_entries(.value |= .value)
;

def reduceAliases:
  with_entries(.value |= map(.value))
;

def reduceSitelinks:
  with_entries(.value |= .title)
;


# ...

def reduceValue:
  if .datavalue.type == "wikibase-entityid" then
    .datavalue.value.id
  else
    .datavalue.value
  end
;

def reduce_snak(base):
  base as $base |
  if $base.snaktype == "value" then
      .value = ( $base | reduceValue ) 
    | .type = $base.datavalue.type
  else
    .type = $base.snaktype  # somevalue or novalue
  end
;

def reduceSnak:
    del(.hash,.property)
  | reduce_snak(.) | del(.datavalue, .snaktype, .datatype)
;

def reduceSnaks:
  with_entries(.value |= map(reduceSnak))
;

def reduceReferences:
  del(.hash) | .snaks |= reduceSnaks
;

def reduceClaim:
    del(.type)  # is always "statement"
  | del(.id)
  | reduce_snak(.mainsnak) | del(.mainsnak)
  | .references[]? |= reduceReferences
  |
  if has("qualifiers") then
    .qualifiers |= reduceSnaks
  else
    .
  end
;

def reduceClaims(f):
  with_entries(.value |= map(reduceClaim | f ))
;

def reduceClaims:
  reduceClaims(.)
;

def reduceEntity_claims:
  if (.claims|length>0) then
    .claims |= reduceClaims
  else
    del(.claims)
  end 
;

# Items and properties

def reduceProperty:
  .labels |= reduceLabels |
  .descriptions |= reduceDescriptions |
  .aliases |= reduceAliases |
  reduceEntity_claims
;

def reduceItem:
  reduceProperty |
  .sitelinks |= reduceSitelinks 
;

# Lexemes

def reduceForms:
  map(
    .representations |= with_entries(.value |= .value)
    | reduceEntity_claims
  )
;

def reduceSenses:
  map(
    .glosses |= with_entries(.value |= .value)
    | reduceEntity_claims
  )
;

def reduceLexeme:
  reduceEntity_claims |
  .lemmas |= with_entries(.value |= .value) |
  .forms  |= reduceForms |
  .senses |= reduceSenses
;


#  Additional information fields

def reduceInfo:
  del(.pageid,.ns,.title,.lastrevid,.modified)
;

