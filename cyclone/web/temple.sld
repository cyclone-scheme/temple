(define-library (cyclone web temple)
  (import
    (scheme base)
    (scheme eval)
    (scheme read)
    (scheme repl)
    (srfi 69)
    (cyclone web temple parser)
    (cyclone web temple trace)
  )
  (export
    render
    get-parse-tree
    build-parse-tree
  )
  (begin
    ;; Setup a cache for view parse trees, so we don't have to 
    ;; read them each time
    (define *cache* (make-hash-table))
    
    ;; Get view, either directly from cache or parsed from given obj
    ;;
    ;; Parameters:
    ;;  view - Filename or port containing contents of the view
    ;;
    ;; Returns the parse tree
    (define (get-parse-tree view)
      (let ((tree (hash-table-ref/default *cache* view #f)))
       (cond
         (tree
          tree)
         (else
          (let ((t (parse view)))
            (hash-table-set! *cache* view t)
            t)))))

    ;; Build parse tree from input object, nothing is read from cache
    ;;
    ;; Parameters:
    ;;  view - Filename or port containing contents of the view
    ;;
    ;; Returns the parse tree
    (define (build-parse-tree obj)
      (parse obj))
    
    ;; Render a view from given object using input data.
    ;;
    ;; Parameters:
    ;;  view - Filename or port containing contents of the view
    ;;  args - A list of data arguments to use when rendering output
    ;;
    ;; No direct return, data is written to the current output port.
    (define (render view args)
      (let ((env (cond-expand
                   (cyclone (create-environment '() '()))
                   (else (interaction-environment))))
            (view-sexpr (get-parse-tree view))
           )
        (for-each
          (lambda (arg)
            (trace `(define ,(car arg) ,(cdr arg)))
            (eval `(define ,(car arg) ,(cdr arg)) env)
          )
          args)
        (trace `(DEBUG render ,view-sexpr))
        (eval (cons 'begin view-sexpr) env)))
  )
)
