# jq-wikidata

[![Build Status](https://travis-ci.org/nichtich/jq-wikidata.svg?branch=master)](https://travis-ci.org/nichtich/jq-wikidata)

> jq module to process Wikidata JSON format

This git repository contains a module for the [jq data transformation language](https://stedolan.github.io/jq/) to process entity data from [Wikidata](https://www.wikidata.org) or other [Wikibase](http://wikiba.se/) instances serialized in its JSON format.

Several methods exist [to get entity data from Wikidata](https://www.wikidata.org/wiki/Wikidata:Data_access).
This module is designed to process entities [in their JSON serialization](https://www.mediawiki.org/wiki/Wikibase/DataModel/JSON)
especially for large numbers of entities.  Please also consider using a dedicated client such as
[wikidata-cli] instead.

[wikidata-cli]: https://www.npmjs.com/package/wikidata-cli

## Table of Contents

* [Install](#install)
* [Usage](#usage)
  * [Process JSON dumps](#process-json-dumps)
  * [Per-item access](#per-item-access)
  * [Reduce entity data](#reduce-entity-data)
* [API](#api)
  * [Simplify labels](#simplify-labels)
  * [Simplify descriptions](#simplify-descriptions)
  * [Simplify aliases](#simplify-aliases)
  * [Simplify sitelinks ](#simplify-sitelinks)
  * [Simplify claims](#simplify-claims)
  * [Simplify lexeme](#simplify-lexeme)
  * [Simplify forms](#simplify-forms)
  * [Remove additional info](#remove-info)
  * [Stream an array of entities](#stream-an-array-of-entities)
* [Contributing](#contributing)
* [License](#license)

## Install

Installation requires [jq](https://stedolan.github.io/jq/) version 1.5 or newer.

Put `wikidata.jq` to a place where jq can [find it as module](https://stedolan.github.io/jq/manual/#Modules).
One way to do so is to check out this repository to directory `~/.jq/wikidata/`:

~~~sh
mkdir -p ~/.jq && git clone https://github.com/nichtich/jq-wikidata.git ~/.jq/wikidata
~~~

## Usage

The shortest method to use functions of this jq module is to directly `include` the module.

~~~sh
jq -c 'include "wikidata"; .labels|simplify_labels' entities.ndjson
~~~

More complex scripts should better be put into a `.jq` file:

~~~jq
include "wikidata";

.labels|simplify_labels
~~~

### Process JSON dumps

Wikidata JSON dumps are made available at <https://dumps.wikimedia.org/wikidatawiki/entities/>.
The current dumps exceed 35GB even in its most compressed form. The file contains one large JSON
array so it should better be converted into a stream of JSON objects for further processing.

With a fast and stable internet connection it's possible to process the dump on-the fly like this:

~~~sh
curl -s https://dumps.wikimedia.org/wikidatawiki/entities/latest-all.json.bz2 \
  | bzcat | jq -nc --stream 'import "wikidata"; ndjson' | jq .id
~~~

### Per-item access

JSON data for single entities can be ontained via the
[Entity Data URL](https://www.wikidata.org/wiki/Special:EntityData). Examples:

* <https://www.wikidata.org/wiki/Special:EntityData/Q42.json>
* <https://www.wikidata.org/wiki/Special:EntityData/L3006.json>
* <https://www.wikidata.org/wiki/Special:EntityData/L3006-F1.json>

The module function `entity_data_url` creates these URLs from Wikidata
itentifier strings. The resulting data is wrapped in JSON object; unwrap with
`.entities|.[]`:

~~~bash
curl $(echo Q42 | jq -rR 'include "wikidata"; entity_data_url') | jq '.entities|.[]'
~~~

As mentioned above you better use [wikidata-cli] for accessing small sets of items:

~~~bash
wd d Q42
~~~

To get sets of items that match a given criteria either use SPARL or MediaWiki API module
[wbsearchentities] and/or MediaWiki API module [wbgetentities].

[wbsearchentities]: https://www.wikidata.org/w/api.php?action=help&modules=wbsearchentities
[wbgetentities]: https://www.wikidata.org/w/api.php?action=help&modules=wbgetentities

### Reduce entity data

Many use cases only require a limite subset of entity data.

Select some fields:

~~~jq
jq '{id,labels}' entities.ndjson
~~~

Remove [additional fields](#remove-info):

~~~jq
jq 'include "wikidata"; remove_info' entities.ndjson
~~~

## API

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

### Simplify sitelinks

~~~jq
.sitelinks|simplify_sitelinks
~~~

### Simplify lexeme

Simplifies lemmas, forms, and senses of a lexeme entity.

~~~.jq
simplify_lexeme
~~~

### Simplify forms

~~~.jq
.forms|simplify_forms
~~~

### Simplify senses

~~~.jq
.senses|simplify_senses
~~~

## Simplify claims

Removes unnecessary fields `.id`, `.hash`, `.type`, `.property` and simplifies
values.

~~~jq
.claims|simplify_claims
~~~

### Simplify forms

Only lexemes have forms.

~~~
.forms|simplify_forms
~~~

### Remove additional info

~~~jq
remove_info
~~~

Removes additional information fields `pageid`, `ns`, `title`, `lastrevid`, and `modified`.

To remove selected field see jq function [`del`](https://stedolan.github.io/jq/manual/#del(path_expression)).


### Stream an array of entities

Module function `ndjson` can be used to process a stream with an array of
entities into a list of entities:

~~~sh
bzcat latest-all.json.bz2 | jq -n --stream 'import "wikidata"; ndjson'
~~~

## Contributing

The source code is hosted at <https://github.com/nichtich/jq-wikidata>.

Bug reports and feature requests [are welcome](https://github.com/nichtich/jq-wikidata/issues/new)!

## License

Made available under the MIT License by Jakob Voß.

