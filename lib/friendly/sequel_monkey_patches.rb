require 'sequel'

# Out of the box, Sequel uses IS TRUE/FALSE for boolean parameters
# This prevents MySQL from using indexes.
#
# This setting fixes that.
DB.meta_def(:supports_is_true){false}

