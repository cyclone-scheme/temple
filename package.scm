(package
 (name temple)
 (version 0.1)
 (license "MIT")
 (authors "Justin Ethier")
 (maintainers "Justin Ethier")
 (description "Web template engine")
 (tags "web" "")
 (docs "https://github.com/cyclone-scheme/cyclone-winds/wiki/temple")
 (test "test.scm")
 (test-dependencies ())
 (foreign-dependencies ())
 (library
  (name (cyclone web temple))
  (description "Temple main module"))
 (library
  (name (cyclone web temple parser))
  (description "Temple's parser"))
 (library
  (name (cyclone web trace))
  (description "Debug tracing"))
)
