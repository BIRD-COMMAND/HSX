; Globals
(global real gps_tmp1 0)
(global real gps_tmp2 0)
(global real gps_tmp3 0)
(global real gps_tmp4 0)
(global real obj_x 0)
(global real obj_y 0)
(global real obj_z 0)
(global real obj_a_x 0)
(global real obj_a_y 0)
(global real obj_a_z 0)
(global real obj_b_x 0)
(global real obj_b_y 0)
(global real obj_b_z 0)
(global real dir_x 0)
(global real dir_y 0)
(global real dir_z 0)
(global real dir_heading 0)
(global real dir_jump_pitch 0)
(global real dir_dist_to_target 0)
(global short ai_0_speed_mode 0)
(global real ai_0_movement_magnitude 0.0)
(global ai aia "test_squad/ai_failure")
(global short aia_mode 0)
(global object aia_target "none")
(global ai ai0  "test_squad/ai0")
(global object ai0_target "none")
(global ai ai1  "test_squad/ai1")
(global object ai1_target "none")
(global ai ai2  "test_squad/ai2")
(global object ai2_target "none")
(global ai ai3  "test_squad/ai3")
(global object ai3_target "none")
(global ai ai4  "test_squad/ai4")
(global object ai4_target "none")
(global ai ai5  "test_squad/ai5")
(global object ai5_target "none")
(global ai ai6  "test_squad/ai6")
(global object ai6_target "none")
(global ai ai7  "test_squad/ai7")
(global object ai7_target "none")

; Get the individual X, Y, and Z coordinate values of an object
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

; Get the direction vector from object A to object B - stored in dir_(x,y,z)
(script static void (get_dir_a_to_b (object a) (object b))
	
	; Store the distance to target
	(set dir_dist_to_target (objects_distance_to_object a b))

	; Get position of object A
	(get_obj_pos a)
	(set obj_a_x obj_x)
	(set obj_a_y obj_y)
	(set obj_a_z obj_z)
	
	; Get position of object B
	(get_obj_pos b)
	(set obj_b_x obj_x)
	(set obj_b_y obj_y)
	(set obj_b_z obj_z)
	
	; Subtract positions to get difference vector dir_ = B - A
	; dir_ is the direction from A to B
	(set dir_x (- obj_b_x obj_a_x))
	(set dir_y (- obj_b_y obj_a_y))
	(set dir_z (- obj_b_z obj_a_z))

	; Handle special cases where and dir_ is zero
	(if (= dir_x 0) (set dir_x 0.0001))
	(if (= dir_y 0) (set dir_y 0.0001))
	(if (= dir_z 0) (set dir_z 0.0001))

)

; Computes the compass heading of the direction vector dir_
(script static void (compute_dir_heading (object a) (object b))

	; Get the direction vector from A to B
	(get_dir_a_to_b a b)

	(if (and (> dir_y 0) (> dir_x 0)) ; Top half-plane and First quadrant
		(set dir_heading (+ 90.0 (/ (* 90.0 dir_x) (- (* -1.0 dir_x) dir_y))))
	)
	(if (and (> dir_y 0) (< dir_x 0)) ; Top half-plane and Second quadrant
		(set dir_heading (+ 90.0 (/ (* 90.0 (* -1.0 dir_x)) (+ (* -1.0 dir_x) dir_y))))
	)
	(if (and (< dir_y 0) (< dir_x 0)) ; Bottom half-plane and Third quadrant
		(set dir_heading (+ 270.0 (/ (* 90.0 dir_x) (- (* -1.0 dir_x) dir_y))))
	)
	(if (and (< dir_y 0) (> dir_x 0)) ; Bottom half-plane and Fourth quadrant
		(set dir_heading (+ 270.0 (/ (* 90.0 dir_x) (- dir_x dir_y))))
	)
)

; Square root function
(global real sqrt_tmp 0)
(script static real (sqrt (real x))
  (set sqrt_tmp (/ (+ sqrt_tmp (/ x (/ x 2))) 2))
  (set sqrt_tmp (/ (+ sqrt_tmp (/ x sqrt_tmp)) 2))
  (set sqrt_tmp (/ (+ sqrt_tmp (/ x sqrt_tmp)) 2))
  (set sqrt_tmp (/ (+ sqrt_tmp (/ x sqrt_tmp)) 2))
  (set sqrt_tmp (/ (+ sqrt_tmp (/ x sqrt_tmp)) 2))
  (set sqrt_tmp (/ (+ sqrt_tmp (/ x sqrt_tmp)) 2))
  (+ 0 sqrt_tmp)
)

; WIP - Arcsin function
(global real a_x 0)
(global real arcsin_a 0)
(global real arcsin_ratio 0)
(global boolean arcsin_flip false)
(script static real (arcsin (real arcsin_height) (real arcsin_hypotenuse))
	(set arcsin_flip false)
	(set arcsin_a arcsin_height)
	(if (< arcsin_a 0) (set arcsin_flip true))
	(if (= true arcsin_flip) (set arcsin_a (* -1 arcsin_a)))
	(set arcsin_ratio (/ arcsin_a arcsin_hypotenuse))
	(if (> arcsin_ratio 1) (set arcsin_ratio 1))
	(if (< arcsin_ratio 0) (set arcsin_ratio 0.001))
	(set a_x 
		(+ a_x 
			(+ 
				(/ (* (* a_x a_x) a_x) 6)
				(+
					(/ (* 3 (* (* (* (* a_x a_x) a_x) a_x) a_x)) 40)
					(/ (* 5 (* (* (* (* (* (* a_x a_x) a_x) a_x) a_x) a_x) a_x)) 112)
				)
			)
		)
	)
	(if (= true arcsin_flip) (set a_x (* -1 a_x)))
	(set a_x (* a_x 57.2957795))
	(+ 180 a_x)
)

(global short ind_short 0)
(global long ind_long 0)
(script static void (manage_ai (ai ai_) (long player_index))

	(set ind_short (+ 0 player_index))
	(set ind_long (+ 0 player_index))
	
	; Check if the AI is dead, if so, respawn
	(if (< (object_get_health (ai_get_object  ai_)) 0) (ai_place  ai_))

	(if 
		; If ai_ and the player are alive, move ai_ towards the player
		(and 
			(> (object_get_health (ai_get_object  ai_)) 0) 
			(> (object_get_health (list_get (players) ind_short)) 0)
		)
		(begin

			; Get the heading from ai_ to the player
			(compute_dir_heading (ai_get_object  ai_) (list_get (players) ind_short))
			; Jump if the player is above the AI by a certain amount
			(if (> dir_z 5) (vs_jump  ai_ true dir_jump_pitch 3.0) )
			; Move ai_ towards the player
			(if (>= dir_dist_to_target 5) (vs_move_in_direction  ai_ true dir_heading 0.3 0))
			; Shoot at the player if the player is close
			(if (< dir_dist_to_target 5) (vs_shoot ai_ true (list_get (players) ind_short)))

			; Debug - ai_ Jump
			(if (unit_action_test_right_shoulder (player_get ind_long))
				(begin 
					(effect_new_on_object_marker "objects\characters\grunt\fx\grunt_birthday_party" (ai_get_object  ai_) "head")
					(vs_jump ai_ true 45.0 5.0)
					(unit_action_test_reset (player_get ind_long))
				)
			)

		)
	)
)

(script continuous manage_units
	(manage_ai ai0 0)
	(manage_ai ai1 1)
	(manage_ai ai2 2)
	(manage_ai ai3 3)
	(manage_ai ai4 4)
	(manage_ai ai5 5)
	(manage_ai ai6 6)
	(manage_ai ai7 7)
	(sleep 1)
)