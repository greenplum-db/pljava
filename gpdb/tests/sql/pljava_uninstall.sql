\! gppkg -q --all | sed -n '/^pljava-/s|.*|pljava|p'
-- start_ignore
\! gppkg -r pljava
-- end_ignore
\! gppkg -q --all | sed -n '/^pljava-/s|.*|pljava|p'
