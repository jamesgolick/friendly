Changelog
=========

### 0.4.0 (master)

  * (jamesgolick) Add has_many association.
  * (jamesgolick) Add ad-hoc scopes. See the docs for Document.scope.
  * (jamesgolick) Add named_scope functionality. See the docs for Document.named_scope.
  * (jeffrafter + jamesgolick) DDL generation now supports custom types. Previously, it would only work with types that Sequel already supported. Now, if you want to register a custom type, use Friendly::Attribute.register_type(klass, sql_type, &conversion_method).

