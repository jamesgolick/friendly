Changelog
=========

### 0.3.6 (master)

  * (jeffrafter + jamesgolick) DDL generation now supports custom types. Previously, it would only work with types that Sequel already supported. Now, if you want to register a custom type, use Friendly::Attribute.register_type(klass, sql_type, &conversion_method).

