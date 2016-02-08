LAYOUT = <<-HTML
<!DOCTYPE html>
<html>
<head><%= javascript_include_tag "application" %></head>
<body><%= yield %></body>
</html>
HTML

INDEX = <<-HTML
<script type="text/ruby">
raise 'pippo'
</script>
HTML

WITH_ASSIGNMENTS = <<-RUBY
return {
  number_var: @number_var,
  string_var: @string_var,
  array_var:  @array_var,
  hash_var:   @hash_var,
  object_var: @object_var,
  local_var:  local_var
}.to_n
RUBY
