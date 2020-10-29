(import (scheme base) 
        (parser)
        (template)
        (cyclone test))

(define view-1
"<html>
<head><title>Test View></title></head>
<body>


  <p>
    <a href=\"view-1.html\">
      View 1
    </a>
  </p>

  <p>
    <a href=\"view-2.html\">
      View 2
    </a>
  </p>

  <p>
    <a href=\"view-3.html\">
      View 3
    </a>
  </p>


</body>
</html>
")

(define view-2
"<html>
<head><title>Test View></title></head>
<body>

some body text here...

</body>
</html>

")

(define view-3
"
<html>
<head><title>Test of a template comment></title></head>
<body>

01234


more text



</body>
</html>
")

(define view-4
"
<html>
<head><title>Test View></title></head>
<body>

  <p>
    <a href=\"view-2.html\">
      View 2
    </a>
  </p>

</body>
</html>
")

(define-syntax test/output
  (syntax-rules ()
      ((_ desc expected body ...)
       (_test/output
         desc
         expected
         (lambda ()
           body ...)))))

(define (_test/output desc expected thunk)
  (call-with-port 
    (open-output-string) 
    (lambda (p)
      (parameterize ((current-output-port p))
        (thunk)
        (test 
          desc
          expected
          (get-output-string p))))))

(test-group "View snippets"
  (test/output "Basic inline comment"
    " test "
    (render (open-input-string " test ") '()))
)

(test-group "Views from file"

  (test/output
    "Basic views with no embedded Scheme"
    view-2
    (render "view-2.html" '()))

  (test/output "Basic view with comments"
    view-3
    (render "view-3.html" '()))

  (test/output
    "Basic view with expressions"
    view-4
    (render
      "view-4.html" 
      '((row . '("view-2.html" . "View 2"))
        (link . car)
        (desc . cdr))))

  (test/output
    "Basic view with statements and expressions"
    view-1
    (render
      "view-1.html" 
      '((rows . '(
                  ("view-1.html" . "View 1")
                  ("view-2.html" . "View 2")
                  ("view-3.html" . "View 3")
                 ))
        (link . car)
        (desc . cdr)))
    )
)

(test-exit)

