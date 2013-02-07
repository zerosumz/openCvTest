(load "main.so")
(set-gc-report! #t) ; to see some finalizer output
(let ((me (load-image "me.jpg"))
      (storage (create-storage))
      (cascade (load-cascade "haarcascade_frontalface_default.xml")))
  (cvNamedWindow "haha" 1)
  (cvShowImage "haha" me)
  (cvWaitKey 0)
  (for-each (lambda (rect)
	      (let* ((base-x (rect-x rect))
		     (base-y (rect-y rect))
		     (left-up-point (cvPoint base-x base-y))
		     (right-bottom-point (cvPoint (+ (rect-width rect) base-x) 
						  (+ (rect-height rect) base-y))))
		(cvRectangle me left-up-point right-bottom-point (get-color 255 0 0 ) 3 4 0)))
	    (CvSeq->rect-list (cvHaarDetectObjects me cascade storage 1.1 3 0 (cvSize 40 40) (cvSize 0  0))))
  (cvShowImage "haha" me)
  (cvWaitKey 0)
  (cvDestroyWindow "haha"))



