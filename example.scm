(import (scheme base)
        (cyclone web temple))

;; TODO: 
;; - enhanced cache to take file timestamp into account? see below
;; - scheme expression and statement syntax
;; - unit tests via test.scm, need to handle many edge cases
;; - cyclone winds package
;; - real example using lighthttpd and fastcgi
;;   EG: https://github.com/jerryvig/lighttpd-fastcgi-c


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Older Notes:

;; Page record type:
;;  filename
;;  last loaded time (?)
;;  cached expressions

;; Render (filename, args)
;;  load args into new env
;;  find page
;;   not found, load from disk and cache
;;   found, eval cached expressions

;; Use cond-expand to try to keep code standard
;;    track file timestamp and reload if necessary,
;;    but this will be cyclone-only.
;;   Otherwise cache forever, I guess. Or time out if no access in X seconds
;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Basic example:
(define args '((row . (cons "view-1.html" "View 1"))
               (link . car)
               (desc . cdr)))

(render "examples/view-4.html" args)
(render "examples/view-4.html" '((row . '("view-2.html" . "View 2"))
                        (link . car)
                        (desc . cdr)))
