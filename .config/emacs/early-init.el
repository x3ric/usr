(setq gc-cons-threshold most-positive-fixnum)
(defvar emacs-start-time (current-time))

(setq package-enable-at-startup nil)

(defun display-startup-echo-area-message ()
  (message ""))

(setq inhibit-startup-message t)
(setq initial-scratch-message nil)


;; (setq inhibit-default-init t)

(add-to-list 'default-frame-alist '(background-color . "#212121"))


(set-face-attribute 'default nil
                    :family "MesloLGS NF"
                    :weight 'bold
                    :height 110)

(setq frame-resize-pixelwise t)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
