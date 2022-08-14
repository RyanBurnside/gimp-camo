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

;; Accessory function for script-fu-make-camo
(define (add-camo-layer image color roughness threshold name)
  (let* ((width (car (gimp-image-width image)))
         (height (car (gimp-image-height image)))
         (new-layer (car (gimp-layer-new image width height 1 name 100 LAYER-MODE-NORMAL-LEGACY))))
    (gimp-context-push)
    (gimp-context-set-defaults)
    (gimp-image-add-layer image new-layer 0)
    (gimp-selection-none image)
    (plug-in-solid-noise 1 image new-layer 1 0 (random 65536) roughness 4.1 4.1)
    (gimp-drawable-threshold new-layer 0 threshold 1.0)
    (gimp-context-set-foreground color)
    (gimp-image-select-color image CHANNEL-OP-ADD new-layer '(255 255 255))
    (gimp-edit-bucket-fill new-layer BUCKET-FILL-FG LAYER-MODE-NORMAL-LEGACY 100 0 FALSE 0 0)
    (gimp-selection-invert image)
    (gimp-edit-cut new-layer)
    (gimp-selection-none image)
    (gimp-context-pop)))

;; Main function
(define (script-fu-make-camo image drawable top-color under-color under-color2 background-color roughness)
  (let* ((width (car (gimp-image-width image)))
         (height (car (gimp-image-height image)))
         (background-layer (car (gimp-layer-new image width height 1 "Camo 3" 100 LAYER-MODE-NORMAL-LEGACY))))

    (gimp-image-undo-group-start image)
    (gimp-context-push)
    (gimp-context-set-defaults)

    ;; Add the background layer
    (gimp-image-add-layer image background-layer 0)

    ;; Set the backing background color
    (gimp-selection-none image)
    (gimp-context-set-foreground background-color)
    (gimp-drawable-fill background-layer FILL-FOREGROUND)

    ;; Add our 3 camo layers
    (add-camo-layer image under-color2 roughness 0.5 "Camo 2")
    (add-camo-layer image under-color roughness 0.5 "Camo 1")
    (add-camo-layer image top-color roughness 0.55 "Camo 0")

    (gimp-displays-flush)
    (gimp-context-pop)
    (gimp-image-undo-group-end image)))
