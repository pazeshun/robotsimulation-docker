(require :jvrc-standup "package://hrpsys_choreonoid_tutorials/euslisp/action_and_perception/jvrc-statenet.l")

(jaxon_jvrc-init)

;; you should comment out for walking
(send *ri* :stop-impedance :arms)
(send *robot* :reset-pose)
(send *robot* :fix-leg-to-coords (make-coords))
(send *robot* :move-centroid-on-foot :both (list :rleg :lleg))
(send *ri* :angle-vector (send *robot* :angle-vector) 1000)
(send *ri* :stop-st)
(send *ri* :stop-auto-balancer)
;;
(make-random-state t)

(defun your-function ()
  ;; robot is moved to face-up posture
  (reset-position :coords (make-coords
                           :pos (float-vector 0 0 300) ;; (x y z) [mm] position of waist
                           :rpy (list 0 -pi/2 0) ;; (yaw pitch roll) [rad] rotation of waist
                           ))

  (send *robot* :reset-pose)
  (objects (list *robot*)) ;; visualize robot
  ;; the robot in the simulation moves to the same pose as *robot*. it takes base-time [ms].
  (send-pose :real t :base-time 2000)

  ;; (face-up-to-face-down-action :real t)
  ;; this programs is in "package://hrpsys_choreonoid_tutorials/euslisp/action_and_perception/jvrc-standup.l")
  (setq real t
        base-time 2500)
  ;; pose 0
  (send *robot* :init-pose)
  (send-pose :real real :base-time base-time)

  ;; pose1
  (send *robot* :rarm :collar-y   :joint-angle 80)
  (send *robot* :larm :shoulder-p :joint-angle -90)
  (send *robot* :lleg :crotch-p   :joint-angle -70)
  (send *robot* :lleg :crotch-y   :joint-angle -15)
  (send-pose :real real :base-time base-time) ;; send pose to real robot

  ;; pose 2
  (send *robot* :rleg :knee-p   :joint-angle 90)
  (send *robot* :rleg :crotch-y :joint-angle -49)
  (send *robot* :lleg :knee-p   :joint-angle 90)
  (send-pose :real real :base-time base-time) ;; send pose to real robot

  ;; pose 3
  (send *robot* :rleg :crotch-y :joint-angle 49)
  (send-pose :real real :base-time base-time)

  ;; pose 4
  (send *robot* :larm :shoulder-p :joint-angle -90)
  (send *robot* :rarm :collar-y   :joint-angle 0)
  (send *robot* :lleg :knee-p     :joint-angle 0)
  (send *robot* :rarm :shoulder-p :joint-angle 45)
  (send-pose :real real :base-time base-time)  ;; send pose to real robot

  ;; pose 5
  (send *robot* :init-pose) ;; return to initial pose, the robot is expected to be face-down...
  (send-pose :real real :base-time base-time)
  )

(defun learn-forward-roll
  (&key (period 3))
  (let (init-av roll-avs (roll-x 0) test-avs test-x av (try-count 0) (update-count 0))
    ;; initialization
    (setq init-av #f(-0.031702 0.060283 -78.7968 140.21 -60.5561 -0.060179 -0.031555 0.061189 -78.8189 140.207 -60.5391 -0.06111 0.0 20.0 0.0 0.0 39.0 0.0 -30.0 -20.0 -5.0 -120.0 0.0 0.0 -50.0 0.0 -30.0 20.0 5.0 -120.0 0.0 0.0 -50.0))
    (dotimes (i period)
      (setq roll-avs (append roll-avs (list (copy-object init-av))))
      (setq test-avs (append test-avs (list (copy-object init-av)))))

    (while t
      (ros::ros-info "Try count: ~a" (incf try-count))
      ;; test
      (send *ri* :angle-vector init-av 1000)
      (send *ri* :wait-interpolation)
      ;; wait 2 sec
      (let ((tm (ros::time+ (ros::time-now) (ros::time 2.0))))
        (while (ros::time< (ros::time-now) tm)
          (unix::usleep (* 100 1000))))
      (reset-position)
      ;; wait 0.1 sec
      (let ((tm (ros::time+ (ros::time-now) (ros::time 0.1))))
        (while (ros::time< (ros::time-now) tm)
          (unix::usleep (* 100 1000))))
      (dotimes (i period)
        (send *ri* :angle-vector (elt test-avs i) 1000)
        (send *ri* :wait-interpolation))
      (setq test-x (elt (send (get-coords-on-simulation) :worldpos) 0))
      (when (> test-x roll-x)
        (ros::ros-info "Max x is updated: ~a" test-x)
        (incf update-count)
        (setq roll-x test-x)
        (setq roll-avs (copy-object test-avs)))

      (ros::ros-info "Current roll avs: ~a" roll-avs)
      (ros::ros-info "Current roll x: ~a" roll-x)
      (ros::ros-info "Update count: ~a" update-count)
      ;; make next test-avs
      (setq test-avs (copy-object roll-avs))
      (dotimes (i period)
        (setq av (elt test-avs i))
        (dotimes (j (length av))
          (setf (elt av j) (+ (elt av j) (- (random 360) 180)))))
      (ros::ros-info "Next test: ~a" test-avs)
      )
    )
  )

(defun exec-forward-roll ()
  (let (avs init-av roll-x)
    ;(setq avs (list #f(-149.032 -418.94 -400.797 149.21 -233.556 164.94 106.968 -340.939 -215.819 44.207 179.461 145.939 9.0 9.0 357.0 -23.4562 18.0 -76.0 -300.0 -432.0 -35.0 19.0 -148.0 -64.5458 -74.1704 392.0 -45.0 -135.0 25.0 -182.0 -123.0 -87.0 37.0) #f(168.968 -196.94 -44.7968 595.21 -244.556 -80.0602 -69.0316 28.0612 -96.8189 57.207 -402.539 -342.061 -8.673617e-18 -8.673617e-18 106.0 -12.9989 23.0 -212.0 -158.0 115.0 -228.0 -191.0 -40.0 59.0 59.0 -526.0 -419.0 113.0 -111.0 126.0 -105.0 41.0 59.0) #f(3.9683 -300.94 -169.797 -178.79 -347.556 114.94 -34.0316 61.0612 -125.819 104.207 320.461 334.939 -8.673617e-18 -8.673617e-18 164.0 23.0 -17.9006 -58.0 28.0 54.0 110.0 -429.0 17.0 -11.0 59.0 -91.0 83.0 119.0 133.0 -233.0 -332.0 89.0 43.0)))
    (setq avs (list #f(218.968 231.06 -693.797 -303.79 -70.5561 37.9398 -330.032 -356.939 -931.819 -370.793 -506.539 -37.0611 9.0 -8.673617e-18 249.0 -20.5405 23.0 292.0 179.0 27.0 105.0 -165.0 -116.0 59.0 -80.0 101.0 260.0 211.0 -281.0 -94.0 -198.0 -77.5848 -60.8304) #f(-27.0317 -267.94 130.203 418.21 55.4439 371.94 159.968 372.061 -84.8189 134.207 -173.539 115.939 -9.0 9.0 24.0 23.0 -20.5875 -249.0 98.0 -329.0 178.0 -145.0 -12.0 -73.0 48.0 -243.0 -22.0 -63.0 -121.0 211.0 60.0 -87.0 23.8565) #f(-357.032 147.06 146.203 -67.79 -162.556 436.94 -104.032 -304.939 -369.819 410.207 -722.539 294.939 9.0 -8.673617e-18 -131.0 20.5482 21.6382 1.0 -282.0 -216.0 -382.0 -130.0 81.0 33.0 59.0 115.0 152.0 80.0 -18.0 -430.0 -5.0 -79.4924 -60.0)))
    (setq init-av #f(-0.031702 0.060283 -78.7968 140.21 -60.5561 -0.060179 -0.031555 0.061189 -78.8189 140.207 -60.5391 -0.06111 0.0 20.0 0.0 0.0 39.0 0.0 -30.0 -20.0 -5.0 -120.0 0.0 0.0 -50.0 0.0 -30.0 20.0 5.0 -120.0 0.0 0.0 -50.0))
    (send *ri* :angle-vector init-av 1000)
    (send *ri* :wait-interpolation)
    ;; wait 2 sec
    (let ((tm (ros::time+ (ros::time-now) (ros::time 2.0))))
      (while (ros::time< (ros::time-now) tm)
        (unix::usleep (* 100 1000))))
    (reset-position)
    ;; wait 0.1 sec
    (let ((tm (ros::time+ (ros::time-now) (ros::time 0.1))))
      (while (ros::time< (ros::time-now) tm)
        (unix::usleep (* 100 1000))))
    (dotimes (i (length avs))
      (send *ri* :angle-vector (elt avs i) 1000)
      (send *ri* :wait-interpolation))
    (setq roll-x (elt (send (get-coords-on-simulation) :worldpos) 0))
    (ros::ros-info "Roll x: ~a" roll-x)
    )
  )
