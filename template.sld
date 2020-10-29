(define-library (template) ;; TODO: (cyclone web template)
  (export
    render
  )
  (import
    (scheme base)
    (scheme eval)
    (scheme read)
    (scheme repl)
    (srfi 69)
    (parser)
    (trace)
  )
  (begin

    (define *cache* (make-hash-table))
    
    (define (get-parse-tree view)
      (let ((tree (hash-table-ref/default *cache* view #f)))
       (cond
         (tree
          tree)
         (else
          (let ((t (parse view)))
            (hash-table-set! *cache* view t)
            t)))))
    
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
