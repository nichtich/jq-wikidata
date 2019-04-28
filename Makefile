meta:
	@jq -L. -n '"wikidata"|modulemeta'

test:
	@./tests/run.sh || true
