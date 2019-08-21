module Steel.Pointer.Views

open FStar.HyperStack.ST
module A = LowStar.Array
module HS = FStar.HyperStack
module HST = FStar.HyperStack.ST
module Seq = FStar.Seq
module P = LowStar.Permissions

open Steel.Resource
open Steel.RST

open LowStar.BufferOps

(* View and resource for (heap-allocated, freeable) pointer resources *)

unfold let pointer (t: Type) = ptr:A.array t{A.vlength ptr = 1}

noeq type vptr (a: Type) = {
  x: a;
  p: Ghost.erased P.permission
}

abstract
let ptr_view (#a:Type) (ptr:pointer a) : view (vptr a) =
  reveal_view ();
  let fp (h: HS.mem) = A.loc_array ptr in
  let inv (h: HS.mem): prop = A.live h ptr /\ A.vlength ptr = 1 in
  let sel h = {x = Seq.index (A.as_seq h ptr) 0; p = Ghost.hide (A.get_perm h ptr 0)} in
  {
    fp = fp;
    inv = inv;
    sel = sel
  }

let ptr_resource (#a:Type) (ptr:pointer a) =
  as_resource (ptr_view ptr)

let reveal_ptr ()
  : Lemma ((forall a (ptr:pointer a) h .{:pattern as_loc (fp (ptr_resource ptr)) h}
             as_loc (fp (ptr_resource ptr)) h == A.loc_array ptr) /\
           (forall a (ptr:pointer a) h .{:pattern inv (ptr_resource ptr) h}
             inv (ptr_resource ptr) h <==> A.live h ptr /\ A.vlength ptr = 1) /\
           (forall a (ptr:pointer a) h .{:pattern sel (ptr_view ptr) h}
             sel (ptr_view ptr) h == { x = Seq.index (A.as_seq h ptr) 0; p = Ghost.hide (A.get_perm h ptr 0)})) =
  ()

let get
  (#a: Type)
  (ptr: pointer a)
  (#r: resource{ptr_resource #a ptr `is_subresource_of` r})
  (h: rmem r) : GTot a =
  (h (ptr_resource ptr)).x

let get_perm
  (#a: Type)
  (ptr: pointer a)
  (#r: resource{ptr_resource #a ptr `is_subresource_of` r})
  (h: rmem r) : GTot P.permission =
  Ghost.reveal (h (ptr_resource ptr)).p