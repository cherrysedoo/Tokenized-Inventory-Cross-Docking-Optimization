;; Scheduling Coordination Contract
;; Coordinates cross-dock scheduling operations

(define-constant ERR_UNAUTHORIZED (err u300))
(define-constant ERR_INVALID_SCHEDULE (err u301))
(define-constant ERR_SCHEDULE_NOT_FOUND (err u302))
(define-constant ERR_TIME_CONFLICT (err u303))

;; Schedule data structure
(define-map schedules
  { schedule-id: uint }
  {
    manager-id: uint,
    dock-id: uint,
    start-time: uint,
    end-time: uint,
    activity-type: (string-ascii 30),
    allocated-resources: uint,
    status: (string-ascii 20)
  }
)

(define-data-var schedule-counter uint u0)

;; Create schedule
(define-public (create-schedule
  (manager-id uint)
  (dock-id uint)
  (start-time uint)
  (end-time uint)
  (activity-type (string-ascii 30))
  (allocated-resources uint)
)
  (let ((schedule-id (+ (var-get schedule-counter) u1)))
    (begin
      (asserts! (< start-time end-time) ERR_INVALID_SCHEDULE)
      (asserts! (> allocated-resources u0) ERR_INVALID_SCHEDULE)
      (map-set schedules
        { schedule-id: schedule-id }
        {
          manager-id: manager-id,
          dock-id: dock-id,
          start-time: start-time,
          end-time: end-time,
          activity-type: activity-type,
          allocated-resources: allocated-resources,
          status: "scheduled"
        }
      )
      (var-set schedule-counter schedule-id)
      (ok schedule-id)
    )
  )
)

;; Update schedule status
(define-public (update-schedule-status (schedule-id uint) (status (string-ascii 20)))
  (match (map-get? schedules { schedule-id: schedule-id })
    schedule
    (begin
      (map-set schedules
        { schedule-id: schedule-id }
        (merge schedule { status: status })
      )
      (ok true)
    )
    ERR_SCHEDULE_NOT_FOUND
  )
)

;; Check for scheduling conflicts
(define-read-only (check-conflict (dock-id uint) (start-time uint) (end-time uint))
  (ok false) ;; Simplified - in real implementation would check all schedules
)

;; Get schedule details
(define-read-only (get-schedule (schedule-id uint))
  (map-get? schedules { schedule-id: schedule-id })
)

;; Calculate resource utilization
(define-read-only (calculate-utilization (dock-id uint) (time-period uint))
  (ok u75) ;; Simplified calculation - returns 75% utilization
)
