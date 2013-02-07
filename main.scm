(use big-chicken)
(require-extension bind foreigners)

(foreign-declare  #<<EOF
#include <cv.h>
#include <ml.h>
#include <cxcore.h>
#include <highgui.h>

EOF
)



(bind* #<<EOF


struct CvPoint cvPoint(int x, int y);
struct CvSize cvSize(int width, int height);
struct CvScalar cvScalar(double val0, double val1, double val2, double val3);
typedef void ( *CvMouseCallback_ )(int event, int x, int y, int, void*);


// 메모리관련
CvMemStorage* cvCreateMemStorage(int block_size);
void* cvLoad(const char* filename, 
		   CvMemStorage* memstorage, 
		   const char* name, 
		   const char** real_name );

IplImage* cvLoadImage(const char*, int);
// 렌더링
void cvShowImage(const char* name, const CvArr* image);

int cvNamedWindow(const char*, int);

int cvWaitKey(int);

void cvSetMouseCallback_( const char* window_name, CvMouseCallback_ on_event, void* param ){
 cvSetMouseCallback(window_name, on_event, param);
}


// 메모리해제
void _cvReleaseImage(IplImage* image){
 cvReleaseImage(&image);
}

void cvDestroyWindow(const char*);

// 인식함수
CvSeq* cvHaarDetectObjects(const CvArr* image, 
				 CvHaarClassifierCascade* cascade, 
				 CvMemStorage* storage, 
				 double scale_factor, 
				 int min_neighbors, 
				 int flags, 
				 struct CvSize min_size, 
				 struct CvSize max_size );
// 사각형관련.
schar* cvGetSeqElem(const CvSeq* seq, int index);
 						 
void cvRectangle(CvArr* img, struct CvPoint pt1, struct CvPoint pt2, struct CvScalar color, int thickness, int line_type, int shift );

EOF
)

(define-foreign-record-type (seq "struct CvSeq")
  (constructor: make-seq)
  (destructor: free-seq)
  (int flags seq-flag seq-flag-set!)
  (int header_size seq-header_size seq-header_size-set!)
  (int total seq-total seq-total-set!)
  (int elem_size seq-elem_size seq-elem_size-set!)
  (c-pointer storage seq-storage seq-storage-set!)
  (c-pointer first seq-first seq-first-set!))

(define-foreign-record-type (rect "struct CvRect")
  (constructor: make-rect)
  (destructor: free-rect)
  (int x rect-x rect-x-set!)
  (int y rect-y rect-y-set!)
  (int width rect-width rect-width-set!)
  (int height rect-height rect-height-set!))

(define (get-color red green blue)
  (cvScalar green blue red 0))

(define (load-image path #!optional(option 1))
  (let ((rest (cvLoadImage path option)))
    (set-finalizer! rest _cvReleaseImage)
    rest))

(define (create-storage #!optional (init 0))
  (cvCreateMemStorage init))


(define (CvSeq->rect-list cvseq)
  (define (iter m n)
    (if (>= m n)
	'()
	(cons (cvGetSeqElem cvseq m) 
	      (iter (add1 m) n))))
  (iter 0 (seq-total cvseq)))

(define (load-cascade path #!optional storage name rel-name)
  (cvLoad path storage name rel-name))


