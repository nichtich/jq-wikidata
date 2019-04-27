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

def simplify_labels:
  with_entries(.value |= .value)
;

def simplify_descriptions:
  with_entries(.value |= .value)
;

def simplify_aliases:
  with_entries(.value |= map(.value))
;

def simplify_claims:
  . # TODO
;

def simplify_sitelinks:
  with_entries(.value |= .title)
;

def remove_metadata:
  del(.modified,.lastrevid,.pageid,.ns,.title)
;
