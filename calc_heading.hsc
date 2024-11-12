; temporary variables for the calculation
(global real gps_tmp1 0)
(global real gps_tmp2 0)
(global real gps_tmp3 0)
(global real gps_tmp4 0)

; holds the output coordinates
(global real obj_x 0)
(global real obj_y 0)
(global real obj_z 0)

(global real obj_heading_a_x 0)
(global real obj_heading_a_y 0)
(global real obj_heading_a_z 0)
(global real obj_heading_b_x 0)
(global real obj_heading_b_y 0)
(global real obj_heading_b_z 0)

(script static void (get_obj_pos (object target))
  (set gps_tmp1 (objects_distance_to_flag target gps1))
  (set gps_tmp2 (objects_distance_to_flag target gps2))
  (set gps_tmp3 (objects_distance_to_flag target gps3))
  (set gps_tmp4 (objects_distance_to_flag target gps4))
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

; Global temporary variables for calculations
(global real heading_dx 0)
(global real heading_dy 0)
(global real heading_angle 0)
(global real heading_tmp 0)
(global boolean heading_calc_complete false)

; Function to compute the compass heading from object A to object B
(script static void (compute_heading (object a) (object b))
    ; Get positions of object A
	(get_obj_pos a)
	(set obj_heading_a_x obj_x)
	(set obj_heading_a_y obj_y)
	;(set obj_heading_a_z obj_z)
	; Get positions of object B
	(get_obj_pos b)
	(set obj_heading_b_x obj_x)
	(set obj_heading_b_y obj_y)
	;(set obj_heading_b_z obj_z)

    ; Subtract positions to get difference vector D = B - A
    (set heading_dx (- obj_heading_b_x obj_heading_a_x))
	(set heading_dy (- obj_heading_b_y obj_heading_a_y))

    ; Handle special cases where dx or dy is zero
    (if (= heading_dx 0)
        (cond 
			((> heading_dy 0)  (set heading_angle 0))     ; North
			((<= heading_dy 0) (set heading_angle 180))	; South
		)
		(set heading_calc_complete true)
	)

    (if (not heading_calc_complete)
		(if (= heading_dy 0)
        	(cond 
				((> heading_dx 0) (set heading_angle 90))   ; East
            	((<= heading_dx 0) (set heading_angle 270)) ; West
        	)
			(set heading_calc_complete true)
		)
    )

	(if (not heading_calc_complete)
		(begin
			; Calculate the angle in degrees
			(set heading_tmp (/ heading_dy heading_dx))
			(set heading_angle (arctangent_approx heading_tmp))

			; Adjust angle based on quadrant
			(if (< heading_dx 0)
				(set heading_angle (+ heading_angle 180))
			)
			(if (and (> heading_dx 0) (< heading_dy 0))
				(set heading_angle (+ heading_angle 360))
			)

			; Convert mathematical angle to compass heading
			(set heading_angle (- 90 heading_angle))
			(if (< heading_angle 0)
				(set heading_angle (+ heading_angle 360))
			)
		)
	)

	(set heading_calc_complete false)

)

; Constants for approximation
(global real PI 3.1415926535)
(global real coeff1 57.2957795) ; 180/π to convert radians to degrees

; Approximate arctangent function in degrees
(script static real (arctangent_approx (real x))
	(* x coeff1)
)

; Example usage: compute heading from player0 to gps1
(script continuous compass_heading
    (print "Computing compass heading from player0 to gps1:")
    (compute_heading (list_get(players) 0) box1)
    (print "Compass Heading (degrees):")
    (inspect heading_angle)
    (sleep 120)
)
