; extends

((call_expression
  function: (identifier) @function.macro)
  (#match? @function.macro "^[A-Z][A-Z0-9_]*$")
  (#set! priority 110))
