(script-fu-register
 "script-fu-make-camo"     ;func name
 "Generate Camo Noise"     ;menu label
 "Generate camo noise"     ;Description
 "Ryan Burnside"           ;author
 "No copyright protection" ;copyright
 "August 4 2022"           ;date
 ""                        ;image type

 ;; Widgets and top level parameters
 SF-IMAGE      "Image"            0
 SF-DRAWABLE   "Drawable"         0
 SF-COLOR      "Top Color"        '(3 22 2)
 SF-COLOR      "Under Color"      '(144 142 44)
 SF-COLOR      "Under Color 2"    '(134 103 6)
 SF-COLOR      "Background Color" '(59 83 9)
 SF-ADJUSTMENT "Edge Roughness"   '(4 0 15 1 3 0 SF-SLIDER))

;; Register the main function
(script-fu-menu-register "script-fu-make-camo"
                         "<Image>/Script-Fu/")

;; Main function
(define (script-fu-make-camo image drawable top-color under-color under-color2 background-color roughness)
  (let* ((width (car (gimp-image-width image)))
         (height (car (gimp-image-height image)))
         (top-layer (car (gimp-layer-new image width height 1 "Top Camo" 100 LAYER-MODE-NORMAL-LEGACY)))
         (under-layer (car (gimp-layer-new image width height 1 "Under Camo" 100 LAYER-MODE-NORMAL-LEGACY)))
         (under-layer2 (car (gimp-layer-new image width height 1 "Under Camo 2" 100 LAYER-MODE-NORMAL-LEGACY)))
         (background-layer (car (gimp-layer-new image width height 1 "Background Camo" 100 LAYER-MODE-NORMAL-LEGACY)))
         (top-r (car top-color))
         (top-g (cadr top-color))
         (top-b (caddr top-color))
         (under-r (car under-color))
         (under-g (cadr under-color))
         (under-b (caddr under-color))
         (under2-r (car under-color2))
         (under2-g (cadr under-color2))
         (under2-b (caddr under-color2)))

    (gimp-image-undo-group-start image)
    (gimp-context-push)
    (gimp-context-set-defaults)
    
    ;; Add the 3 layers
    (gimp-image-add-layer image background-layer 0)
    (gimp-image-add-layer image under-layer2 0)
    (gimp-image-add-layer image under-layer 0)
    (gimp-image-add-layer image top-layer 0)

    ;; Set the backing background color
    (gimp-selection-none image)
    (gimp-context-set-foreground background-color)
    (gimp-drawable-fill background-layer FOREGROUND-FILL)

    ;; Top Layer (small flecks of color)
    (gimp-selection-none image)
    (plug-in-solid-noise 1 image top-layer 1 0 (random 65536) roughness 4.1 4.1)
    (gimp-drawable-threshold top-layer 0 0.6 1.0)
    (plug-in-exchange 1 image top-layer 255 255 255 top-r top-g top-b 0 0 0)
    (gimp-image-select-color image CHANNEL-OP-REPLACE top-layer '(0 0 0))
    (gimp-edit-cut top-layer)

    ;; Under Layer (larger blocks of color)
    (gimp-selection-none image)
    (plug-in-solid-noise 1 image under-layer 1 0 (random 65536) roughness 4.1 4.1)
    (gimp-drawable-threshold under-layer 0 0.55 1.0)
    (plug-in-exchange 1 image under-layer 255 255 255 under-r under-g under-b 0 0 0)
    (gimp-image-select-color image CHANNEL-OP-REPLACE under-layer '(0 0 0))
    (gimp-edit-cut under-layer)

    ;; Under Layer2 (larger blocks of color)
    (gimp-selection-none image)
    (plug-in-solid-noise 1 image under-layer2 1 0 (random 65536) roughness 4.1 4.1)
    (gimp-drawable-threshold under-layer2 0 0.55 1.0)
    (plug-in-exchange 1 image under-layer2 255 255 255 under2-r under2-g under2-b 0 0 0)
    (gimp-image-select-color image CHANNEL-OP-REPLACE under-layer2 '(0 0 0))
    (gimp-edit-cut under-layer2)
        
    (gimp-displays-flush)
    (gimp-context-pop)
    (gimp-image-undo-group-end image)))
