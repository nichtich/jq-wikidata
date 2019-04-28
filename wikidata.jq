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

def remove_metadata:
  del(.modified,.lastrevid,.pageid,.ns,.title)
;

def simplify_claims(f):
  with_entries(.value |= map( del(.type,.id) | f ))
;

def simplify_claims:
  simplify_claims(.)
;

def simplify_snak:
  del(.hash,.property)
;

def simplify_snaks:
  with_entries(.value |= map(simplify_snak))
;

def simplify_references:
  del(.hash) | .snaks |= simplify_snaks
;

def remove_hashes:
  .mainsnak  |= simplify_snak
  |
  .references[]? |= simplify_references
  |
  if has("qualifiers") then
    .qualifiers |= simplify_snaks
  else
    .
  end
;
