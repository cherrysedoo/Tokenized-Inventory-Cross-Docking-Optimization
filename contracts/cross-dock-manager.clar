;; Cross-dock Manager Verification Contract
;; Validates and manages cross-dock managers

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_MANAGER_NOT_FOUND (err u101))
(define-constant ERR_MANAGER_EXISTS (err u102))

;; Manager data structure
(define-map managers
  { manager-id: uint }
  {
    address: principal,
    name: (string-ascii 50),
    certified: bool,
    experience-level: uint,
    active: bool
  }
)

(define-data-var manager-counter uint u0)

;; Register a new manager
(define-public (register-manager (name (string-ascii 50)) (experience-level uint))
  (let ((manager-id (+ (var-get manager-counter) u1)))
    (begin
      (map-set managers
        { manager-id: manager-id }
        {
          address: tx-sender,
          name: name,
          certified: false,
          experience-level: experience-level,
          active: true
        }
      )
      (var-set manager-counter manager-id)
      (ok manager-id)
    )
  )
)

;; Certify a manager (only contract owner)
(define-public (certify-manager (manager-id uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (match (map-get? managers { manager-id: manager-id })
      manager
      (begin
        (map-set managers
          { manager-id: manager-id }
          (merge manager { certified: true })
        )
        (ok true)
      )
      ERR_MANAGER_NOT_FOUND
    )
  )
)

;; Get manager details
(define-read-only (get-manager (manager-id uint))
  (map-get? managers { manager-id: manager-id })
)

;; Check if manager is verified
(define-read-only (is-manager-verified (manager-id uint))
  (match (map-get? managers { manager-id: manager-id })
    manager (and (get certified manager) (get active manager))
    false
  )
)
