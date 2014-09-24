(in-package :mgl-test)

(defun test-fracture ()
  (assert (equal (fracture 5 '(0 1 2 3 4 5 6 7 8 9))
                 '((0 1) (2 3) (4 5) (6 7) (8 9))))
  (assert (equal (fracture '(2 3) '(0 1 2 3 4 5 6 7 8 9))
                 '((0 1 2 3) (4 5 6 7 8 9))))
  (assert (equal (fracture '(2 3) '(0))
                 '(() (0))))
  (assert (equal (fracture '(1 2) '(0 1 2 3 4 5 6 7 8 9
                                    0 2 4 6 8 10 12 14 16 18)
                           :weight #'identity)
                 '((0 1 2 3 4 5 6 7 8 9)
                   (0 2 4 6 8 10 12 14 16 18))))
  (assert (equal (fracture 2 '(0 1 2 3 4 5 6 7 8 9
                               0 2 4 6 8 10 12 14 16 18)
                           :weight #'identity)
                 '((0 1 2 3 4 5 6 7 8 9 0 2 4 6 8)
                   (10 12 14 16 18)))))

(defun test-stratify ()
  (assert (equal (stratify '(0 1 2 3 4 5 6 7 8 9) :key #'evenp)
                 '((0 2 4 6 8) (1 3 5 7 9)))))

(defun test-fracture-stratified ()
  (assert (equal (fracture-stratified 2 '(0 1 2 3 4 5 6 7 8 9)
                                      :key #'evenp)
                 '((0 2 1 3) (4 6 8 5 7 9))))
  (assert (equal (fracture-stratified '(2 3) '(0 1 2 3 4 5 6 7 8 9)
                                      :key #'evenp)
                 '((0 2 1 3) (4 6 8 5 7 9))))
  (assert (equal (fracture-stratified '(2 3) '(0 1 2 3 4) :key #'evenp)
                 '((0 1) (2 4 3))))
  (assert (equal (fracture-stratified '(2 3) '(0 1 2 3 4 5 6 7 8 9)
                                      :key #'evenp :weight #'identity)
                 '((0 2 4 1 3 5) (6 8 7 9))))
  (assert (equal (fracture-stratified '(2 3) '(0 1 2 3 4 5 6 7 8 9)
                                      :key #'evenp
                                      :weight (lambda (x) (* 0.01 x)))
                 '((0 2 4 1 3 5) (6 8 7 9)))))

(defun test-cross-validate ()
  (assert (equal
           (cross-validate '(0 1 2 3 4)
                           (lambda (test training)
                             (list test training))
                           :n-folds 5)
           '(((0) (1 2 3 4))
             ((1) (0 2 3 4))
             ((2) (0 1 3 4))
             ((3) (0 1 2 4))
             ((4) (0 1 2 3)))))
  (assert (equal (cross-validate '(0 1 2 3 4)
                                 (lambda (fold test training)
                                   (list :fold fold test training))
                                 :folds '(2 3)
                                 :pass-fold t)
                 '((:fold 2 (2) (0 1 3 4))
                   (:fold 3 (3) (0 1 2 4))))))

(defun test-sample-from ()
  (let ((seq '(0 1 2 3 4 5)))
    (loop repeat 100 do
      (let ((samples (sample-from 1/2 seq)))
        (assert (= (length samples) 3))
        (assert (every (lambda (sample)
                         (member sample seq))
                       samples))))))

(defun test-bag-cv ()
  (let ((bag-of-cvs (bag-cv '(0 1 2 3 4) #'list :n 3 :n-folds 2)))
    (assert (= (length bag-of-cvs) 3))
    (assert (every (lambda (cv)
                     (and (= (length cv) 2)
                          (every (lambda (cv-splits)
                                   (= (length (apply #'append cv-splits)) 5))
                                 cv)))
                   bag-of-cvs))))

(defun test-spread-strata ()
  (assert (equal (spread-strata '(0 2 4 6 8 1 3 5 7 9) :key #'evenp)
                 '(0 1 2 3 4 5 6 7 8 9)))
  (assert (vector= (spread-strata (vector 0 2 3 5 6 1 4)
                                  :key (lambda (x)
                                         (if (member x '(1 4))
                                             t
                                             nil)))
                   #(0 1 2 3 4 5 6))))

(defun test-zip-evenly ()
  (assert (equal (zip-evenly '((0 2 4) (1 3)))
                 '(0 1 2 3 4))))

(defun test-resample ()
  (test-fracture)
  (test-stratify)
  (test-fracture-stratified)
  (test-cross-validate)
  (test-sample-from)
  (test-bag-cv)
  (test-spread-strata)
  (test-zip-evenly))

#|

(test-resample)

|#
