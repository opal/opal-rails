require 'json'
return {
  number_var: @number_var,
  string_var: @string_var,
  array_var:  @array_var,
  hash_var:   @hash_var,
  object_var: @object_var,
  local_var:  defined?(local_var) ? local_var : nil
}.to_json
