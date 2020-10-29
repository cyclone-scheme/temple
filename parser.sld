(define-library (parser) ;; TODO: (cyclone web template parser)
  (export
    parse
  )
  (import
    (scheme base)
    (scheme read)
    (scheme cyclone util)
    (trace)
  )
  (begin

; Algorithm
;
; - read string from input
; - does string contain embedded expr?
;   - yes, split string at that point, put beginning into expr list, parse the rest (possibly more reads req'd)
;   - no, append to string list
;

(define *read-size* 1024)

(define-record-type <buf>
  (%make-buf fp buf exprs)
  buf?
  (fp buf:fp)
  (str buf:str buf:set-str!)
  (exprs buf:exprs buf:set-exprs!)
)

(define (make-buf fp)
  (%make-buf
   fp
   (read-string *read-size* fp)
   '()))

(define (buf:read-next-string! buf)
  (buf:set-str! buf (read-string *read-size* (buf:fp buf))))

(define (buf:append-next-string! buf)
  (let ((s (buf:str buf)))
    (buf:read-next-string! buf)
    (buf:set-str! buf (string-append s (buf:str buf)))))

;; Return next char from input, starting at position `pos`.
;; Will read more from input stream if necessary
(define (buf:next-char buf pos)
  (cond
    ((< (+ 1 pos) (string-length (buf:str buf)))
     (string-ref (buf:str buf) (+ pos 1)))
    (else
     (buf:append-next-string! buf)
     (buf:next-char buf 0)
     )))


;; Return position of char `chr` within string `str`, starting from index `start`
(define (string-pos str chr start)
  (let loop ((i start))
    (cond
     ((= i (string-length str))
      #f)
     ((equal? (string-ref str i) chr)
      i)
     (else
       (loop (+ i 1))))))

;;; Parse out data for a scheme template comment
;;; Basically reads and discards the whole comment.
(define (parse-string-comment! buf start)
  (let loop ((pos start))
    (trace `(loop ,start ,(buf:str buf)))
    (let ((i (string-pos (buf:str buf) #\# pos)))
    (trace `(loop ,i ,(buf:str buf)))
      (cond
        (i
         (let ((c (buf:next-char buf i)))
           (trace `(DEBUG c ,c ,(buf:str buf) ,pos)) 
           (cond
            ((eq? c #\})
             (trace `(DEBUG ,(buf:str buf) ,i)) 
             ;; Start buffer from end of comment
             (buf:set-str! 
               buf
               (substring (buf:str buf) (+ i 2) (string-length (buf:str buf)))))

            ((eof-object? c)
             (error "Unexpected end of file parsing Scheme comment" (buf:str buf)))
            (else
              (buf:read-next-string! buf)
              (loop 0)) )))
        (else
         (buf:read-next-string! buf)
         (loop 0))))))

(define (parse-expr! buf start ending-char stmt?)
  (define expr "")
  (define (add! str)
    (set! expr (string-append expr str)))

(trace `(parse-expr! ,(buf:str buf) ,start ,ending-char ,stmt?))
(trace '())

  (let loop ((pos start))
    (let ((i (string-pos (buf:str buf) ending-char pos)))
      (trace `(loop ,i ,(buf:str buf)))
      (cond
        (i
         (let ((c (buf:next-char buf i)))
           (trace `(DEBUG c ,c ,(buf:str buf) ,pos)) 
           (cond
            ((eq? c #\})
             (trace `(DEBUG ,(buf:str buf) ,i)) 
             ;; Add expression, return remaining buffer
             ;(if (> (- i 2) pos)
             (add! (substring (buf:str buf) pos i))

             ;; Append Scheme code to the buffer of expressions
             (buf:set-exprs! 
               buf 
               (cons 
                 (list
                   (if stmt?
                     expr
                     (string-append "(display " expr ")")))
                 (buf:exprs buf)))

             ;; Return extra buffer chars back to the top-level parser
             (buf:set-str! 
               buf
               (substring (buf:str buf) (+ i 2) (string-length (buf:str buf))))) ;; Remaining buffer

            ((eof-object? c)
             (error "Unexpected error parsing Scheme expression" (buf:str buf)))

            (else
              (add! (substring (buf:str buf) pos (string-length (buf:str buf))))
              (buf:read-next-string! buf)
              (loop 0)) )))
        (else
         (add! (substring (buf:str buf) pos (string-length (buf:str buf))))
         (buf:read-next-string! buf)
         (loop 0))))))

;; Top-level parser
(define (parse obj)
 (trace `(DEBUG called parse ,obj))  ;; DEBUG

 (let loop ((buf (make-buf 
                   (cond
                     ((string? obj)
                      (open-input-file obj)) ;; Open file
                     ((port? obj)
                      obj)
                     (else
                      (error "Cannot parse input from unexpected object" obj) )))))

  (cond
    ;; EOF?
    ((eof-object? (buf:str buf))
     (close-port (buf:fp buf))
     (let* ((exprs (map 
                     (lambda (expr)
                       (cond
                         ((string? expr)
                          (string-append 
                            "(display \"" 
                            (string-replace-all 
                              expr 
                              "\""
                              "\\\"")
                            "\")"))
                         ((pair? expr)
                          (car expr))
                         (else
                           expr)))
                     (reverse (buf:exprs buf))))
            (str
              (foldr 
                string-append 
                ""
                exprs))
            (fp (open-input-string str))
            (result (read-all fp)))
     ;(trace `(DEBUG parse exprs ,exprs))
     ;(trace `(DEBUG parse str ,str))
     ;(trace `(DEBUG parse result ,result))
     result)
    )
    (else
      ;; Does the string begin a scheme expression?
      ;; Will eventually need more sophisticated parsing but this works for now
      (let ((spos (string-pos (buf:str buf) #\{ 0)))
        (cond
          (spos
            ;; Include any chars already read, and clear from inp buffer
            (buf:set-exprs!
              buf
              (cons (substring (buf:str buf) 0 spos) (buf:exprs buf)))
            (buf:set-str! 
              buf 
              (substring (buf:str buf) spos (string-length (buf:str buf))))

            (let ((c (buf:next-char buf 0)))
              (cond
                ((eq? c #\#)
                 (parse-string-comment! buf 2)
                 (loop buf))
                ((eq? c #\{)
                 (parse-expr! buf 2 #\} #f)
                 (loop buf))
                ((eq? c #\%)
                 (parse-expr! buf 2 #\% #t)
                 (loop buf))
                (else
                  (error "TODO: parse scheme expression")
                  (exit 1)))))  ;; TODO: (loop buf)
          (else
            (buf:set-exprs! buf (cons (buf:str buf) (buf:exprs buf)))
            (buf:read-next-string! buf)
            (loop buf))))))))

  )
)
