;; =====================================================
;; VerifiedDeliveryEscrow
;; Trust-minimized delivery escrow with timeout fallback
;; =====================================================

;; -----------------------------
;; Data Variables
;; -----------------------------

(define-data-var buyer principal tx-sender)
(define-data-var seller principal 'SP000000000000000000002Q6VF78)

(define-data-var amount uint u0)
(define-data-var funded bool false)
(define-data-var delivered bool false)
(define-data-var released bool false)

(define-data-var delivery-deadline uint u0)
(define-data-var confirmation-deadline uint u0)

(define-data-var proof-hash (optional (buff 32)) none)

;; -----------------------------
;; Errors
;; -----------------------------

(define-constant ERR-NOT-BUYER (err u100))
(define-constant ERR-NOT-SELLER (err u101))
(define-constant ERR-NOT-FUNDED (err u102))
(define-constant ERR-ALREADY-FINALIZED (err u103))
(define-constant ERR-DEADLINE-PASSED (err u104))
(define-constant ERR-NOT-DELIVERED (err u105))
(define-constant ERR-NOT-READY (err u106))

;; -----------------------------
;; Initialize Escrow
;; -----------------------------

(define-public (initialize
  (new-seller principal)
  (escrow-amount uint)
  (delivery-time uint)
  (confirmation-time uint)
)
  (begin
    (asserts! (not (var-get funded)) ERR-ALREADY-FINALIZED)
    (asserts! (> escrow-amount u0) ERR-NOT-READY)

    (var-set seller new-seller)
    (var-set amount escrow-amount)
    (var-set delivery-deadline (+ stacks-block-height delivery-time))
    ;; Store the duration first, will be updated to absolute height on delivery
    (var-set confirmation-deadline confirmation-time)

    (ok true)
  )
)

;; -----------------------------
;; Fund Escrow
;; -----------------------------

(define-public (fund)
  (begin
    (asserts! (is-eq tx-sender (var-get buyer)) ERR-NOT-BUYER)
    (asserts! (not (var-get funded)) ERR-ALREADY-FINALIZED)

    ;; FIXED: Added try! to check intermediary response
    (try! (stx-transfer? (var-get amount) tx-sender (as-contract tx-sender)))

    (var-set funded true)
    (ok true)
  )
)

;; -----------------------------
;; Submit Delivery Proof
;; -----------------------------

(define-public (submit-proof (hash (buff 32)))
  (begin
    ;; FIXED: Use var-get for seller
    (asserts! (is-eq tx-sender (var-get seller)) ERR-NOT-SELLER)
    (asserts! (var-get funded) ERR-NOT-FUNDED)
    (asserts! (not (var-get delivered)) ERR-ALREADY-FINALIZED)
    (asserts! (< stacks-block-height (var-get delivery-deadline)) ERR-DEADLINE-PASSED)

    (var-set proof-hash (some hash))
    (var-set delivered true)
    ;; Update confirmation deadline to an absolute block height
    (var-set confirmation-deadline (+ stacks-block-height (var-get confirmation-deadline)))

    (ok true)
  )
)

;; -----------------------------
;; Buyer Confirms Delivery
;; -----------------------------

(define-public (confirm)
  (begin
    (asserts! (is-eq tx-sender (var-get buyer)) ERR-NOT-BUYER)
    (asserts! (var-get delivered) ERR-NOT-DELIVERED)
    (asserts! (not (var-get released)) ERR-ALREADY-FINALIZED)

    (var-set released true)

    ;; FIXED: Added try! and used var-get for amount/seller
    (try! (as-contract (stx-transfer? (var-get amount) tx-sender (var-get seller))))
    (ok true)
  )
)

;; -----------------------------
;; Auto-Release After Timeout
;; -----------------------------

(define-public (auto-release)
  (begin
    (asserts! (var-get delivered) ERR-NOT-DELIVERED)
    (asserts! (not (var-get released)) ERR-ALREADY-FINALIZED)
    (asserts! (>= stacks-block-height (var-get confirmation-deadline)) ERR-NOT-READY)

    (var-set released true)

    ;; FIXED: Added try! and used var-get
    (try! (as-contract (stx-transfer? (var-get amount) tx-sender (var-get seller))))
    (ok true)
  )
)

;; -----------------------------
;; Refund If Seller Fails
;; -----------------------------

(define-public (refund)
  (begin
    (asserts! (var-get funded) ERR-NOT-FUNDED)
    (asserts! (not (var-get delivered)) ERR-NOT-DELIVERED)
    (asserts! (>= stacks-block-height (var-get delivery-deadline)) ERR-NOT-READY)
    (asserts! (not (var-get released)) ERR-ALREADY-FINALIZED)

    (var-set released true)

    ;; FIXED: Added try! and used var-get
    (try! (as-contract (stx-transfer? (var-get amount) tx-sender (var-get buyer))))
    (ok true)
  )
)

;; -----------------------------
;; Read-only Views
;; -----------------------------

(define-read-only (get-status)
  {
    buyer: (var-get buyer),
    seller: (var-get seller),
    amount: (var-get amount),
    funded: (var-get funded),
    delivered: (var-get delivered),
    released: (var-get released),
    delivery-deadline: (var-get delivery-deadline),
    confirmation-deadline: (var-get confirmation-deadline),
    proof-hash: (var-get proof-hash)
  }
)