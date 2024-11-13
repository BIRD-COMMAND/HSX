; temporary variables for the calculation
(global real gps_tmp1 0.0)
(global real gps_tmp2 0.0)
(global real gps_tmp3 0.0)
(global real gps_tmp4 0.0)
; holds the output coordinates
(global real obj_x 0.0)
(global real obj_y 0.0)
(global real obj_z 0.0)
; holds temporary object coordinates
(global real obj_a_x 0.0)
(global real obj_a_y 0.0)
(global real obj_b_x 0.0)
(global real obj_b_y 0.0)
; holds the direction vector
(global real dir_x 0.0)
(global real dir_y 0.0)
; holds the calculated heading
(global real heading 0.0)

(script static void (get_obj_pos (object target))
  (set gps_tmp1 (objects_distance_to_flag target "gps1"))
  (set gps_tmp2 (objects_distance_to_flag target "gps2"))
  (set gps_tmp3 (objects_distance_to_flag target "gps3"))
  (set gps_tmp4 (objects_distance_to_flag target "gps4"))
  (set gps_tmp1 (* gps_tmp1 gps_tmp1))
  (set gps_tmp2 (* gps_tmp2 gps_tmp2))
  (set gps_tmp3 (* gps_tmp3 gps_tmp3))
  (set gps_tmp4 (* gps_tmp4 gps_tmp4))
  (set gps_tmp1 (+ gps_tmp1 (* gps_tmp2 -1) 1))
  (set gps_tmp2 (- gps_tmp2 gps_tmp3))
  (set gps_tmp3 (- gps_tmp3 gps_tmp4))
  (set obj_x (/ gps_tmp1 2))
  (set obj_y (/ (+ gps_tmp1 gps_tmp2) 2))
  (set obj_z (/ (+ gps_tmp1 gps_tmp2 gps_tmp3) 2))
)

; Function to compute the compass heading from object A to object B
(script static void (compute_heading (object a) (object b))
	
	; reset all globals
	(set dir_x 0.0)
	(set dir_y 0.0)
	(set heading 0.0)

	; Get position of object A
	(get_obj_pos a)
	(set obj_a_x obj_x)
	(set obj_a_y obj_y)
	
	; Get position of object B
	(get_obj_pos b)
	(set obj_b_x obj_x)
	(set obj_b_y obj_y)

	; Subtract positions to get difference vector dir_ = B - A
	; dir_ is the direction from A to B
	(set dir_x (- obj_b_x obj_a_x))
	(set dir_y (- obj_b_y obj_a_y))

	; Handle special cases where dir_x or dir_y is zero
	(if (= dir_x 0) (set dir_x 0.0001))
	(if (= dir_y 0) (set dir_y 0.0001))

	
	(if (and (> dir_y 0) (> dir_x 0)) ; Top half-plane and First quadrant
		(set heading (* 360.0 (/ dir_x (+ dir_x dir_y))))
	)
	(if (and (> dir_y 0) (< dir_x 0)) ; Top half-plane and Second quadrant
		(set heading (- 360.0 (* 360.0 (/ (* -1.0 dir_x) (+ (* -1.0 dir_x) dir_y)))))
	)
	(if (and (< dir_y 0) (< dir_x 0)) ; Bottom half-plane and Third quadrant
		(set heading (+ 180.0 (* 360.0 (/ (* -1.0 dir_x) (- (* -1.0 dir_x) dir_y)))))
	)
	(if (and (< dir_y 0) (> dir_x 0)) ; Bottom half-plane and Fourth quadrant
		(set heading (- 180.0 (* 360.0 (/ dir_x (- dir_x dir_y)))))
	)

	; Ensure the angle is within the range [0, 360)
	(if (>= heading 360)
		(set heading (- heading 360))
	)

)

(script continuous compass_heading
	(print "Computing compass heading from player0 to player1:")
	(compute_heading (ai_get_unit jump) box2)
	(print "Compass Heading (degrees):")
	(inspect heading)
	(sleep 120)
)