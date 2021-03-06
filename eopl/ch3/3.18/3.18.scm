#lang eopl
(require eopl/tests/private/utils)

(require "data-structures.rkt")  ; for expval constructors
(require "lang.rkt")             ; for scan&parse
(require "interp.rkt")           ; for value-of-program

;; run : String -> ExpVal
;; Page: 71
(define run
  (lambda (string)
    (value-of-program (scan&parse string))))

(define equal-answer?
  (lambda (ans correct-ans)
    (equal? ans (sloppy->expval correct-ans))))

(define sloppy->expval 
  (lambda (sloppy-val)
    (cond
      ((number? sloppy-val) (num-val sloppy-val))
      ((boolean? sloppy-val) (bool-val sloppy-val))
      (else
       (eopl:error 'sloppy->expval 
                   "Can't convert sloppy value to expval: ~s"
                   sloppy-val)))))

(define-syntax-rule (check-run (name str res) ...)
  (begin
    (cond [(eqv? 'res 'error)
           (check-exn always? (lambda () (run str)))]
          [else
           (check equal-answer? (run str) 'res (symbol->string 'name))])
    ...))

;;;;;;;;;;;;;;;; tests ;;;;;;;;;;;;;;;;

(check-run
 ;; simple arithmetic
 (positive-const "11" 11)
 (negative-const "-33" -33)
 (simple-arith-1 "-(44,33)" 11)

 (simple-arith-2 "minus(-1)" 1)
 (simple-arith-3 "minus(1)" -1)
 (simple-arith-4 "+(1,2)" 3)
 (simple-arith-5 "*(1,2)" 2)
 (simple-arith-6 "/(2, 2)" 1)

 (simple-arith-comp-1 "equal?(1, 1)" #t)
 (simple-arith-comp-2 "equal?(2, 1)" #f)
 (simple-arith-comp-3 "equal?(1, 2)" #f)
 (simple-arith-comp-1 "greater?(1, 1)" #f)
 (simple-arith-comp-2 "greater?(2, 1)" #t)
 (simple-arith-comp-3 "greater?(1, 2)" #f)
 (simple-arith-comp-1 "less?(1, 1)" #f)
 (simple-arith-comp-2 "less?(2, 1)" #f)
 (simple-arith-comp-3 "less?(1, 2)" #t)

 (308-in-if-1 "if less?(1, 2) then 2 else 1" 2)
 (308-in-if-2 "if equal?(1, 2) then 2 else 1" 1)
 (308-in-if-3 "if greater?(1, 2) then 2 else 1" 1)
 
 ;; nested arithmetic
 (nested-arith-left "-(-(44,33),22)" -11)
 (nested-arith-right "-(55, -(22,11))" 44)
 
 ;; simple variables
 (test-var-1 "x" 10)
 (test-var-2 "-(x,1)" 9)
 (test-var-3 "-(1,x)" -9)
 
 ;; simple unbound variables
 (test-unbound-var-1 "foo" error)
 (test-unbound-var-2 "-(x,foo)" error)
 
 ;; simple conditionals
 (if-true "if zero?(0) then 3 else 4" 3)
 (if-false "if zero?(1) then 3 else 4" 4)
 
 ;; test dynamic typechecking
 (no-bool-to-diff-1 "-(zero?(0),1)" error)
 (no-bool-to-diff-2 "-(1,zero?(0))" error)
 (no-int-to-if "if 1 then 2 else 3" error)
 
 ;; make sure that the test and both arms get evaluated
 ;; properly. 
 (if-eval-test-true "if zero?(-(11,11)) then 3 else 4" 3)
 (if-eval-test-false "if zero?(-(11, 12)) then 3 else 4" 4)
 
 ;; and make sure the other arm doesn't get evaluated.
 (if-eval-test-true-2 "if zero?(-(11, 11)) then 3 else foo" 3)
 (if-eval-test-false-2 "if zero?(-(11,12)) then foo else 4" 4)
 
 ;; simple let
 (simple-let-1 "let x = 3 in x" 3)
 
 ;; make sure the body and rhs get evaluated
 (eval-let-body "let x = 3 in -(x,1)" 2)
 (eval-let-rhs "let x = -(4,1) in -(x,1)" 2)
 
 ;; check nested let and shadowing
 (simple-nested-let "let x = 3 in let y = 4 in -(x,y)" -1)
 (check-shadowing-in-body "let x = 3 in let x = 4 in x" 4)
 (check-shadowing-in-rhs "let x = 3 in let x = -(x,1) in x" 2)

 ;; minus in simple let
 (minus-in-let "let x = 3 in minus(x)" -3)
 (minus-in-let-rhs "let x = minus(3) in -(x, -5)" 2)

 (list-check-1 "car(cons(3, emptylist))" 3)
 (list-check-2 "car(cons(5, cons(3, emptylist)))" 5)
 (list-check-3 "car(cdr(cons(5, cons(3, emptylist))))" 3)
 (list-check-4 "null?(emptylist)" #t)

 (list-in-let "let x = cons(3, emptylist) in car(x)" 3)
 (list-using-let "let x = 3 in car(cons(x, emptylist))" 3)

 (list-exp-check-1 "car(list(1, 2, 3))" 1)
 (list-exp-check-2 "let x = 4 in car(list(x, -(x, 1), -(x, 3)))" 4)
 (list-exp-check-3 "let x = 4 in car(cdr(list(x, -(x, 1), -(x, 3))))" 3)
 (cond-error-check "cond zero?(3) ==> 5 zero?(4) ==> 6 end" error)
 (cond-check-1 "let x =  3 in cond zero?(-(3, 3)) ==> 3 zero?(0) ==> 4 end" 3)

 (ext-let-check-1 "let x = 30 in let x = -(x, 1) y = -(x, 2) in -(x, y)" 1)
 (ext-let-star-check-1 "let x = 30 in let* x = -(x, 1) y = -(x, 2) in -(x, y)" 2)
 (unpack-test-1 "let u = 7 in unpack x y = cons(u,cons(3,emptylist)) in -(x,y)" 4)
 )

