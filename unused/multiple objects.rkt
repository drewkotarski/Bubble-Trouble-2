#lang racket


(require 2htdp/image)
(require 2htdp/universe)

(define (ball-image t) ;<-- the t-parameter is our WorldState
  (and (place-image (circle 10 "solid" "red")
               (car t) ;<-- here now x variable coordinate
               (cdr t) ;<-- here now y variable, instead of 150
               (empty-scene 300 300))
  (overlay (text "jo" 40 "black")
           (square 40 "solid" "red"))))

(define (rectangle-image h)
  (place-image (rectangle 5 10 "solid" "blue")
               (car h)
               (cdr h)
               (empty-scene 300 300)))
             
(define (change w a-key)
  (cond ;w - is the previous worldState, V here we change it
    [(key=? a-key "left")  (cons (sub1 (car w)) (cdr w))];and 
    [(key=? a-key "right") (cons (add1 (car w)) (cdr w))];return 
    [(= (string-length a-key) 1) w] ;<-- this line is excess
    [(key=? a-key "up")    (cons (car w) (sub1 (cdr w)))]
    [(key=? a-key "down")  (cons (car w) (add1 (cdr w)))]
    [(key=? a-key "space") (cons (car w) (+ 3 (cdr w)))];; createa a new image that goes to the top of the screen, and then disappears
    [else w])) ;<-- If the key of no interest, just
                
(define (hook world)
  (if (= (cdr world) 300)
      world
      (hook (+ 2 (cdr world)))))

(big-bang '(150 . 150) ;<-- initial state
          (to-draw ball-image) ;<-- redraws the world
          (on-key change)) ;<-- process the event of key press
