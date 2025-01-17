; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=simplifycfg -simplifycfg-require-and-preserve-domtree=1 -phi-node-folding-threshold=2 -S | FileCheck %s

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define i32 @test1(i32 %a, i32 %b, i32 %c) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[T1:%.*]] = icmp eq i32 [[B:%.*]], 0
; CHECK-NEXT:    [[T2:%.*]] = icmp sgt i32 [[C:%.*]], 1
; CHECK-NEXT:    [[T4_SEL:%.*]] = select i1 [[T1]], i32 [[A:%.*]], i32 [[B]]
; CHECK-NEXT:    [[OR_COND:%.*]] = select i1 [[T1]], i1 [[T2]], i1 false
; CHECK-NEXT:    [[T3:%.*]] = add i32 [[A]], 1
; CHECK-NEXT:    [[T4:%.*]] = select i1 [[OR_COND]], i32 [[T3]], i32 [[T4_SEL]]
; CHECK-NEXT:    [[T5:%.*]] = sub i32 [[T4]], 1
; CHECK-NEXT:    ret i32 [[T5]]
;
entry:
  %t1 = icmp eq i32 %b, 0
  br i1 %t1, label %bb1, label %bb3

bb1:
  %t2 = icmp sgt i32 %c, 1
  br i1 %t2, label %bb2, label %bb3

bb2:
  %t3 = add i32 %a, 1
  br label %bb3

bb3:
  %t4 = phi i32 [ %b, %entry ], [ %a, %bb1 ], [ %t3, %bb2 ]
  %t5 = sub i32 %t4, 1
  ret i32 %t5
}

define float @spec_select_fp1(float %a, float %b, float %c) {
; CHECK-LABEL: @spec_select_fp1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[T1:%.*]] = fcmp oeq float [[B:%.*]], 0.000000e+00
; CHECK-NEXT:    [[T2:%.*]] = fcmp ogt float [[C:%.*]], 1.000000e+00
; CHECK-NEXT:    [[T4_SEL:%.*]] = select i1 [[T1]], float [[A:%.*]], float [[B]]
; CHECK-NEXT:    [[OR_COND:%.*]] = select i1 [[T1]], i1 [[T2]], i1 false
; CHECK-NEXT:    [[T3:%.*]] = fadd float [[A]], 1.000000e+00
; CHECK-NEXT:    [[T4:%.*]] = select ninf i1 [[OR_COND]], float [[T3]], float [[T4_SEL]]
; CHECK-NEXT:    [[T5:%.*]] = fsub float [[T4]], 1.000000e+00
; CHECK-NEXT:    ret float [[T5]]
;
entry:
  %t1 = fcmp oeq float %b, 0.0
  br i1 %t1, label %bb1, label %bb3

bb1:
  %t2 = fcmp ogt float %c, 1.0
  br i1 %t2, label %bb2, label %bb3

bb2:
  %t3 = fadd float %a, 1.0
  br label %bb3

bb3:
  %t4 = phi ninf float [ %b, %entry ], [ %a, %bb1 ], [ %t3, %bb2 ]
  %t5 = fsub float %t4, 1.0
  ret float %t5
}

define i8* @test4(i1* %dummy, i8* %a, i8* %b) {
; Test that we don't speculate an arbitrarily large number of unfolded constant
; expressions.
; CHECK-LABEL: @test4(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[COND1:%.*]] = load volatile i1, i1* [[DUMMY:%.*]], align 1
; CHECK-NEXT:    br i1 [[COND1]], label [[IF:%.*]], label [[END:%.*]]
; CHECK:       if:
; CHECK-NEXT:    [[COND2:%.*]] = load volatile i1, i1* [[DUMMY]], align 1
; CHECK-NEXT:    br i1 [[COND2]], label [[THEN:%.*]], label [[END]]
; CHECK:       then:
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    [[X1:%.*]] = phi i8* [ [[A:%.*]], [[ENTRY:%.*]] ], [ [[B:%.*]], [[IF]] ], [ inttoptr (i64 1 to i8*), [[THEN]] ]
; CHECK-NEXT:    [[X2:%.*]] = phi i8* [ [[A]], [[ENTRY]] ], [ [[B]], [[IF]] ], [ inttoptr (i64 2 to i8*), [[THEN]] ]
; CHECK-NEXT:    [[X3:%.*]] = phi i8* [ [[A]], [[ENTRY]] ], [ [[B]], [[IF]] ], [ inttoptr (i64 3 to i8*), [[THEN]] ]
; CHECK-NEXT:    [[X4:%.*]] = phi i8* [ [[A]], [[ENTRY]] ], [ [[B]], [[IF]] ], [ inttoptr (i64 4 to i8*), [[THEN]] ]
; CHECK-NEXT:    [[X5:%.*]] = phi i8* [ [[A]], [[ENTRY]] ], [ [[B]], [[IF]] ], [ inttoptr (i64 5 to i8*), [[THEN]] ]
; CHECK-NEXT:    [[X6:%.*]] = phi i8* [ [[A]], [[ENTRY]] ], [ [[B]], [[IF]] ], [ inttoptr (i64 6 to i8*), [[THEN]] ]
; CHECK-NEXT:    [[X7:%.*]] = phi i8* [ [[A]], [[ENTRY]] ], [ [[B]], [[IF]] ], [ inttoptr (i64 7 to i8*), [[THEN]] ]
; CHECK-NEXT:    [[X8:%.*]] = phi i8* [ [[A]], [[ENTRY]] ], [ [[B]], [[IF]] ], [ inttoptr (i64 8 to i8*), [[THEN]] ]
; CHECK-NEXT:    [[X9:%.*]] = phi i8* [ [[A]], [[ENTRY]] ], [ [[B]], [[IF]] ], [ inttoptr (i64 9 to i8*), [[THEN]] ]
; CHECK-NEXT:    [[X10:%.*]] = phi i8* [ [[A]], [[ENTRY]] ], [ [[B]], [[IF]] ], [ inttoptr (i64 10 to i8*), [[THEN]] ]
; CHECK-NEXT:    ret i8* [[X10]]
;

entry:
  %cond1 = load volatile i1, i1* %dummy
  br i1 %cond1, label %if, label %end

if:
  %cond2 = load volatile i1, i1* %dummy
  br i1 %cond2, label %then, label %end

then:
  br label %end

end:
  %x1 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 1 to i8*), %then ]
  %x2 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 2 to i8*), %then ]
  %x3 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 3 to i8*), %then ]
  %x4 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 4 to i8*), %then ]
  %x5 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 5 to i8*), %then ]
  %x6 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 6 to i8*), %then ]
  %x7 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 7 to i8*), %then ]
  %x8 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 8 to i8*), %then ]
  %x9 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 9 to i8*), %then ]
  %x10 = phi i8* [ %a, %entry ], [ %b, %if ], [ inttoptr (i64 10 to i8*), %then ]

  ret i8* %x10
}

define i32* @test5(i32 %a, i32 %b, i32 %c, i32* dereferenceable(10) %ptr1, i32* dereferenceable(10) %ptr2, i32** dereferenceable(10) align 8 %ptr3) nofree nosync {
; CHECK-LABEL: @test5(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[T1:%.*]] = icmp eq i32 [[B:%.*]], 0
; CHECK-NEXT:    [[T2:%.*]] = icmp sgt i32 [[C:%.*]], 1
; CHECK-NEXT:    [[T4_SEL:%.*]] = select i1 [[T1]], i32* [[PTR2:%.*]], i32* [[PTR1:%.*]]
; CHECK-NEXT:    [[OR_COND:%.*]] = select i1 [[T1]], i1 [[T2]], i1 false
; CHECK-NEXT:    [[T3:%.*]] = load i32*, i32** [[PTR3:%.*]], align 8
; CHECK-NEXT:    [[T4:%.*]] = select i1 [[OR_COND]], i32* [[T3]], i32* [[T4_SEL]]
; CHECK-NEXT:    ret i32* [[T4]]
;
entry:
  %t1 = icmp eq i32 %b, 0
  br i1 %t1, label %bb1, label %bb3

bb1:
  %t2 = icmp sgt i32 %c, 1
  br i1 %t2, label %bb2, label %bb3

bb2:
  %t3 = load i32*, i32** %ptr3, !dereferenceable !{i64 10}
  br label %bb3

bb3:
  %t4 = phi i32* [ %ptr1, %entry ], [ %ptr2, %bb1 ], [ %t3, %bb2 ]
  ret i32* %t4
}

define float @spec_select_fp5(float %a, float %b, float %c) {
; CHECK-LABEL: @spec_select_fp5(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[T1:%.*]] = fcmp oeq float [[B:%.*]], 0.000000e+00
; CHECK-NEXT:    [[T2:%.*]] = fcmp ogt float [[C:%.*]], 1.000000e+00
; CHECK-NEXT:    [[T4_SEL:%.*]] = select i1 [[T1]], float [[B]], float [[A:%.*]]
; CHECK-NEXT:    [[OR_COND:%.*]] = select i1 [[T1]], i1 [[T2]], i1 false
; CHECK-NEXT:    [[T4:%.*]] = select nsz i1 [[OR_COND]], float [[C]], float [[T4_SEL]]
; CHECK-NEXT:    ret float [[T4]]
;
entry:
  %t1 = fcmp oeq float %b, 0.0
  br i1 %t1, label %bb1, label %bb3

bb1:
  %t2 = fcmp ogt float %c, 1.0
  br i1 %t2, label %bb2, label %bb3

bb2:
  br label %bb3

bb3:
  %t4 = phi nsz float [ %a, %entry ], [ %b, %bb1 ], [ %c, %bb2 ]
  ret float %t4
}
