;;; -*- Emacs-Lisp -*-
;;; $Id$

;;; Author: Tsuchiya Masatoshi <tsuchiya@pine.kuee.kyoto-u.ac.jp>
;;; Keywords: dictionary

;;; Commentary:

;; This file is a part of sdic. Please see sdic.el for more detail.

;; SDIC �����μ���� sdicf.el �����Ѥ��Ƹ�������饤�֥��Ǥ���


;;; Install:

;; (1) �����Ŭ�ڤʷ������Ѵ����ơ�Ŭ���ʾ��( ��: /usr/dict/ )����¸
;;     ���Ʋ������������Ѵ��ѥ�����ץȤȤ��ưʲ��� Perl ������ץȤ�
;;     ���ѤǤ��ޤ���
;;
;;         gene.perl    - GENE95 ����
;;         edict.perl   - EDICT ����
;;         eijirou.perl - �Ѽ�Ϻ
;;
;; (2) �Ȥ���褦�ˤ���������������� sdic-eiwa-dictionary-list �ޤ�
;;     �� sdic-waei-dictionary-list ���ɲä��Ʋ�������
;;
;;         (setq sdic-eiwa-dictionary-list
;;               (cons '(sdicf-client "/usr/dict/gene.dic") sdic-eiwa-dictionary-list))
;;
;;     �����������ϼ��Τ褦�ʹ����ˤʤäƤ��ޤ���
;;
;;         (sdicf-client �ե�����̾ (���ץ����A ��A) (���ץ����B ��B) ...)
;;
;;     ���̤ʻ��꤬���פʾ��ˤϡ����ץ����Ͼ�ά�Ǥ��ޤ���
;;
;;         (sdicf-client �ե�����̾)


;;; Options:

;; sdicf-client.el ���Ф��ƻ���Ǥ��륪�ץ����ϼ����̤�Ǥ���
;;
;; coding-system
;;     ����δ��������ɤ���ꤷ�ޤ�����ά�������ϡ�
;;     sdic-default-coding-system ���ͤ�Ȥ��ޤ���
;;
;; title
;;     ����Υ����ȥ����ꤷ�ޤ�����ά�������ϡ�����ե������ 
;;     basename �򥿥��ȥ�Ȥ��ޤ���
;;
;; add-keys-to-headword
;;     ���Ƥθ���������ޤ�Ƹ��Ф������������� t �����ꤷ�Ʋ���
;;     �����±Ѽ���򸡺�������ˡ����겾̾��ޤ�ƽ��Ϥ��������
;;     �Ѥ��ޤ���
;;
;; strategy
;;     sdicf.el ���̤��Ƽ���򸡺�������� strategy ����ꤷ�ޤ�����ά
;;     �������ϡ�sdicf.el �μ�ưȽ��ˤ�ä����Ф줿 strategy �����
;;     ���ޤ���


;;; Note;

;; sdicf.el �� SDIC �����μ���򸡺����뤿��Υ饤�֥��Ǥ������줾��
;; �ΰ㤤�ϼ����̤�Ǥ���3����� strategy �����ݡ��Ȥ���Ƥ��ޤ���
;;
;; `direct'
;;     ����ǡ��������ƥ�����ɤ߹���Ǥ��鸡����Ԥ��ޤ�����������
;;     ��ɤ�ɬ�פȤ��ޤ��󤬡����̤Υ��꤬ɬ�פˤʤ�ޤ���
;;
;; `grep'
;;     fgrep �����Ѥ��Ƹ�����Ԥ��ޤ���
;;
;; `array'
;;     array �����Ѥ��Ƹ�����Ԥ��ޤ�������� index file �����������
;;     ���Ƥ����Ƥ��鸡����Ԥ��ޤ��Τǡ���®�˸�������ǽ�Ǥ�����������
;;     index file �ϼ����3�����٤��礭���ˤʤ�ޤ���
;;
;; ���Ū�����Ϥμ���򸡺�������� `grep' ����Ŭ�Ǥ��礦����������
;; 5MByte ����礭������ξ��� `array' �����Ѥ��θ���٤����Ȼפ���
;; ����
;;
;; SDIC �����μ���ι�¤�ˤĤ��Ƥϡ�sdic.texi �򻲾Ȥ��Ƥ���������


;;; �饤�֥���������
(require 'sdic)
(require 'sdicf)
(provide 'sdicf-client)
(put 'sdicf-client 'version "2.0")
(put 'sdicf-client 'init-dictionary 'sdicf-client-init-dictionary)
(put 'sdicf-client 'open-dictionary 'sdicf-client-open-dictionary)
(put 'sdicf-client 'close-dictionary 'sdicf-client-close-dictionary)
(put 'sdicf-client 'search-entry 'sdicf-client-search-entry)
(put 'sdicf-client 'get-content 'sdicf-client-get-content)



;;;----------------------------------------------------------------------
;;;		����
;;;----------------------------------------------------------------------

(defun sdicf-client-init-dictionary (file-name &rest option-list)
  "Function to initialize dictionary"
  (let ((dic (sdic-make-dictionary-symbol)))
    (if (file-readable-p (setq file-name (expand-file-name file-name)))
	(progn
	  (mapcar '(lambda (c) (put dic (car c) (nth 1 c))) option-list)
	  (put dic 'file-name file-name)
	  (put dic 'identifier (concat "sdicf-client+" file-name))
	  (or (get dic 'title)
	      (put dic 'title (file-name-nondirectory file-name)))
	  (or (get dic 'coding-system)
	      (put dic 'coding-system sdic-default-coding-system))
	  dic)
      (error "Can't read dictionary: %s" (prin1-to-string file-name)))))


(defun sdicf-client-open-dictionary (dic)
  "Function to open dictionary"
  (if (put dic 'sdic-object
	   (sdicf-open (get dic 'file-name) (get dic 'coding-system) (get dic 'strategy)))
      dic))


(defun sdicf-client-close-dictionary (dic)
  "Function to close dictionary"
  (if (get dic 'sdic-object) (sdicf-close (get dic 'sdic-object))))


(defun sdicf-client-search-entry (dic string &optional search-type) "\
Function to search word with look or grep, and write results to current buffer.
search-type ���ͤˤ�äƼ��Τ褦��ư����ѹ����롣
    nil    : �������׸���
    t      : �������׸���
    lambda : �������׸���
    0      : ��ʸ����
������̤Ȥ��Ƹ��Ĥ��ä����Ф���򥭡��Ȥ����������ʸ����Ƭ�� point ���ͤȤ���
Ϣ��������֤���
"
  (let ((case-fold-search t) list)
    (mapcar (if (get dic 'add-keys-to-headword)
		(function
		 (lambda (entry)
		   (setq list (sdicf-entry-keywords entry))
		   (cons (if (= (length list) 1)
			     (car list)
			   (apply 'concat
				  (car list)
				  " "
				  (mapcar (lambda (s) (format "[%s]" s)) (cdr list))))
			 entry)))
	      (function
	       (lambda (entry)
		 (cons (sdicf-entry-headword entry) entry))))
	    (sdicf-search (get dic 'sdic-object)
			  (cond
			   ((not search-type) 'prefix)
			   ((eq search-type t) 'suffix)
			   ((eq search-type 'lambda) 'exact)
			   ((eq search-type 0) 'text)
			   (t (error "Illegal search method : %S" search-type)))
			  string))))


(defun sdicf-client-get-content (dic entry)
  (sdicf-entry-text entry))