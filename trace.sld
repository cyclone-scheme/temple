(define-library (trace)
  (export
    trace
    set-trace-level!
  )
  (import
    (scheme base)
    (scheme write)
  )
  (begin
   (define *trace-level* 0)
   (define (set-trace-level! l)
     (set! *trace-level* l))
   (define (trace expr)
     (when (> *trace-level* 0)
       (write expr)
       (newline)))
  )
)
