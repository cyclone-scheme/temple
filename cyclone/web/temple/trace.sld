(define-library (cyclone web temple trace)
  (import
    (scheme base)
    (scheme write)
  )
  (export
    trace
    set-trace-level!
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
