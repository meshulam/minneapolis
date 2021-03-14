QUERIES = $(wildcard queries/*.sql)
OUTPUTS = $(QUERIES:queries/%.sql=output/%.csv)


all: $(OUTPUTS)

output/%.csv: queries/%.sql
	sqlite3 -csv -header data/minneapolis.db < $< > $@

# Regenerate database from source data
data/minneapolis.db:
	bin/database.py

.PHONY: package
package: all
	zip -r output.zip output
