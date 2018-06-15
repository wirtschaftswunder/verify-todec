(in-package "RTL")
(include-book "ihs/basic-definitions" :dir :system)
(include-book "kestrel/utilities/fixbytes/instances" :dir :system)
(include-book "rtl/rel11/support/definitions" :dir :system)

(include-book "tools/with-arith5-help" :dir :system)
(local (acl2::allow-arith5-help))

(local (include-book "rtl/rel11/support/basic" :dir :system))

; Coerce x to a signed integer which will fit in n bits.
(acl2::with-arith5-help
 (define int-fix
   ((x integerp))
   :returns (result acl2::sbyte32p
                    :hints (("goal" :in-theory (enable acl2::sbyte32p))))
   (acl2::logext 32 (ifix x))
   ///
   (fty::deffixequiv int-fix)
   (defrule int-fix-type
     (integerp (int-fix x))
     :rule-classes :type-prescription)
   (defrule int-fix-when-sbyte32
     (implies (acl2::sbyte32p x)
              (equal (int-fix x) x))
     :enable acl2::sbyte32p)))

(acl2::with-arith5-help
 (define long-fix
   ((x integerp))
   :returns (result acl2::sbyte64p
                    :hints (("goal" :in-theory (enable acl2::sbyte64p))))
   (acl2::logext 64 (ifix x))
   ///
   (fty::deffixequiv long-fix)
   (defrule long-fix-type
     (integerp (long-fix x))
     :rule-classes :type-prescription)
   (defrule long-fix-when-sbyte64
     (implies (acl2::sbyte64p x)
              (equal (long-fix x) x))
     :enable acl2::sbyte64p)))

(defruled sbyte32-suff
  (implies (and (integerp x)
                (<= #fx-1p31 x)
                (< x #fx1p31))
           (acl2::sbyte32p x))
  :enable acl2::sbyte32p)

(defruled sbyte64-suff
  (implies (and (integerp x)
                (<= #fx-1p63 x)
                (< x #fx1p63))
           (acl2::sbyte64p x))
  :enable acl2::sbyte64p)

(defrule sbyte32-fix-type
  (integerp (acl2::sbyte32-fix x))
  :rule-classes :type-prescription
  :enable acl2::sbyte32-fix)

(defrule sbyte64-fix-type
  (integerp (acl2::sbyte64-fix x))
  :rule-classes :type-prescription
  :enable acl2::sbyte64-fix)

(defrule sbyte32-is-integer
  (implies (acl2::sbyte32p x)
           (integerp x)))

(defrule sbyte64-is-integer
  (implies (acl2::sbyte64p x)
           (integerp x)))

(defrule sbyte32-is-acl2-numberp
  (implies (acl2::sbyte32p x)
           (acl2-numberp x)))

(defrule sbyte64-is-acl2-numberp
  (implies (acl2::sbyte64p x)
           (acl2-numberp x)))

(define ldiv
  ((x acl2::sbyte64p)
   (y acl2::sbyte64p))
  :returns (result-or-exception (implies result-or-exception ; DivideByZeroError
                                         (acl2::sbyte64p result-or-exception)))
  (acl2::b*
   ((x (acl2::sbyte64-fix x))
    (y (acl2::sbyte64-fix y)))
   (and (not (= y 0)) (long-fix (truncate x y))))
  ///
  (fty::deffixequiv ldiv)
  (defrule sbyte64p-ldiv-noexcept
    (implies (not (= (acl2::sbyte64-fix y) 0))
             (acl2::sbyte64p (ldiv x y))))
  (defrule ldiv-type-noexcept
    (implies (not (= (acl2::sbyte64-fix y) 0))
             (integerp (ldiv x y)))
    :rule-classes :type-prescription)
  (defruled ldiv-when-nonnegative-args
    (implies (and (<= 0 (acl2::sbyte64-fix x))
                  (< 0 (acl2::sbyte64-fix y)))
             (equal (ldiv x y)
                    (fl (/ (acl2::sbyte64-fix x) (acl2::sbyte64-fix y)))))
    :use (:instance lemma
                    (x (acl2::sbyte64-fix x))
                    (y (acl2::sbyte64-fix y)))
    :prep-lemmas
    ((acl2::with-arith5-nonlinear-help
      (defrule lemma
        (implies (and (acl2::sbyte64p x)
                      (acl2::sbyte64p y)
                      (<= 0 x)
                      (< 0 y))
                 (equal (ldiv x y) (fl (/ x y))))
        :enable (acl2::sbyte64p fl)))))
  (acl2::with-arith5-help
   (defrule ldiv-type-when-nonnegative-args
     (implies (and (<= 0 (acl2::sbyte64-fix x))
                   (< 0 (acl2::sbyte64-fix y)))
              (natp (ldiv x y)))
     :rule-classes :type-prescription
     :disable ldiv
     :use ldiv-when-nonnegative-args)))

(define lrem
  ((x acl2::sbyte64p)
   (y acl2::sbyte64p))
  :returns (result-or-exception (implies result-or-exception ; DivideByZeroError
                                         (acl2::sbyte64p result-or-exception)))
  (acl2::b*
   ((x (acl2::sbyte64-fix x))
    (y (acl2::sbyte64-fix y)))
   (and (not (= y 0)) (long-fix (rem x y))))
  ///
  (fty::deffixequiv lrem)
  (defrule sbyte64p-lrem-noexcept
    (implies (not (= (acl2::sbyte64-fix y) 0))
             (acl2::sbyte64p (lrem x y))))
  (defrule lrem-type-noexcept
    (implies (not (= (acl2::sbyte64-fix y) 0))
             (integerp (lrem x y)))
    :rule-classes :type-prescription)
  (defruled lrem-when-nonnegative-args
    (implies (and (<= 0 (acl2::sbyte64-fix x))
                  (< 0 (acl2::sbyte64-fix y)))
             (equal (lrem x y)
                    (mod (acl2::sbyte64-fix x) (acl2::sbyte64-fix y))))
    :use (:instance lemma
                    (x (acl2::sbyte64-fix x))
                    (y (acl2::sbyte64-fix y)))
    :prep-lemmas
    ((acl2::with-arith5-nonlinear-help
      (defrule lemma
        (implies (and (acl2::sbyte64p x)
                      (acl2::sbyte64p y)
                      (<= 0 x)
                      (< 0 y))
                 (equal (lrem x y) (mod x y)))
        :enable acl2::sbyte64p))))
  (acl2::with-arith5-help
   (defrule lrem-type-when-nonnegative-args
     (implies (and (<= 0 (acl2::sbyte64-fix x))
                   (< 0 (acl2::sbyte64-fix y)))
              (natp (lrem x y)))
     :rule-classes :type-prescription
     :use lrem-when-nonnegative-args)))

(define Natural.compareTo
  ((this natp)
   (y natp))
  :returns (result acl2::sbyte32p)
  (acl2::b*
   ((this (nfix this))
    (y (nfix y)))
   (signum (- this y)))
  ///
  (fty::deffixequiv Natural.compareTo)
  (defrule Natural.compareTo-linear
    (and (<= -1 (Natural.compareTo this x))
         (<= (Natural.compareTo this x) 1))
    :rule-classes :linear))

(define Natural.closerTo
  ((this natp)
   (x natp)
   (y natp))
  :returns (result acl2::sbyte32p)
  (acl2::b*
   ((this (nfix this))
    (x (nfix x))
    (y (nfix y)))
   (signum (- (* 2 this) (+ x y))))
  ///
  (fty::deffixequiv Natural.closerTo)
  (defrule Natural.closerTo-linear
    (and (<= -1 (Natural.closerTo this x y))
         (<= (Natural.closerTo this x y) 1))
    :rule-classes :linear))

(acl2::with-arith5-help
 (define Natural.valueOfShiftLeft
   ((v acl2::sbyte64p)
    (n acl2::sbyte32p))
   :returns (result-or-exception (or (null result-or-exception)
                                     (natp result-or-exception))
                                 :rule-classes :type-prescription)
   (acl2::b*
    ((v (acl2::sbyte64-fix v))
     (n (acl2::sbyte32-fix n))
     ((unless (<= 0 n)) nil)
     (unsigned-v (acl2::loghead 64 v)))
    (ash unsigned-v n))
   ///
   (fty::deffixequiv Natural.valueOfShiftLeft)
   (defrule Natural.valueOfShiftLeft-type-noexception
     (implies (<= 0 (acl2::sbyte32-fix n))
              (natp (Natural.valueOfShiftLeft v n)))
     :rule-classes :type-prescription)
   (acl2::with-arith5-nonlinear-help
    (defrule Natural.valueOfShiftLeft-when-nonnegative
      (implies (and (<= 0 (acl2::sbyte64-fix v))
                    (<= 0 (acl2::sbyte32-fix n)))
               (equal (Natural.valueOfShiftLeft v n)
                      (* (acl2::sbyte64-fix v)
                         (expt 2 (acl2::sbyte32-fix n)))))
     :enable (acl2::sbyte64-fix acl2::sbyte64p)))))

(acl2::with-arith5-help
 (define gen-powers
   ((b integerp)
    (n natp))
   :returns (powers acl2::sbyte64-listp)
   (and (posp n)
        (append
         (gen-powers b (1- n))
         (list (long-fix (expt (ifix b) (1- n))))))
   ///
   (fty::deffixequiv gen-powers)))


(defconst *Powers.MAX_POW_10_EXP* 19)

(defconst *Powers.pow10*
  (gen-powers 10 (+ *Powers.MAX_POW_10_EXP* 1)))

(defruled nth-pow10-when-i<=MAX_POW_10_EXP
  (implies (and (natp i)
                (< i (len *Powers.pow10*)))
           (equal (nth i *Powers.pow10*)
                  (long-fix (expt 10 (nfix i)))))
  :cases ((= i 0) (= i 1) (= i 2) (= i 3) (= i 4)
          (= i 5) (= i 6) (= i 7) (= i 8) (= i 9)
          (= i 10) (= i 11) (= i 12) (= i 13) (= i 14)
          (= i 15) (= i 16) (= i 17) (= i 18) (= i 19)))

(define Powers.pow10[]
  ((i acl2::sbyte32p))
  :returns (result-or-exception (implies result-or-exception
                                         (acl2::sbyte64p result-or-exception))
                                :hints (("goal" :use nth-pow10-when-i<=MAX_POW_10_EXP)))
  (acl2::b*
   ((i (acl2::sbyte32-fix i)))
   (and (natp i) (< i (len *Powers.pow10*)) (nth i *Powers.pow10*)))
  ///
  (fty::deffixequiv Powers.pow10[])
  (defrule Powers.pow10[]-type
    (or (null (Powers.pow10[] i))
        (integerp (Powers.pow10[] i)))
    :rule-classes :type-prescription)
  (defruled Powers.pow10[]-when-i<=MAX_POW_10_EXP
    (implies (and (natp i)
                  (<= i *Powers.MAX_POW_10_EXP*))
             (equal (Powers.pow10[] i)
                    (long-fix (expt 10 i))))
    :enable acl2::sbyte32p
    :use (:instance nth-pow10-when-i<=MAX_POW_10_EXP))
  (defruled Powers.pow10[]-when-i<MAX_POW_10_EXP
    (implies (and (natp i)
                  (< i *Powers.MAX_POW_10_EXP*))
             (equal (Powers.pow10[] i)
                    (expt 10 i)))
    :use (:instance nth-pow10-when-i<=MAX_POW_10_EXP)
    :cases ((= i 0) (= i 1) (= i 2) (= i 3) (= i 4)
            (= i 5) (= i 6) (= i 7) (= i 8) (= i 9)
            (= i 10) (= i 11) (= i 12) (= i 13) (= i 14)
            (= i 15) (= i 16) (= i 17) (= i 18))))

(fty::defprod DoubleToDecimal
  ((e acl2::sbyte32p)
   (q acl2::sbyte32p)
   (c acl2::sbyte64p)
   (lout acl2::sbyte32p)
   (rout acl2::sbyte32p)
   (buf character-listp)
   (index acl2::sbyte32p)))

(defconst *H* 17)

; stub of method DoubleToDecimal.toChars(long f, int e)
; returns positive rational instead of String
; TODO implement rendering to chars
(define DoubleToDecimal.toChars
  ((this DoubleToDecimal-p)
   (f acl2::sbyte64p)
   (e acl2::sbyte32p))
  :returns (result rationalp :rule-classes :type-prescription)
  (declare (ignore this))
  (acl2::b*
   ((f (acl2::sbyte64-fix f))
    (e (acl2::sbyte32-fix e)))
   (* f (expt 10 (- e *H*))))
  ///
  (fty::deffixequiv DoubleToDecimal.toChars))

(local
 (acl2::with-arith5-help
  (defrule loop-measure-decreases
    (implies (and (acl2::sbyte32p g)
                  (<= 0 g))
             (< (int-fix (+ -1 g)) g))
    :enable int-fix)))

(acl2::with-arith5-help
 (define DoubleToDecimal.fullCaseXS-loop
  ((this DoubleToDecimal-p)
   (g acl2::sbyte32p)
   (sbH acl2::sbyte64p)
   (p acl2::sbyte32p)
   (vb natp)
   (vbl natp)
   (vbr natp))
  :measure (nfix (+ (acl2::sbyte32-fix g) 1))
  :returns (result-or-exception (or (not result-or-exception)
                                    (rationalp result-or-exception))
                                :rule-classes :type-prescription)
  (acl2::b*
   (((DoubleToDecimal this) this)
    (g (acl2::sbyte32-fix g))
    (sbH (acl2::sbyte64-fix sbH))
    (p (acl2::sbyte32-fix p))
    (vb (nfix vb))
    (vbl (nfix vbl))
    (vbr (nfix vbr))

    ((unless (>= g 0)) nil) ; AssertionError
    (di (Powers.pow10[] g))
    ((unless di) nil) ; ArrayIndexOutOfBounds
    ((when (= di 0)) nil) ; DivideByZeroError
    (sbi (long-fix (- sbH (lrem sbH di))))
    (ubi (Natural.valueOfShiftLeft sbi p))
    ((unless ubi) nil)
    (wbi (Natural.valueOfShiftLeft (long-fix (+ sbi di)) p))
    ((unless wbi) nil)
    (uin (<= (int-fix (+ (Natural.compareTo vbl ubi) this.lout)) 0))
    (win (<= (int-fix (+ (Natural.compareTo wbi vbr) this.rout)) 0))
    ((when (and uin (not win)))
     (DoubleToDecimal.toChars this sbi this.e))
    ((when (and (not uin) win))
     (DoubleToDecimal.toChars this (long-fix (+ sbi di)) this.e))
    ((when uin)
     (let ((cmp (Natural.closerTo vb ubi wbi)))
       (if (or (< cmp 0)
               (and (= cmp 0)
                    ; di=0 was checked before
                    (= (long-fix (logand (ldiv sbi di) 1)) 0)))
           (DoubleToDecimal.toChars this sbi this.e)
         (DoubleToDecimal.toChars this (long-fix (+ sbi di)) this.e)))))
   (DoubleToDecimal.fullCaseXS-loop
    this (int-fix (- g 1)) sbH p vb vbl vbr))))