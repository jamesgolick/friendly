Changelog
=========

### 0.3.6 (master)

  * (jamesgolick) Add named_scope functionality. See the docs for Document.named_scope.
  * (jeffrafter + jamesgolick) DDL generation now supports custom types. Previously, it would only work with types that Sequel already supported. Now, if you want to register a custom type, use Friendly::Attribute.register_type(klass, sql_type, &conversion_method).

