; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -opaque-pointers -passes=newgvn -S %s | FileCheck %s

; Test cases where initially a PHI-of-ops can be simplified to an existing
; value, but later we need to revisit the decision because the leader of
; one of the operands used for the simplification changed.

declare void @use(i1)

define void @pr36501(i1 %c) {
; CHECK-LABEL: @pr36501(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    br label [[BB1:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    [[PHI_1:%.*]] = phi i32 [ -2022207984, [[BB:%.*]] ], [ 0, [[BB7:%.*]] ]
; CHECK-NEXT:    br i1 [[C:%.*]], label [[BB3:%.*]], label [[BB2:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    br label [[BB3]]
; CHECK:       bb3:
; CHECK-NEXT:    [[PHI_2:%.*]] = phi i32 [ -1, [[BB2]] ], [ [[PHI_1]], [[BB1]] ]
; CHECK-NEXT:    [[TMP5:%.*]] = icmp eq i32 [[PHI_2]], 0
; CHECK-NEXT:    br i1 [[TMP5]], label [[BB6:%.*]], label [[BB7]]
; CHECK:       bb6:
; CHECK-NEXT:    br label [[BB7]]
; CHECK:       bb7:
; CHECK-NEXT:    [[PHIOFOPS:%.*]] = phi i1 [ [[TMP5]], [[BB3]] ], [ true, [[BB6]] ]
; CHECK-NEXT:    [[PHI_3:%.*]] = phi i32 [ [[PHI_2]], [[BB3]] ], [ 0, [[BB6]] ]
; CHECK-NEXT:    call void @use(i1 [[PHIOFOPS]])
; CHECK-NEXT:    br label [[BB1]]
;
bb:
  br label %bb1

bb1:
  %phi.1 = phi i32 [ -2022207984, %bb ], [ 0, %bb7 ]
  br i1 %c, label %bb3, label %bb2

bb2:
  br label %bb3

bb3:
  %phi.2 = phi i32 [ -1, %bb2 ], [ %phi.1, %bb1 ]
  %tmp5 = icmp eq i32 %phi.2, 0
  br i1 %tmp5, label %bb6, label %bb7

bb6:
  br label %bb7

bb7:                                              ; preds = %bb6, %bb3
  %phi.3 = phi i32 [ %phi.2, %bb3 ], [ 0, %bb6 ]
  %tmp9 = icmp eq i32 %phi.3, 0
  call void @use(i1 %tmp9)
  br label %bb1
}

define void @pr42422(i1 %c.1, i1 %c.2) {
; CHECK-LABEL: @pr42422(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    br label [[BB1:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    br label [[BB2:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    [[TMP:%.*]] = phi i32 [ [[TMP23:%.*]], [[BB22:%.*]] ], [ 0, [[BB1]] ]
; CHECK-NEXT:    [[TMP3:%.*]] = icmp sle i32 [[TMP]], 1
; CHECK-NEXT:    br i1 [[TMP3]], label [[BB4:%.*]], label [[BB24:%.*]]
; CHECK:       bb4:
; CHECK-NEXT:    br i1 [[C_1:%.*]], label [[BB5:%.*]], label [[BB6:%.*]]
; CHECK:       bb5:
; CHECK-NEXT:    br label [[BB19:%.*]]
; CHECK:       bb6:
; CHECK-NEXT:    br i1 [[C_2:%.*]], label [[BB7:%.*]], label [[BB8:%.*]]
; CHECK:       bb7:
; CHECK-NEXT:    br label [[BB16:%.*]]
; CHECK:       bb8:
; CHECK-NEXT:    [[TMP9:%.*]] = phi i64 [ [[TMP12:%.*]], [[BB11:%.*]] ], [ 0, [[BB6]] ]
; CHECK-NEXT:    [[TMP10:%.*]] = icmp sle i64 [[TMP9]], 1
; CHECK-NEXT:    br i1 [[TMP10]], label [[BB11]], label [[BB13:%.*]]
; CHECK:       bb11:
; CHECK-NEXT:    [[TMP12]] = add nsw i64 [[TMP9]], 1
; CHECK-NEXT:    br label [[BB8]]
; CHECK:       bb13:
; CHECK-NEXT:    br i1 true, label [[BB14:%.*]], label [[BB15:%.*]]
; CHECK:       bb14:
; CHECK-NEXT:    br label [[BB16]]
; CHECK:       bb15:
; CHECK-NEXT:    store i8 poison, ptr null, align 1
; CHECK-NEXT:    br label [[BB16]]
; CHECK:       bb16:
; CHECK-NEXT:    [[TMP17:%.*]] = phi i32 [ poison, [[BB15]] ], [ 1, [[BB14]] ], [ 9, [[BB7]] ]
; CHECK-NEXT:    switch i32 [[TMP17]], label [[BB19]] [
; CHECK-NEXT:    i32 0, label [[BB6]]
; CHECK-NEXT:    i32 9, label [[BB18:%.*]]
; CHECK-NEXT:    ]
; CHECK:       bb18:
; CHECK-NEXT:    br label [[BB19]]
; CHECK:       bb19:
; CHECK-NEXT:    [[TMP20:%.*]] = phi i32 [ 0, [[BB18]] ], [ [[TMP17]], [[BB16]] ], [ 1, [[BB5]] ]
; CHECK-NEXT:    [[TMP21:%.*]] = icmp eq i32 [[TMP20]], 0
; CHECK-NEXT:    br i1 [[TMP21]], label [[BB22]], label [[BB25:%.*]]
; CHECK:       bb22:
; CHECK-NEXT:    [[TMP23]] = add nsw i32 [[TMP]], 1
; CHECK-NEXT:    br label [[BB2]]
; CHECK:       bb24:
; CHECK-NEXT:    br label [[BB25]]
; CHECK:       bb25:
; CHECK-NEXT:    [[PHIOFOPS:%.*]] = phi i1 [ true, [[BB24]] ], [ [[TMP21]], [[BB19]] ]
; CHECK-NEXT:    [[TMP26:%.*]] = phi i32 [ [[TMP20]], [[BB19]] ], [ 0, [[BB24]] ]
; CHECK-NEXT:    br i1 [[PHIOFOPS]], label [[BB1]], label [[BB28:%.*]]
; CHECK:       bb28:
; CHECK-NEXT:    ret void
;
bb:
  br label %bb1

bb1:                                              ; preds = %bb25, %bb
  br label %bb2

bb2:                                              ; preds = %bb22, %bb1
  %tmp = phi i32 [ %tmp23, %bb22 ], [ 0, %bb1 ]
  %tmp3 = icmp sle i32 %tmp, 1
  br i1 %tmp3, label %bb4, label %bb24

bb4:                                              ; preds = %bb2
  br i1 %c.1, label %bb5, label %bb6

bb5:                                              ; preds = %bb4
  br label %bb19

bb6:                                              ; preds = %bb16, %bb4
  br i1 %c.2, label %bb7, label %bb8

bb7:                                              ; preds = %bb6
  br label %bb16

bb8:                                              ; preds = %bb11, %bb6
  %tmp9 = phi i64 [ %tmp12, %bb11 ], [ 0, %bb6 ]
  %tmp10 = icmp sle i64 %tmp9, 1
  br i1 %tmp10, label %bb11, label %bb13

bb11:                                             ; preds = %bb8
  %tmp12 = add nsw i64 %tmp9, 1
  br label %bb8

bb13:                                             ; preds = %bb8
  br i1 true, label %bb14, label %bb15

bb14:                                             ; preds = %bb13
  br label %bb16

bb15:                                             ; preds = %bb13
  br label %bb16

bb16:                                             ; preds = %bb15, %bb14, %bb7
  %tmp17 = phi i32 [ undef, %bb15 ], [ 1, %bb14 ], [ 9, %bb7 ]
  switch i32 %tmp17, label %bb19 [
  i32 0, label %bb6
  i32 9, label %bb18
  ]

bb18:                                             ; preds = %bb16
  br label %bb19

bb19:                                             ; preds = %bb18, %bb16, %bb5
  %tmp20 = phi i32 [ 0, %bb18 ], [ %tmp17, %bb16 ], [ 1, %bb5 ]
  %tmp21 = icmp eq i32 %tmp20, 0
  br i1 %tmp21, label %bb22, label %bb25

bb22:                                             ; preds = %bb19
  %tmp23 = add nsw i32 %tmp, 1
  br label %bb2

bb24:                                             ; preds = %bb2
  br label %bb25

bb25:                                             ; preds = %bb24, %bb19
  %tmp26 = phi i32 [ %tmp20, %bb19 ], [ 0, %bb24 ]
  %tmp27 = icmp eq i32 %tmp26, 0
  br i1 %tmp27, label %bb1, label %bb28

bb28:                                             ; preds = %bb25
  ret void
}

define void @PR42557(i32 %tmp6, i1 %c.1, i1 %c.2) {
; CHECK-LABEL: @PR42557(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    br label [[BB1:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    [[TMP:%.*]] = phi i32 [ 0, [[BB:%.*]] ], [ [[TMP6:%.*]], [[BB1]] ]
; CHECK-NEXT:    br i1 [[C_1:%.*]], label [[BB2:%.*]], label [[BB1]]
; CHECK:       bb2:
; CHECK-NEXT:    br i1 [[C_2:%.*]], label [[BB16:%.*]], label [[BB11:%.*]]
; CHECK:       bb16:
; CHECK-NEXT:    [[TMP17:%.*]] = add i32 [[TMP]], 1
; CHECK-NEXT:    br label [[BB11]]
; CHECK:       bb11:
; CHECK-NEXT:    [[TMP12:%.*]] = phi i32 [ [[TMP17]], [[BB16]] ], [ 0, [[BB2]] ]
; CHECK-NEXT:    [[TMP13:%.*]] = icmp eq i32 [[TMP12]], 0
; CHECK-NEXT:    call void @use(i1 [[TMP13]])
; CHECK-NEXT:    [[TMP15:%.*]] = icmp ne i32 [[TMP]], 0
; CHECK-NEXT:    br i1 [[TMP15]], label [[BB18:%.*]], label [[BB19:%.*]]
; CHECK:       bb18:
; CHECK-NEXT:    br label [[BB19]]
; CHECK:       bb19:
; CHECK-NEXT:    [[PHIOFOPS:%.*]] = phi i1 [ [[TMP13]], [[BB11]] ], [ false, [[BB18]] ]
; CHECK-NEXT:    [[TMP20:%.*]] = phi i32 [ [[TMP12]], [[BB11]] ], [ 1, [[BB18]] ]
; CHECK-NEXT:    call void @use(i1 [[PHIOFOPS]])
; CHECK-NEXT:    ret void
;
bb:
  br label %bb1

bb1:                                              ; preds = %bb1, %bb
  %tmp = phi i32 [ 0, %bb ], [ %tmp6, %bb1 ]
  br i1 %c.1, label %bb2, label %bb1

bb2:                                              ; preds = %bb1
  br i1 %c.2, label %bb16, label %bb11

bb16:                                             ; preds = %bb2
  %tmp17 = add i32 %tmp, 1
  br label %bb11

bb11:                                             ; preds = %bb16, %bb2
  %tmp12 = phi i32 [ %tmp17, %bb16 ], [ 0, %bb2 ]
  %tmp13 = icmp eq i32 %tmp12, 0
  call void @use(i1 %tmp13)
  %tmp15 = icmp ne i32 %tmp, 0
  br i1 %tmp15, label %bb18, label %bb19

bb18:                                             ; preds = %bb11
  br label %bb19

bb19:                                             ; preds = %bb18, %bb11
  %tmp20 = phi i32 [ %tmp12, %bb11 ], [ 1, %bb18 ]
  %tmp21 = icmp eq i32 %tmp20, 0
  call void @use(i1 %tmp21)
  ret void
}
