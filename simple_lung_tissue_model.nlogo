breed[ t_cell t_cells ]
t_cell-own[
  spd
  age
]

breed[ chemokine chemokines ]
chemokine-own[
  direction
  time_alive
]

patches-own[ state time_in_state ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  reset-ticks
  setup_cells
end

;; setup helper function
to setup_cells
  ask patches[set state "heathy"]
  let x random-xcor
  let y random-ycor
  infect_cell patch 0 0
end


to go
  tissue_behavior
  t_cell_behavior
  chemokine_behavior
  tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; dictates virus spread to healthy cells, virus progression in infected cells, cell death
to tissue_behavior
  ask patches with [state = "incubating"][
    if time_in_state = 10[
      set state "secreting"
      set time_in_state 0
    ]
  ]
  ask patches with [state = "secreting"][
    ifelse time_in_state >= 17
      [cell_death]
      [infect_cell patches in-radius 10]
  ]
  ask patches with [state = "apoptotic"][
    if time_in_state = 1[cell_death]
  ]
  ask patches with [state != "heathy" and state != "dead"][set time_in_state (time_in_state + 1)]
end

;; takes a patch or group of patches and sets them to incubate
to infect_cell [pat]
  ask pat[
    if state = "heathy"[    ;; introduce probablility here!
      set state "incubating"
      set pcolor red
    ]
  ]
end

;; cell death helper function
to cell_death
  set state "dead" set time_in_state -1 set pcolor yellow
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; dictates how T cells spawn, induct, move, decay
to t_cell_behavior
  spawn_t_cells
  ask t_cell[
    if [state] of patch-here = "secreting"[
      t_cell_induction patch-here
      set age age_at_infection_site
      set spd 0

    ]
    t_cell_move
    t_cell_decay
  ]
end

;; helper function to spawn T cells
to spawn_t_cells
  if ticks > 120[
    create-t_cell t_cell_production_rate[set size 5 set color green set shape "circle" setxy random-xcor random-ycor set age age_in_blood set spd t_cell_speed]
  ]
end

;; helper function to simulate T cell induction given a patch
to t_cell_induction [pat]
  ask pat[set state "apoptotic" set time_in_state 0]
end

;; helper function to move T cells:
; if any chemokines are nearby, the T cell will randomly move twords one
; else random walk
to t_cell_move
  carefully[
    face one-of chemokine in-radius 50
    forward spd
  ]
  [
    set heading random 359
    forward spd
  ]

end

;; helper function for cell decay
to t_cell_decay
  if age <= 0[die]
  set age age - 1
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; dictates chemokine spawn, diffusion, decay
to chemokine_behavior
  spawn_chemokine
  ask chemokine[chemokine_diffuse chemokine_decay]
end

;; helper function to spawn chemokine
to spawn_chemokine
  ask patches with [state = "secreting"][sprout-chemokine 1[set color blue set size 2 set shape "circle" set direction random 359]]
end

;; helper function to diffuse chemokine
to chemokine_diffuse
    forward chemokine_diffusion_rate
end

;; helper function to decay chemokine
to chemokine_decay
  if time_alive > chemokine_decay_rate[die]
  set time_alive time_alive + 1
end

;; TODO ;;

; correct slider values and constents
; make it look pretty
