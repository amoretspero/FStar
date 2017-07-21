module FStar.SnapshotHyperStack.ST

open FStar.SnapshotHyperStack

module HH = FStar.HyperHeap
module HS = FStar.HyperStack

type mem = snapshot_heap

let st_pre = st_pre_h mem
let st_post (a:Type) = st_post_h mem a
let st_wp (a:Type) = st_wp_h mem a

private new_effect STATE = STATE_h mem

(* effect State (a:Type) (wp:st_wp a) = *)
(*        STATE a wp *)

(**
    WARNING: this effect is unsafe, for C/C++ extraction it shall only be used by
    code that would later extract to OCaml or by library functions
    *)
effect Unsafe (a:Type) (pre:st_pre) (post: (mem -> Tot (st_post a))) =
       STATE a
             (fun (p:st_post a) (h:mem) -> pre h /\ (forall a h1. pre h /\ post h a h1 ==> p a h1)) (* WP *)

(**
   Effect of stacked based code: the 'equal_domains' clause enforces that
   - both mem have the same tip
   - both mem reference the same heaps (their map: rid -> heap have the same domain)
   - in each region id, the corresponding heaps contain the same references on both sides
 *)
effect Stack (a:Type) (pre:st_pre) (post: (mem -> Tot (st_post a))) =
       STATE a
             (fun (p:st_post a) (h:mem) -> pre h /\ (forall a h1. (pre h /\ post h a h1 /\ equal_domains h h1) ==> p a h1)) (* WP *)

(**
   Effect of heap-based code.
   - assumes that the stack is empty (tip = root)
   - corresponds to the HyperHeap ST effect
   - can call to Stack and ST code freely
   - respects the stack invariant: the stack has to be empty when returning
*)
effect Heap (a:Type) (pre:st_pre) (post: (mem -> Tot (st_post a))) =
       STATE a
             (fun (p:st_post a) (h:mem) -> pre h /\ (forall a h1. (pre h /\ post h a h1 /\ tip h = HH.root /\ tip h1 = HH.root ) ==> p a h1)) (* WP *)

(**
  Effect of low-level code:
  - maintains the allocation invariant on the stack: no allocation unless in a new frame that has to be popped before returning
  - not constraints on heap allocation
*)
effect ST (a:Type) (pre:st_pre) (post: (mem -> Tot (st_post a))) =
       STATE a
             (fun (p:st_post a) (h:mem) -> pre h /\ (forall a h1. (pre h /\ post h a h1 /\ equal_stack_domains h h1) ==> p a h1)) (* WP *)

effect St (a:Type) = ST a (fun _ -> True) (fun _ _ _ -> True)

let inline_stack_inv h h' : GTot Type0 =
  (* The frame invariant is enforced *)
  tip h = tip h'
  (* The heap structure is unchanged *)
  /\ Map.domain (active_mem h).HS.h == Map.domain (active_mem h').HS.h
  (* Any region that is not the tip has no seen any allocation *)
  /\ (forall (r:HH.rid). {:pattern (Map.contains (active_mem h).HS.h r)} (r <> tip h /\ Map.contains (active_mem h).HS.h r)
       ==> Heap.equal_dom (Map.sel (active_mem h).HS.h r) (Map.sel (active_mem h').HS.h r))

(**
   Effect that indicates to the Kremlin compiler that allocation may occur in the caller's frame.
   In other terms, the backend has to unfold the body into the caller's body.
   This effect maintains the stack AND the heap invariant: it can be inlined in the Stack effect
   function body as well as in a Heap effect function body
   *)
effect StackInline (a:Type) (pre:st_pre) (post: (mem -> Tot (st_post a))) =
       STATE a
             (fun (p:st_post a) (h:mem) -> pre h /\ HS.is_stack_region (tip h) /\ (forall a h1. (pre h /\ post h a h1 /\ inline_stack_inv h h1) ==> p a h1)) (* WP *)

let inline_inv h h' : GTot Type0 =
  (* The stack invariant is enforced *)
  tip h = tip h'
  (* No frame may have received an allocation but the tip *)
  /\ (forall (r:HH.rid). {:pattern (HS.is_stack_region r)}(HS.is_stack_region r /\ r `HS.is_strictly_above` (tip h))
       ==> Heap.equal_dom (Map.sel (active_mem h).HS.h r) (Map.sel (active_mem h').HS.h r))

(**
   Effect that indicates to the Kremlin compiler that allocation may occur in the caller's frame.
   In other terms, the backend has to unfold the body into the caller's body.
   This effect only maintains the stack invariant: the tip is left unchanged and no allocation
   may occurs in the stack lower than the tip.
   Region allocation is not constrained.
   Heap allocation is not constrained.
   *)
effect Inline (a:Type) (pre:st_pre) (post: (mem -> Tot (st_post a))) =
       STATE a
             (fun (p:st_post a) (h:mem) -> pre h /\ (forall a h1. (pre h /\ post h a h1 /\ inline_inv h h1) ==> p a h1)) (* WP *)

(**
    TODO:
    REMOVE AS SOON AS CONSENSUS IS REACHED ON NEW LOW EFFECT NAMES
  *)
effect STL (a:Type) (pre:st_pre) (post: (mem -> Tot (st_post a))) = Stack a pre post

sub_effect
  DIV   ~> STATE = fun (a:Type) (wp:pure_wp a) (p:st_post a) (h:mem) -> wp (fun a -> p a h)

(**
   Pushes a new empty frame on the stack
   *)
assume val push_frame: unit -> Unsafe unit
  (requires (fun m -> True))
  (ensures (fun (m0:mem) _ (m1:mem) -> fresh_frame m0 m1))

(**
   Removes old frame from the stack
   *)
assume val pop_frame: unit -> Unsafe unit
  (requires (fun m -> poppable m))
  (ensures (fun (m0:mem) _ (m1:mem) -> poppable m0 /\ m1==pop m0 /\ popped m0 m1))

let salloc_post (#a:Type) (init:a) (m0:mem) (s:HS.reference a{HS.is_stack_region s.HS.id}) (m1:mem) =
      HS.is_stack_region (tip m0)
    /\ Map.domain (heap m0) == Map.domain (heap m1)
    /\ tip m0 = tip m1
    /\ s.HS.id   = tip m1
    /\ HH.fresh_rref s.HS.ref (heap m0) (heap m1)         //it's a fresh reference in the top fram
    /\ m1== upd m0 s init          //and it's been initialized

(**
     Allocates on the top-most stack frame
     *)
assume val salloc: #a:Type -> init:a -> StackInline (HS.stackref a)
  (requires (fun m -> HS.is_stack_region (tip m)))
  (ensures salloc_post init)

assume val salloc_mm: #a:Type -> init:a -> StackInline (HS.mmstackref a)
  (requires (fun m -> HS.is_stack_region (tip m)))
  (ensures salloc_post init)

assume val sfree: #a:Type -> r:HS.mmstackref a -> StackInline unit
    (requires (fun m0 -> r.HS.id = (tip m0) /\ m0 `contains` r))
    (ensures (fun m0 _ m1 -> m0 `contains` r /\ m1 == remove_reference r m0))

let fresh_region (r:HH.rid) (m0:mem) (m1:mem) =
  not (r `HS.is_in` (heap m0))
  /\ r `HS.is_in` (heap m1)

(*
 * AR: using this in mitls code, so that it corresponds to the
 * fresh_region definition in hyperheap.
 *)
let stronger_fresh_region (r:HH.rid) (m0:mem) (m1:mem) =
   (forall j. HH.includes r j ==> not (j `HS.is_in` (heap m0)))
   /\ r `HS.is_in` (heap m1)

assume val new_region: r0:HH.rid -> ST HH.rid
      (requires (fun m -> HS.is_eternal_region r0))
      (ensures (fun (m0:mem) (r1:HH.rid) (m1:mem) ->
                           r1 `HH.extends` r0
                        /\ HH.fresh_region r1 (heap m0) (heap m1)
			/\ HH.color r1 = HH.color r0
			/\ (heap m1) == Map.upd (heap m0) r1 Heap.emp
			/\ (tip m1) = (tip m0)
			))

let is_eternal_color = HS.is_eternal_color

assume val new_colored_region: r0:HH.rid -> c:int -> ST HH.rid
      (requires (fun m -> is_eternal_color c /\ HS.is_eternal_region r0))
      (ensures (fun (m0:mem) (r1:HH.rid) (m1:mem) ->
                           r1 `HH.extends` r0
                        /\ HH.fresh_region r1 (heap m0) (heap m1)
			/\ HH.color r1 = c
			/\ (heap m1) == Map.upd (heap m0) r1 Heap.emp
			/\ (tip m1) = (tip m0)
			))
// Clean up to use projections, tweak projections to fire with SMTPat - Jared.
unfold let ralloc_post (#a:Type) (i:HH.rid) (init:a) (m0:mem) (x:HS.reference a{HS.is_eternal_region x.HS.id}) (m1:mem) =
    let region_i = Map.sel (active_mem m0).HS.h i in
    (HH.as_ref x.HS.ref) `Heap.unused_in` region_i
  /\ i `HS.is_in` (active_mem m0).HS.h
  /\ i = x.HS.id
  /\ (active_mem m0) == HS.upd (active_mem m0) x init

assume val ralloc: #a:Type -> i:HH.rid -> init:a -> ST (HS.ref a)
    (requires (fun m -> HS.is_eternal_region i))
    (ensures (ralloc_post i init))

assume val ralloc_mm: #a:Type -> i:HH.rid -> init:a -> ST (HS.mmref a)
    (requires (fun _ -> HS.is_eternal_region i))
    (ensures (ralloc_post i init))

assume val rfree: #a:Type -> r:HS.mmref a -> ST unit
    (requires (fun m0 -> m0 `contains` r))
    (ensures (fun m0 _ m1 -> m0 `contains` r /\ m1 == remove_reference r m0))

unfold let assign_post (#a:Type) (r:HS.reference a) (v:a) m0 (_u:unit) m1 =
  m0 `contains` r /\ m1 == upd m0 r v

(**
   Assigns, provided that the reference exists.
   Guaranties the strongest low-level effect: Stack
   *)
assume val op_Colon_Equals: #a:Type -> r:HS.reference a -> v:a -> STL unit
  (requires (fun m -> m `contains` r))
  (ensures (assign_post r v))

unfold let deref_post (#a:Type) (r:HS.reference a) m0 x m1 =
  m1== m0 /\ x == sel m0 r

(**
   Dereferences, provided that the reference exists.
   Guaranties the strongest low-level effect: Stack
   *)
(*
 * AR: making the precondition as weak_contains.

 *)
assume val op_Bang: #a:Type -> r:HS.reference a -> Stack a
  (requires (fun m -> m `weak_contains` r))
  (ensures (deref_post r))

// let modifies_none (h0:mem) (h1:mem) = modifies Set.empty h0 h1

module G = FStar.Ghost

//   NS: This version is just fine; all the operation on mem are ghost
//       and we can rig it so that mem just get erased at the end
(**
    Returns the current stack of heaps --- it should be erased
    *)
assume val get: unit -> Stack mem
  (requires (fun m -> True))
  (ensures (fun m0 x m1 -> m0==x /\ m1==m0))

(**
   We can only recall refs with mm bit unset, not stack refs
   *)
assume val recall: #a:Type -> r:HS.ref a -> Stack unit
  (requires (fun m -> True))
  (ensures (fun m0 _ m1 -> m0==m1 /\ m1 `contains` r))

(**
   We can only recall eternal regions, not stack regions
   *)
assume val recall_region: i:HH.rid{HS.is_eternal_region i} -> Stack unit
  (requires (fun m -> True))
  (ensures (fun m0 _ m1 -> m0==m1 /\ i `HS.is_in` (heap m1)))

(* Tests *)
val test_do_nothing: int -> Stack int
  (requires (fun h -> True))
  (ensures (fun h _ h1 -> True))
let test_do_nothing x =
  push_frame();
  pop_frame ();
  x

val test_do_something: s:HS.stackref int -> Stack int
  (requires (fun h -> contains h s))
  (ensures (fun h r h1 -> contains h s /\ r = sel h s))
let test_do_something x =
  push_frame();
  let res = !x in
  pop_frame ();
  res

val test_do_something_else: s:HS.stackref int -> v:int -> Stack unit
  (requires (fun h -> contains h s))
  (ensures (fun h r h1 -> contains h1 s /\ v = sel h1 s))
let test_do_something_else x v =
  push_frame();
  x := v;
  pop_frame ()

val test_allocate: unit -> Stack unit (requires (fun _ -> True)) (ensures (fun _ _ _ -> True))
let test_allocate () =
  push_frame();
  let x = salloc 1 in
  x := 2;
  pop_frame ()

val test_nested_stl: unit -> Stack unit (requires (fun _ -> True)) (ensures (fun _ _ _ -> True))
let test_nested_stl () =
  let x = test_do_nothing 0 in ()

val test_nested_stl2: unit -> Stack unit (requires (fun _ -> True)) (ensures (fun _ _ _ -> True))
let test_nested_stl2 () =
  push_frame ();
  let x = test_do_nothing 0 in
  pop_frame ()

(* Testing mix of Heap and Stack code *)
val test_stack: int -> Stack int
  (requires (fun h -> True))
  (ensures (fun h _ h1 -> modifies Set.empty h h1))
let test_stack x =
  push_frame();
  let s = salloc x in
  s := (1 + x);
  pop_frame ();
  x

val test_stack_with_long_lived: s:HS.reference int -> Stack unit
  (requires (fun h -> contains h s))
  (ensures  (fun h0 _ h1 -> contains h1 s /\ sel h1 s = (sel h0 s) + 1
    /\ modifies (Set.singleton s.HS.id) h0 h1))
let test_stack_with_long_lived s =
  push_frame();
  let _ = test_stack !s in
  s := !s + 1;
  pop_frame()

val test_heap_code_with_stack_calls: unit -> Heap unit
  (requires (fun h -> heap_only h))
  (ensures  (fun h0 _ h1 -> modifies_transitively (Set.singleton (tip h0)) h0 h1 ))
let test_heap_code_with_stack_calls () =
  let h = get () in
  // How is the following not known ?
  HH.root_has_color_zero ();
  let s = ralloc (tip h) 0 in
  test_stack_with_long_lived s;
  s := 1;
  ()

val test_heap_code_with_stack_calls_and_regions: unit -> Heap unit
  (requires (fun h -> heap_only h))
  (ensures  (fun h0 _ h1 -> modifies_transitively (Set.singleton (tip h0)) h0 h1 ))
let test_heap_code_with_stack_calls_and_regions () =
  let h = get() in
  let color = 0 in
  HH.root_has_color_zero ();
  let new_region = new_colored_region (tip h) color in
  let s = ralloc new_region 1 in
  test_stack_with_long_lived s; // STStack call
  test_heap_code_with_stack_calls (); // STHeap call
  ()

val test_lax_code_with_stack_calls_and_regions: unit -> ST unit
  (requires (fun h -> True))
  (ensures  (fun h0 _ h1 -> modifies_transitively (Set.singleton HH.root) h0 h1 ))
let test_lax_code_with_stack_calls_and_regions () =
  push_frame();
  let color = 0 in
  HH.root_has_color_zero ();
  let new_region = new_colored_region HH.root color in
  let s = ralloc new_region 1 in
  test_stack_with_long_lived s; // Stack call
  pop_frame()

val test_lax_code_with_stack_calls_and_regions_2: unit -> ST unit
  (requires (fun h -> True))
  (ensures  (fun h0 _ h1 -> modifies_transitively (Set.singleton HH.root) h0 h1 ))
let test_lax_code_with_stack_calls_and_regions_2 () =
  push_frame();
  let color = 0 in
  HH.root_has_color_zero ();
  let new_region = new_colored_region HH.root color in
  let s = ralloc new_region 1 in
  test_stack_with_long_lived s; // Stack call
  test_lax_code_with_stack_calls_and_regions (); // ST call
  pop_frame()

val test_to_be_stack_inlined: unit -> StackInline (HS.reference int)
  (requires (fun h -> HS.is_stack_region (tip h)))
  (ensures  (fun h0 r h1 -> ~(contains h0 r) /\ contains h1 r /\ sel h1 r = 2))
let test_to_be_stack_inlined () =
  let r = salloc 0 in
  r := 2;
  r

val test_stack_function_with_inline: unit -> Stack int
  (requires (fun h -> True))
  (ensures  (fun h0 _ h1 -> True))
let test_stack_function_with_inline () =
  push_frame();
  let x = test_to_be_stack_inlined () in
  let y = !x + !x in
  pop_frame();
  y

val test_st_function_with_inline: unit -> ST unit
  (requires (fun h -> True))
  (ensures  (fun h0 _ h1 -> True))
let test_st_function_with_inline () =
  push_frame();
  let x = test_to_be_stack_inlined () in
  let y = !x + !x in
  pop_frame();
  ()

val test_to_be_inlined: unit -> Inline (HS.reference int * HS.reference int)
  (requires (fun h -> HS.is_stack_region (tip h)))
  (ensures  (fun h0 r h1 -> True))
let test_to_be_inlined () =
  let r = salloc 0 in
  HH.root_has_color_zero ();
  let region = new_region HH.root in
  let r' = ralloc region 1 in
  r := 2;
  r' := 3;
  r,r'

val test_st_function_with_inline_2: unit -> ST unit
  (requires (fun h -> True))
  (ensures  (fun h0 _ h1 -> True))
let test_st_function_with_inline_2 () =
  push_frame();
  let x = test_to_be_stack_inlined () in
  let r, r' = test_to_be_inlined () in
  pop_frame();
  ()

val with_frame: #a:Type -> #pre:st_pre -> #post:(mem -> Tot (st_post a)) -> $f:(unit -> Stack a pre post)
	     -> Stack a (fun s0 -> forall s1. fresh_frame s0 s1 ==> pre s1)
		     (fun s0 x s1 ->
			exists s0' s1'. fresh_frame s0 s0'
			         /\ poppable s0'
				 /\ post s0' x s1'
				 /\ equal_domains s0' s1'
				 /\ s1 == pop s1')
let with_frame #a #pre #post f =
  push_frame();
  let x = f() in
  pop_frame();
  x

let test_with_frame (x:HS.stackref int) (v:int)
  : Stack unit (requires (fun m -> contains m x))
	     (ensures (fun m0 _ m1 -> modifies (Set.singleton x.HS.id) m0 m1 /\ sel m1 x = v))
 = with_frame (fun _ -> x := v)

let as_requires (#a:Type) (wp:st_wp a) = wp (fun x s -> True)
let as_ensures (#a:Type) (wp:st_wp a) = fun s0 x s1 -> wp (fun y s1' -> y=!=x \/ s1=!=s1') s0

assume val as_stack: #a:Type -> #wp:st_wp a -> $f:(unit -> STATE a wp) ->
	   Pure (unit -> Stack a (as_requires wp)
			      (as_ensures wp))
	        (requires (forall s0 x s1. as_ensures wp s0 x s1 ==> equal_domains s0 s1))
 	        (ensures (fun x -> True))

val mm_tests: unit -> Unsafe unit (requires (fun _ -> True)) (ensures (fun _ _ _ -> True))
let mm_tests _ =
  let _ = push_frame () in

  let r1 = salloc_mm 2 in

  //check that the heap contains the reference
  let m = get () in
  let h = Map.sel (heap m) (tip m) in
  let _ = assert (Heap.contains h (HH.as_ref r1.HS.ref)) in

  let _ = !r1 in

  let _ = sfree r1 in

  //this fails because the ref has been freed
  //let _ = !r1 in

  //check that the heap does not contain the reference
  let m = get () in
  let h = Map.sel (heap m) (tip m) in
  let _ = assert (~ (Heap.contains h (HH.as_ref r1.HS.ref))) in

  let r2 = salloc_mm 2 in
  let _ = pop_frame () in

  //this fails because the reference is no longer live
  //let _ = sfree r2 in

  let id = new_region HH.root in

  let r3 = ralloc_mm id 2 in
  let _ = !r3 in
  let _ = rfree r3 in

  //check that the heap does not contain the reference
  let m = get () in
  let h = Map.sel (heap m) id in
  let _ = assert (~ (Heap.contains h (HH.as_ref r3.HS.ref))) in

  //this fails because the reference is no longer live
  //let _ = !r3 in

  //this fails because recall of mm refs is not allowed
  //let _ = recall r3 in
  ()
