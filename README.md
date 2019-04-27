# jq-wikidata

> jq module to process Wikidata JSON format

## Requirements

Requires jq version 1.5 or newer.

## Installation

Put `wikidata.jq` to a place where jq can [find it as module](https://stedolan.github.io/jq/manual/#Modules).

One way to do so is to check out this repository to directory `~/.jq/wikidata/`:

~~~sh
mkdir -p ~/.jq && git clone https://github.com/nichtich/jq-wikidata.git ~/.jq/wikidata
~~~

## Usage

Several methods exist [to get entity data from Wikidata](https://www.wikidata.org/wiki/Wikidata:Data_access).
This jq module is designed to process entities [in their JSON serialization](https://www.mediawiki.org/wiki/Wikibase/DataModel/JSON)
especially for large numbers of items.  Please also consider using a dedicated client such as
[wikidata-cli](https://www.npmjs.com/package/wikidata-cli) instead.

The shortest method to use functions of this jq module is to directly `include` the module.

~~~sh
jq -c 'include "wikidata"; .labels|simplify_labels' entities.ndjson
~~~

More complex scripts should better be put into a `.jq` file:

~~~jq
include "wikidata";

.labels|simplify_labels;
~~~

### Process JSON dumps

Wikidata JSON dumps are made available at <https://dumps.wikimedia.org/wikidatawiki/entities/>.
The current dumps exceed 35GB even in its most compressed form. File contains one large JSON
array that should better be converted into a stream of JSON objects for further processing.

With a fast and stable internet connection it's possible to process the dump
on-the fly like this:

~~~sh
curl -s https://dumps.wikimedia.org/wikidatawiki/entities/latest-all.json.bz2 \
  | bzcat | jq -nc --stream 'import "wikidata"; ndjson' | jq .id
~~~

## API

### Stream an array of entities

Module function `ndjson` can be used to process a stream with an array of
entities into a list of entities:

~~~sh
bzcat latest-all.json.bz2 | jq -n --stream 'import "wikidata"; ndjson'
~~~

### Simplify labels

~~~jq
.labels|simplify_labels
~~~

### Simplify descriptions

~~~jq
.descriptions|simplify_descriptions
~~~

### Simplify aliases

~~~jq
.aliases|simplify_aliases
~~~

### Simmplify sitelinks 

~~~jq
.sitelinks|simplify_sitelinks
~~~

### Remove metadata

~~~jq
.|remove_metadata
~~~

Removes entity fields `modified`, `lastrevid`, `pageid`, `ns`, and `title`. See
[`del`](https://stedolan.github.io/jq/manual/#del(path_expression)) to remove
selected fields.

