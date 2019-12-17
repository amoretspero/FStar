open Prims
let rec (delta_depth_to_string :
  FStar_Syntax_Syntax.delta_depth -> Prims.string) =
  fun uu___0_5  ->
    match uu___0_5 with
    | FStar_Syntax_Syntax.Delta_constant_at_level i ->
        let uu____9 = FStar_Util.string_of_int i  in
        Prims.op_Hat "Delta_constant_at_level " uu____9
    | FStar_Syntax_Syntax.Delta_equational_at_level i ->
        let uu____14 = FStar_Util.string_of_int i  in
        Prims.op_Hat "Delta_equational_at_level " uu____14
    | FStar_Syntax_Syntax.Delta_abstract d ->
        let uu____18 =
          let uu____20 = delta_depth_to_string d  in
          Prims.op_Hat uu____20 ")"  in
        Prims.op_Hat "Delta_abstract (" uu____18
  
let (sli : FStar_Ident.lident -> Prims.string) =
  fun l  ->
    let uu____32 = FStar_Options.print_real_names ()  in
    if uu____32
    then l.FStar_Ident.str
    else (l.FStar_Ident.ident).FStar_Ident.idText
  
let (lid_to_string : FStar_Ident.lid -> Prims.string) = fun l  -> sli l 
let (fv_to_string : FStar_Syntax_Syntax.fv -> Prims.string) =
  fun fv  ->
    lid_to_string (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
  
let (bv_to_string : FStar_Syntax_Syntax.bv -> Prims.string) =
  fun bv  ->
    let uu____59 =
      let uu____61 = FStar_Util.string_of_int bv.FStar_Syntax_Syntax.index
         in
      Prims.op_Hat "#" uu____61  in
    Prims.op_Hat (bv.FStar_Syntax_Syntax.ppname).FStar_Ident.idText uu____59
  
let (nm_to_string : FStar_Syntax_Syntax.bv -> Prims.string) =
  fun bv  ->
    let uu____71 = FStar_Options.print_real_names ()  in
    if uu____71
    then bv_to_string bv
    else (bv.FStar_Syntax_Syntax.ppname).FStar_Ident.idText
  
let (db_to_string : FStar_Syntax_Syntax.bv -> Prims.string) =
  fun bv  ->
    let uu____84 =
      let uu____86 = FStar_Util.string_of_int bv.FStar_Syntax_Syntax.index
         in
      Prims.op_Hat "@" uu____86  in
    Prims.op_Hat (bv.FStar_Syntax_Syntax.ppname).FStar_Ident.idText uu____84
  
let (infix_prim_ops : (FStar_Ident.lident * Prims.string) Prims.list) =
  [(FStar_Parser_Const.op_Addition, "+");
  (FStar_Parser_Const.op_Subtraction, "-");
  (FStar_Parser_Const.op_Multiply, "*");
  (FStar_Parser_Const.op_Division, "/");
  (FStar_Parser_Const.op_Eq, "=");
  (FStar_Parser_Const.op_ColonEq, ":=");
  (FStar_Parser_Const.op_notEq, "<>");
  (FStar_Parser_Const.op_And, "&&");
  (FStar_Parser_Const.op_Or, "||");
  (FStar_Parser_Const.op_LTE, "<=");
  (FStar_Parser_Const.op_GTE, ">=");
  (FStar_Parser_Const.op_LT, "<");
  (FStar_Parser_Const.op_GT, ">");
  (FStar_Parser_Const.op_Modulus, "mod");
  (FStar_Parser_Const.and_lid, "/\\");
  (FStar_Parser_Const.or_lid, "\\/");
  (FStar_Parser_Const.imp_lid, "==>");
  (FStar_Parser_Const.iff_lid, "<==>");
  (FStar_Parser_Const.precedes_lid, "<<");
  (FStar_Parser_Const.eq2_lid, "==");
  (FStar_Parser_Const.eq3_lid, "===")] 
let (unary_prim_ops : (FStar_Ident.lident * Prims.string) Prims.list) =
  [(FStar_Parser_Const.op_Negation, "not");
  (FStar_Parser_Const.op_Minus, "-");
  (FStar_Parser_Const.not_lid, "~")] 
let (is_prim_op :
  FStar_Ident.lident Prims.list ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax -> Prims.bool)
  =
  fun ps  ->
    fun f  ->
      match f.FStar_Syntax_Syntax.n with
      | FStar_Syntax_Syntax.Tm_fvar fv ->
          FStar_All.pipe_right ps
            (FStar_Util.for_some (FStar_Syntax_Syntax.fv_eq_lid fv))
      | uu____308 -> false
  
let (get_lid :
  FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax -> FStar_Ident.lident)
  =
  fun f  ->
    match f.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Tm_fvar fv ->
        (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
    | uu____321 -> failwith "get_lid"
  
let (is_infix_prim_op : FStar_Syntax_Syntax.term -> Prims.bool) =
  fun e  ->
    is_prim_op
      (FStar_Pervasives_Native.fst (FStar_List.split infix_prim_ops)) e
  
let (is_unary_prim_op : FStar_Syntax_Syntax.term -> Prims.bool) =
  fun e  ->
    is_prim_op
      (FStar_Pervasives_Native.fst (FStar_List.split unary_prim_ops)) e
  
let (quants : (FStar_Ident.lident * Prims.string) Prims.list) =
  [(FStar_Parser_Const.forall_lid, "forall");
  (FStar_Parser_Const.exists_lid, "exists")] 
type exp = FStar_Syntax_Syntax.term
let (is_b2t : FStar_Syntax_Syntax.typ -> Prims.bool) =
  fun t  -> is_prim_op [FStar_Parser_Const.b2t_lid] t 
let (is_quant : FStar_Syntax_Syntax.typ -> Prims.bool) =
  fun t  ->
    is_prim_op (FStar_Pervasives_Native.fst (FStar_List.split quants)) t
  
let (is_ite : FStar_Syntax_Syntax.typ -> Prims.bool) =
  fun t  -> is_prim_op [FStar_Parser_Const.ite_lid] t 
let (is_lex_cons : exp -> Prims.bool) =
  fun f  -> is_prim_op [FStar_Parser_Const.lexcons_lid] f 
let (is_lex_top : exp -> Prims.bool) =
  fun f  -> is_prim_op [FStar_Parser_Const.lextop_lid] f 
let is_inr :
  'Auu____424 'Auu____425 .
    ('Auu____424,'Auu____425) FStar_Util.either -> Prims.bool
  =
  fun uu___1_435  ->
    match uu___1_435 with
    | FStar_Util.Inl uu____440 -> false
    | FStar_Util.Inr uu____442 -> true
  
let filter_imp :
  'Auu____449 .
    ('Auu____449 * FStar_Syntax_Syntax.arg_qualifier
      FStar_Pervasives_Native.option) Prims.list ->
      ('Auu____449 * FStar_Syntax_Syntax.arg_qualifier
        FStar_Pervasives_Native.option) Prims.list
  =
  fun a  ->
    FStar_All.pipe_right a
      (FStar_List.filter
         (fun uu___2_504  ->
            match uu___2_504 with
            | (uu____512,FStar_Pervasives_Native.Some
               (FStar_Syntax_Syntax.Meta t)) when
                FStar_Syntax_Util.is_fvar FStar_Parser_Const.tcresolve_lid t
                -> true
            | (uu____519,FStar_Pervasives_Native.Some
               (FStar_Syntax_Syntax.Implicit uu____520)) -> false
            | (uu____525,FStar_Pervasives_Native.Some
               (FStar_Syntax_Syntax.Meta uu____526)) -> false
            | uu____532 -> true))
  
let rec (reconstruct_lex :
  exp -> exp Prims.list FStar_Pervasives_Native.option) =
  fun e  ->
    let uu____550 =
      let uu____551 = FStar_Syntax_Subst.compress e  in
      uu____551.FStar_Syntax_Syntax.n  in
    match uu____550 with
    | FStar_Syntax_Syntax.Tm_app (f,args) ->
        let args1 = filter_imp args  in
        let exps = FStar_List.map FStar_Pervasives_Native.fst args1  in
        let uu____612 =
          (is_lex_cons f) && ((FStar_List.length exps) = (Prims.of_int (2)))
           in
        if uu____612
        then
          let uu____621 =
            let uu____626 = FStar_List.nth exps Prims.int_one  in
            reconstruct_lex uu____626  in
          (match uu____621 with
           | FStar_Pervasives_Native.Some xs ->
               let uu____637 =
                 let uu____640 = FStar_List.nth exps Prims.int_zero  in
                 uu____640 :: xs  in
               FStar_Pervasives_Native.Some uu____637
           | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None)
        else FStar_Pervasives_Native.None
    | uu____652 ->
        let uu____653 = is_lex_top e  in
        if uu____653
        then FStar_Pervasives_Native.Some []
        else FStar_Pervasives_Native.None
  
let rec find : 'a . ('a -> Prims.bool) -> 'a Prims.list -> 'a =
  fun f  ->
    fun l  ->
      match l with
      | [] -> failwith "blah"
      | hd1::tl1 ->
          let uu____701 = f hd1  in if uu____701 then hd1 else find f tl1
  
let (find_lid :
  FStar_Ident.lident ->
    (FStar_Ident.lident * Prims.string) Prims.list -> Prims.string)
  =
  fun x  ->
    fun xs  ->
      let uu____733 =
        find
          (fun p  -> FStar_Ident.lid_equals x (FStar_Pervasives_Native.fst p))
          xs
         in
      FStar_Pervasives_Native.snd uu____733
  
let (infix_prim_op_to_string :
  FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax -> Prims.string) =
  fun e  -> let uu____764 = get_lid e  in find_lid uu____764 infix_prim_ops 
let (unary_prim_op_to_string :
  FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax -> Prims.string) =
  fun e  -> let uu____776 = get_lid e  in find_lid uu____776 unary_prim_ops 
let (quant_to_string :
  FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax -> Prims.string) =
  fun t  -> let uu____788 = get_lid t  in find_lid uu____788 quants 
let (const_to_string : FStar_Const.sconst -> Prims.string) =
  fun x  -> FStar_Parser_Const.const_to_string x 
let (lbname_to_string : FStar_Syntax_Syntax.lbname -> Prims.string) =
  fun uu___3_802  ->
    match uu___3_802 with
    | FStar_Util.Inl l -> bv_to_string l
    | FStar_Util.Inr l ->
        lid_to_string (l.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
  
let (uvar_to_string : FStar_Syntax_Syntax.uvar -> Prims.string) =
  fun u  ->
    let uu____813 = FStar_Options.hide_uvar_nums ()  in
    if uu____813
    then "?"
    else
      (let uu____820 =
         let uu____822 = FStar_Syntax_Unionfind.uvar_id u  in
         FStar_All.pipe_right uu____822 FStar_Util.string_of_int  in
       Prims.op_Hat "?" uu____820)
  
let (version_to_string : FStar_Syntax_Syntax.version -> Prims.string) =
  fun v1  ->
    let uu____834 = FStar_Util.string_of_int v1.FStar_Syntax_Syntax.major  in
    let uu____836 = FStar_Util.string_of_int v1.FStar_Syntax_Syntax.minor  in
    FStar_Util.format2 "%s.%s" uu____834 uu____836
  
let (univ_uvar_to_string :
  (FStar_Syntax_Syntax.universe FStar_Pervasives_Native.option
    FStar_Unionfind.p_uvar * FStar_Syntax_Syntax.version) -> Prims.string)
  =
  fun u  ->
    let uu____862 = FStar_Options.hide_uvar_nums ()  in
    if uu____862
    then "?"
    else
      (let uu____869 =
         let uu____871 =
           let uu____873 = FStar_Syntax_Unionfind.univ_uvar_id u  in
           FStar_All.pipe_right uu____873 FStar_Util.string_of_int  in
         let uu____877 =
           let uu____879 = version_to_string (FStar_Pervasives_Native.snd u)
              in
           Prims.op_Hat ":" uu____879  in
         Prims.op_Hat uu____871 uu____877  in
       Prims.op_Hat "?" uu____869)
  
let rec (int_of_univ :
  Prims.int ->
    FStar_Syntax_Syntax.universe ->
      (Prims.int * FStar_Syntax_Syntax.universe
        FStar_Pervasives_Native.option))
  =
  fun n1  ->
    fun u  ->
      let uu____907 = FStar_Syntax_Subst.compress_univ u  in
      match uu____907 with
      | FStar_Syntax_Syntax.U_zero  -> (n1, FStar_Pervasives_Native.None)
      | FStar_Syntax_Syntax.U_succ u1 -> int_of_univ (n1 + Prims.int_one) u1
      | uu____920 -> (n1, (FStar_Pervasives_Native.Some u))
  
let rec (univ_to_string : FStar_Syntax_Syntax.universe -> Prims.string) =
  fun u  ->
    let uu____931 = FStar_Syntax_Subst.compress_univ u  in
    match uu____931 with
    | FStar_Syntax_Syntax.U_unif u1 ->
        let uu____942 = univ_uvar_to_string u1  in
        Prims.op_Hat "U_unif " uu____942
    | FStar_Syntax_Syntax.U_name x ->
        Prims.op_Hat "U_name " x.FStar_Ident.idText
    | FStar_Syntax_Syntax.U_bvar x ->
        let uu____949 = FStar_Util.string_of_int x  in
        Prims.op_Hat "@" uu____949
    | FStar_Syntax_Syntax.U_zero  -> "0"
    | FStar_Syntax_Syntax.U_succ u1 ->
        let uu____954 = int_of_univ Prims.int_one u1  in
        (match uu____954 with
         | (n1,FStar_Pervasives_Native.None ) -> FStar_Util.string_of_int n1
         | (n1,FStar_Pervasives_Native.Some u2) ->
             let uu____975 = univ_to_string u2  in
             let uu____977 = FStar_Util.string_of_int n1  in
             FStar_Util.format2 "(%s + %s)" uu____975 uu____977)
    | FStar_Syntax_Syntax.U_max us ->
        let uu____983 =
          let uu____985 = FStar_List.map univ_to_string us  in
          FStar_All.pipe_right uu____985 (FStar_String.concat ", ")  in
        FStar_Util.format1 "(max %s)" uu____983
    | FStar_Syntax_Syntax.U_unknown  -> "unknown"
  
let (univs_to_string : FStar_Syntax_Syntax.universes -> Prims.string) =
  fun us  ->
    let uu____1004 = FStar_List.map univ_to_string us  in
    FStar_All.pipe_right uu____1004 (FStar_String.concat ", ")
  
let (univ_names_to_string : FStar_Syntax_Syntax.univ_names -> Prims.string) =
  fun us  ->
    let uu____1021 = FStar_List.map (fun x  -> x.FStar_Ident.idText) us  in
    FStar_All.pipe_right uu____1021 (FStar_String.concat ", ")
  
let (qual_to_string : FStar_Syntax_Syntax.qualifier -> Prims.string) =
  fun uu___4_1039  ->
    match uu___4_1039 with
    | FStar_Syntax_Syntax.Assumption  -> "assume"
    | FStar_Syntax_Syntax.New  -> "new"
    | FStar_Syntax_Syntax.Private  -> "private"
    | FStar_Syntax_Syntax.Unfold_for_unification_and_vcgen  -> "unfold"
    | FStar_Syntax_Syntax.Inline_for_extraction  -> "inline"
    | FStar_Syntax_Syntax.NoExtract  -> "noextract"
    | FStar_Syntax_Syntax.Visible_default  -> "visible"
    | FStar_Syntax_Syntax.Irreducible  -> "irreducible"
    | FStar_Syntax_Syntax.Abstract  -> "abstract"
    | FStar_Syntax_Syntax.Noeq  -> "noeq"
    | FStar_Syntax_Syntax.Unopteq  -> "unopteq"
    | FStar_Syntax_Syntax.Logic  -> "logic"
    | FStar_Syntax_Syntax.TotalEffect  -> "total"
    | FStar_Syntax_Syntax.Discriminator l ->
        let uu____1055 = lid_to_string l  in
        FStar_Util.format1 "(Discriminator %s)" uu____1055
    | FStar_Syntax_Syntax.Projector (l,x) ->
        let uu____1060 = lid_to_string l  in
        FStar_Util.format2 "(Projector %s %s)" uu____1060
          x.FStar_Ident.idText
    | FStar_Syntax_Syntax.RecordType (ns,fns) ->
        let uu____1073 =
          let uu____1075 = FStar_Ident.path_of_ns ns  in
          FStar_Ident.text_of_path uu____1075  in
        let uu____1076 =
          let uu____1078 =
            FStar_All.pipe_right fns (FStar_List.map FStar_Ident.text_of_id)
             in
          FStar_All.pipe_right uu____1078 (FStar_String.concat ", ")  in
        FStar_Util.format2 "(RecordType %s %s)" uu____1073 uu____1076
    | FStar_Syntax_Syntax.RecordConstructor (ns,fns) ->
        let uu____1104 =
          let uu____1106 = FStar_Ident.path_of_ns ns  in
          FStar_Ident.text_of_path uu____1106  in
        let uu____1107 =
          let uu____1109 =
            FStar_All.pipe_right fns (FStar_List.map FStar_Ident.text_of_id)
             in
          FStar_All.pipe_right uu____1109 (FStar_String.concat ", ")  in
        FStar_Util.format2 "(RecordConstructor %s %s)" uu____1104 uu____1107
    | FStar_Syntax_Syntax.Action eff_lid ->
        let uu____1126 = lid_to_string eff_lid  in
        FStar_Util.format1 "(Action %s)" uu____1126
    | FStar_Syntax_Syntax.ExceptionConstructor  -> "ExceptionConstructor"
    | FStar_Syntax_Syntax.HasMaskedEffect  -> "HasMaskedEffect"
    | FStar_Syntax_Syntax.Effect  -> "Effect"
    | FStar_Syntax_Syntax.Reifiable  -> "reify"
    | FStar_Syntax_Syntax.Reflectable l ->
        FStar_Util.format1 "(reflect %s)" l.FStar_Ident.str
    | FStar_Syntax_Syntax.OnlyName  -> "OnlyName"
  
let (quals_to_string :
  FStar_Syntax_Syntax.qualifier Prims.list -> Prims.string) =
  fun quals  ->
    match quals with
    | [] -> ""
    | uu____1149 ->
        let uu____1152 =
          FStar_All.pipe_right quals (FStar_List.map qual_to_string)  in
        FStar_All.pipe_right uu____1152 (FStar_String.concat " ")
  
let (quals_to_string' :
  FStar_Syntax_Syntax.qualifier Prims.list -> Prims.string) =
  fun quals  ->
    match quals with
    | [] -> ""
    | uu____1180 ->
        let uu____1183 = quals_to_string quals  in
        Prims.op_Hat uu____1183 " "
  
let (paren : Prims.string -> Prims.string) =
  fun s  -> Prims.op_Hat "(" (Prims.op_Hat s ")") 
let rec (tag_of_term : FStar_Syntax_Syntax.term -> Prims.string) =
  fun t  ->
    match t.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Tm_bvar x ->
        let uu____1365 = db_to_string x  in
        Prims.op_Hat "Tm_bvar: " uu____1365
    | FStar_Syntax_Syntax.Tm_name x ->
        let uu____1369 = nm_to_string x  in
        Prims.op_Hat "Tm_name: " uu____1369
    | FStar_Syntax_Syntax.Tm_fvar x ->
        let uu____1373 =
          lid_to_string (x.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
           in
        Prims.op_Hat "Tm_fvar: " uu____1373
    | FStar_Syntax_Syntax.Tm_uinst uu____1376 -> "Tm_uinst"
    | FStar_Syntax_Syntax.Tm_constant uu____1384 -> "Tm_constant"
    | FStar_Syntax_Syntax.Tm_type uu____1386 -> "Tm_type"
    | FStar_Syntax_Syntax.Tm_quoted
        (uu____1388,{
                      FStar_Syntax_Syntax.qkind =
                        FStar_Syntax_Syntax.Quote_static ;
                      FStar_Syntax_Syntax.antiquotes = uu____1389;_})
        -> "Tm_quoted (static)"
    | FStar_Syntax_Syntax.Tm_quoted
        (uu____1403,{
                      FStar_Syntax_Syntax.qkind =
                        FStar_Syntax_Syntax.Quote_dynamic ;
                      FStar_Syntax_Syntax.antiquotes = uu____1404;_})
        -> "Tm_quoted (dynamic)"
    | FStar_Syntax_Syntax.Tm_abs uu____1418 -> "Tm_abs"
    | FStar_Syntax_Syntax.Tm_arrow uu____1438 -> "Tm_arrow"
    | FStar_Syntax_Syntax.Tm_refine uu____1454 -> "Tm_refine"
    | FStar_Syntax_Syntax.Tm_app uu____1462 -> "Tm_app"
    | FStar_Syntax_Syntax.Tm_match uu____1480 -> "Tm_match"
    | FStar_Syntax_Syntax.Tm_ascribed uu____1504 -> "Tm_ascribed"
    | FStar_Syntax_Syntax.Tm_let uu____1532 -> "Tm_let"
    | FStar_Syntax_Syntax.Tm_uvar uu____1547 -> "Tm_uvar"
    | FStar_Syntax_Syntax.Tm_delayed uu____1561 -> "Tm_delayed"
    | FStar_Syntax_Syntax.Tm_meta (uu____1577,m) ->
        let uu____1583 = metadata_to_string m  in
        Prims.op_Hat "Tm_meta:" uu____1583
    | FStar_Syntax_Syntax.Tm_unknown  -> "Tm_unknown"
    | FStar_Syntax_Syntax.Tm_lazy uu____1587 -> "Tm_lazy"

and (term_to_string : FStar_Syntax_Syntax.term -> Prims.string) =
  fun x  ->
    let uu____1590 =
      let uu____1592 = FStar_Options.ugly ()  in Prims.op_Negation uu____1592
       in
    if uu____1590
    then
      let e = FStar_Syntax_Resugar.resugar_term x  in
      let d = FStar_Parser_ToDocument.term_to_document e  in
      FStar_Pprint.pretty_string (FStar_Util.float_of_string "1.0")
        (Prims.of_int (100)) d
    else
      (let x1 = FStar_Syntax_Subst.compress x  in
       let x2 =
         let uu____1606 = FStar_Options.print_implicits ()  in
         if uu____1606 then x1 else FStar_Syntax_Util.unmeta x1  in
       match x2.FStar_Syntax_Syntax.n with
       | FStar_Syntax_Syntax.Tm_delayed uu____1614 -> failwith "impossible"
       | FStar_Syntax_Syntax.Tm_app (uu____1631,[]) -> failwith "Empty args!"
       | FStar_Syntax_Syntax.Tm_lazy
           { FStar_Syntax_Syntax.blob = b;
             FStar_Syntax_Syntax.lkind = FStar_Syntax_Syntax.Lazy_embedding
               (uu____1657,thunk1);
             FStar_Syntax_Syntax.ltyp = uu____1659;
             FStar_Syntax_Syntax.rng = uu____1660;_}
           ->
           let uu____1671 =
             let uu____1673 =
               let uu____1675 = FStar_Thunk.force thunk1  in
               term_to_string uu____1675  in
             Prims.op_Hat uu____1673 "]"  in
           Prims.op_Hat "[LAZYEMB:" uu____1671
       | FStar_Syntax_Syntax.Tm_lazy i ->
           let uu____1681 =
             let uu____1683 =
               let uu____1685 =
                 let uu____1686 =
                   let uu____1695 =
                     FStar_ST.op_Bang FStar_Syntax_Syntax.lazy_chooser  in
                   FStar_Util.must uu____1695  in
                 uu____1686 i.FStar_Syntax_Syntax.lkind i  in
               term_to_string uu____1685  in
             Prims.op_Hat uu____1683 "]"  in
           Prims.op_Hat "[lazy:" uu____1681
       | FStar_Syntax_Syntax.Tm_quoted (tm,qi) ->
           (match qi.FStar_Syntax_Syntax.qkind with
            | FStar_Syntax_Syntax.Quote_static  ->
                let print_aq uu____1764 =
                  match uu____1764 with
                  | (bv,t) ->
                      let uu____1772 = bv_to_string bv  in
                      let uu____1774 = term_to_string t  in
                      FStar_Util.format2 "%s -> %s" uu____1772 uu____1774
                   in
                let uu____1777 = term_to_string tm  in
                let uu____1779 =
                  FStar_Common.string_of_list print_aq
                    qi.FStar_Syntax_Syntax.antiquotes
                   in
                FStar_Util.format2 "`(%s)%s" uu____1777 uu____1779
            | FStar_Syntax_Syntax.Quote_dynamic  ->
                let uu____1788 = term_to_string tm  in
                FStar_Util.format1 "quote (%s)" uu____1788)
       | FStar_Syntax_Syntax.Tm_meta
           (t,FStar_Syntax_Syntax.Meta_pattern (uu____1792,ps)) ->
           let pats =
             let uu____1832 =
               FStar_All.pipe_right ps
                 (FStar_List.map
                    (fun args  ->
                       let uu____1869 =
                         FStar_All.pipe_right args
                           (FStar_List.map
                              (fun uu____1894  ->
                                 match uu____1894 with
                                 | (t1,uu____1903) -> term_to_string t1))
                          in
                       FStar_All.pipe_right uu____1869
                         (FStar_String.concat "; ")))
                in
             FStar_All.pipe_right uu____1832 (FStar_String.concat "\\/")  in
           let uu____1918 = term_to_string t  in
           FStar_Util.format2 "{:pattern %s} %s" pats uu____1918
       | FStar_Syntax_Syntax.Tm_meta
           (t,FStar_Syntax_Syntax.Meta_monadic (m,t')) ->
           let uu____1932 = tag_of_term t  in
           let uu____1934 = sli m  in
           let uu____1936 = term_to_string t'  in
           let uu____1938 = term_to_string t  in
           FStar_Util.format4 "(Monadic-%s{%s %s} %s)" uu____1932 uu____1934
             uu____1936 uu____1938
       | FStar_Syntax_Syntax.Tm_meta
           (t,FStar_Syntax_Syntax.Meta_monadic_lift (m0,m1,t')) ->
           let uu____1953 = tag_of_term t  in
           let uu____1955 = term_to_string t'  in
           let uu____1957 = sli m0  in
           let uu____1959 = sli m1  in
           let uu____1961 = term_to_string t  in
           FStar_Util.format5 "(MonadicLift-%s{%s : %s -> %s} %s)" uu____1953
             uu____1955 uu____1957 uu____1959 uu____1961
       | FStar_Syntax_Syntax.Tm_meta
           (t,FStar_Syntax_Syntax.Meta_labeled (l,r,b)) ->
           let uu____1976 = FStar_Range.string_of_range r  in
           let uu____1978 = term_to_string t  in
           FStar_Util.format3 "Meta_labeled(%s, %s){%s}" l uu____1976
             uu____1978
       | FStar_Syntax_Syntax.Tm_meta (t,FStar_Syntax_Syntax.Meta_named l) ->
           let uu____1987 = lid_to_string l  in
           let uu____1989 =
             FStar_Range.string_of_range t.FStar_Syntax_Syntax.pos  in
           let uu____1991 = term_to_string t  in
           FStar_Util.format3 "Meta_named(%s, %s){%s}" uu____1987 uu____1989
             uu____1991
       | FStar_Syntax_Syntax.Tm_meta
           (t,FStar_Syntax_Syntax.Meta_desugared uu____1995) ->
           let uu____2000 = term_to_string t  in
           FStar_Util.format1 "Meta_desugared{%s}" uu____2000
       | FStar_Syntax_Syntax.Tm_bvar x3 ->
           let uu____2004 = db_to_string x3  in
           let uu____2006 =
             let uu____2008 =
               let uu____2010 = tag_of_term x3.FStar_Syntax_Syntax.sort  in
               Prims.op_Hat uu____2010 ")"  in
             Prims.op_Hat ":(" uu____2008  in
           Prims.op_Hat uu____2004 uu____2006
       | FStar_Syntax_Syntax.Tm_name x3 -> nm_to_string x3
       | FStar_Syntax_Syntax.Tm_fvar f -> fv_to_string f
       | FStar_Syntax_Syntax.Tm_uvar (u,([],uu____2017)) ->
           let uu____2032 =
             (FStar_Options.print_bound_var_types ()) &&
               (FStar_Options.print_effect_args ())
              in
           if uu____2032
           then ctx_uvar_to_string u
           else
             (let uu____2038 =
                let uu____2040 =
                  FStar_Syntax_Unionfind.uvar_id
                    u.FStar_Syntax_Syntax.ctx_uvar_head
                   in
                FStar_All.pipe_left FStar_Util.string_of_int uu____2040  in
              Prims.op_Hat "?" uu____2038)
       | FStar_Syntax_Syntax.Tm_uvar (u,s) ->
           let uu____2063 =
             (FStar_Options.print_bound_var_types ()) &&
               (FStar_Options.print_effect_args ())
              in
           if uu____2063
           then
             let uu____2067 = ctx_uvar_to_string u  in
             let uu____2069 =
               let uu____2071 =
                 FStar_List.map subst_to_string
                   (FStar_Pervasives_Native.fst s)
                  in
               FStar_All.pipe_right uu____2071 (FStar_String.concat "; ")  in
             FStar_Util.format2 "(%s @ %s)" uu____2067 uu____2069
           else
             (let uu____2090 =
                let uu____2092 =
                  FStar_Syntax_Unionfind.uvar_id
                    u.FStar_Syntax_Syntax.ctx_uvar_head
                   in
                FStar_All.pipe_left FStar_Util.string_of_int uu____2092  in
              Prims.op_Hat "?" uu____2090)
       | FStar_Syntax_Syntax.Tm_constant c -> const_to_string c
       | FStar_Syntax_Syntax.Tm_type u ->
           let uu____2099 = FStar_Options.print_universes ()  in
           if uu____2099
           then
             let uu____2103 = univ_to_string u  in
             FStar_Util.format1 "Type u#(%s)" uu____2103
           else "Type"
       | FStar_Syntax_Syntax.Tm_arrow (bs,c) ->
           let uu____2131 = binders_to_string " -> " bs  in
           let uu____2134 = comp_to_string c  in
           FStar_Util.format2 "(%s -> %s)" uu____2131 uu____2134
       | FStar_Syntax_Syntax.Tm_abs (bs,t2,lc) ->
           (match lc with
            | FStar_Pervasives_Native.Some rc when
                FStar_Options.print_implicits () ->
                let uu____2166 = binders_to_string " " bs  in
                let uu____2169 = term_to_string t2  in
                let uu____2171 =
                  if FStar_Option.isNone rc.FStar_Syntax_Syntax.residual_typ
                  then "None"
                  else
                    (let uu____2180 =
                       FStar_Option.get rc.FStar_Syntax_Syntax.residual_typ
                        in
                     term_to_string uu____2180)
                   in
                FStar_Util.format4 "(fun %s -> (%s $$ (residual) %s %s))"
                  uu____2166 uu____2169
                  (rc.FStar_Syntax_Syntax.residual_effect).FStar_Ident.str
                  uu____2171
            | uu____2184 ->
                let uu____2187 = binders_to_string " " bs  in
                let uu____2190 = term_to_string t2  in
                FStar_Util.format2 "(fun %s -> %s)" uu____2187 uu____2190)
       | FStar_Syntax_Syntax.Tm_refine (xt,f) ->
           let uu____2199 = bv_to_string xt  in
           let uu____2201 =
             FStar_All.pipe_right xt.FStar_Syntax_Syntax.sort term_to_string
              in
           let uu____2204 = FStar_All.pipe_right f formula_to_string  in
           FStar_Util.format3 "(%s:%s{%s})" uu____2199 uu____2201 uu____2204
       | FStar_Syntax_Syntax.Tm_app (t,args) ->
           let uu____2236 = term_to_string t  in
           let uu____2238 = args_to_string args  in
           FStar_Util.format2 "(%s %s)" uu____2236 uu____2238
       | FStar_Syntax_Syntax.Tm_let (lbs,e) ->
           let uu____2261 = lbs_to_string [] lbs  in
           let uu____2263 = term_to_string e  in
           FStar_Util.format2 "%s\nin\n%s" uu____2261 uu____2263
       | FStar_Syntax_Syntax.Tm_ascribed (e,(annot,topt),eff_name) ->
           let annot1 =
             match annot with
             | FStar_Util.Inl t ->
                 let uu____2328 =
                   let uu____2330 =
                     FStar_Util.map_opt eff_name FStar_Ident.text_of_lid  in
                   FStar_All.pipe_right uu____2330
                     (FStar_Util.dflt "default")
                    in
                 let uu____2341 = term_to_string t  in
                 FStar_Util.format2 "[%s] %s" uu____2328 uu____2341
             | FStar_Util.Inr c -> comp_to_string c  in
           let topt1 =
             match topt with
             | FStar_Pervasives_Native.None  -> ""
             | FStar_Pervasives_Native.Some t ->
                 let uu____2362 = term_to_string t  in
                 FStar_Util.format1 "by %s" uu____2362
              in
           let uu____2365 = term_to_string e  in
           FStar_Util.format3 "(%s <ascribed: %s %s)" uu____2365 annot1 topt1
       | FStar_Syntax_Syntax.Tm_match (head1,branches) ->
           let uu____2406 = term_to_string head1  in
           let uu____2408 =
             let uu____2410 =
               FStar_All.pipe_right branches
                 (FStar_List.map branch_to_string)
                in
             FStar_Util.concat_l "\n\t|" uu____2410  in
           FStar_Util.format2 "(match %s with\n\t| %s)" uu____2406 uu____2408
       | FStar_Syntax_Syntax.Tm_uinst (t,us) ->
           let uu____2428 = FStar_Options.print_universes ()  in
           if uu____2428
           then
             let uu____2432 = term_to_string t  in
             let uu____2434 = univs_to_string us  in
             FStar_Util.format2 "%s<%s>" uu____2432 uu____2434
           else term_to_string t
       | FStar_Syntax_Syntax.Tm_unknown  -> "_")

and (branch_to_string : FStar_Syntax_Syntax.branch -> Prims.string) =
  fun uu____2440  ->
    match uu____2440 with
    | (p,wopt,e) ->
        let uu____2462 = FStar_All.pipe_right p pat_to_string  in
        let uu____2465 =
          match wopt with
          | FStar_Pervasives_Native.None  -> ""
          | FStar_Pervasives_Native.Some w ->
              let uu____2476 = FStar_All.pipe_right w term_to_string  in
              FStar_Util.format1 "when %s" uu____2476
           in
        let uu____2480 = FStar_All.pipe_right e term_to_string  in
        FStar_Util.format3 "%s %s -> %s" uu____2462 uu____2465 uu____2480

and (ctx_uvar_to_string : FStar_Syntax_Syntax.ctx_uvar -> Prims.string) =
  fun ctx_uvar  ->
    let uu____2485 =
      binders_to_string ", " ctx_uvar.FStar_Syntax_Syntax.ctx_uvar_binders
       in
    let uu____2488 =
      uvar_to_string ctx_uvar.FStar_Syntax_Syntax.ctx_uvar_head  in
    let uu____2490 = term_to_string ctx_uvar.FStar_Syntax_Syntax.ctx_uvar_typ
       in
    FStar_Util.format4 "(* %s *)\n(%s |- %s : %s)"
      ctx_uvar.FStar_Syntax_Syntax.ctx_uvar_reason uu____2485 uu____2488
      uu____2490

and (subst_elt_to_string : FStar_Syntax_Syntax.subst_elt -> Prims.string) =
  fun uu___5_2493  ->
    match uu___5_2493 with
    | FStar_Syntax_Syntax.DB (i,x) ->
        let uu____2499 = FStar_Util.string_of_int i  in
        let uu____2501 = bv_to_string x  in
        FStar_Util.format2 "DB (%s, %s)" uu____2499 uu____2501
    | FStar_Syntax_Syntax.NM (x,i) ->
        let uu____2508 = bv_to_string x  in
        let uu____2510 = FStar_Util.string_of_int i  in
        FStar_Util.format2 "NM (%s, %s)" uu____2508 uu____2510
    | FStar_Syntax_Syntax.NT (x,t) ->
        let uu____2519 = bv_to_string x  in
        let uu____2521 = term_to_string t  in
        FStar_Util.format2 "NT (%s, %s)" uu____2519 uu____2521
    | FStar_Syntax_Syntax.UN (i,u) ->
        let uu____2528 = FStar_Util.string_of_int i  in
        let uu____2530 = univ_to_string u  in
        FStar_Util.format2 "UN (%s, %s)" uu____2528 uu____2530
    | FStar_Syntax_Syntax.UD (u,i) ->
        let uu____2537 = FStar_Util.string_of_int i  in
        FStar_Util.format2 "UD (%s, %s)" u.FStar_Ident.idText uu____2537

and (subst_to_string : FStar_Syntax_Syntax.subst_t -> Prims.string) =
  fun s  ->
    let uu____2541 =
      FStar_All.pipe_right s (FStar_List.map subst_elt_to_string)  in
    FStar_All.pipe_right uu____2541 (FStar_String.concat "; ")

and (pat_to_string : FStar_Syntax_Syntax.pat -> Prims.string) =
  fun x  ->
    let uu____2557 =
      let uu____2559 = FStar_Options.ugly ()  in Prims.op_Negation uu____2559
       in
    if uu____2557
    then
      let e =
        let uu____2564 = FStar_Syntax_Syntax.new_bv_set ()  in
        FStar_Syntax_Resugar.resugar_pat x uu____2564  in
      let d = FStar_Parser_ToDocument.pat_to_document e  in
      FStar_Pprint.pretty_string (FStar_Util.float_of_string "1.0")
        (Prims.of_int (100)) d
    else
      (match x.FStar_Syntax_Syntax.v with
       | FStar_Syntax_Syntax.Pat_cons (l,pats) ->
           let uu____2593 = fv_to_string l  in
           let uu____2595 =
             let uu____2597 =
               FStar_List.map
                 (fun uu____2611  ->
                    match uu____2611 with
                    | (x1,b) ->
                        let p = pat_to_string x1  in
                        if b then Prims.op_Hat "#" p else p) pats
                in
             FStar_All.pipe_right uu____2597 (FStar_String.concat " ")  in
           FStar_Util.format2 "(%s %s)" uu____2593 uu____2595
       | FStar_Syntax_Syntax.Pat_dot_term (x1,uu____2636) ->
           let uu____2641 = FStar_Options.print_bound_var_types ()  in
           if uu____2641
           then
             let uu____2645 = bv_to_string x1  in
             let uu____2647 = term_to_string x1.FStar_Syntax_Syntax.sort  in
             FStar_Util.format2 ".%s:%s" uu____2645 uu____2647
           else
             (let uu____2652 = bv_to_string x1  in
              FStar_Util.format1 ".%s" uu____2652)
       | FStar_Syntax_Syntax.Pat_var x1 ->
           let uu____2656 = FStar_Options.print_bound_var_types ()  in
           if uu____2656
           then
             let uu____2660 = bv_to_string x1  in
             let uu____2662 = term_to_string x1.FStar_Syntax_Syntax.sort  in
             FStar_Util.format2 "%s:%s" uu____2660 uu____2662
           else bv_to_string x1
       | FStar_Syntax_Syntax.Pat_constant c -> const_to_string c
       | FStar_Syntax_Syntax.Pat_wild x1 ->
           let uu____2669 = FStar_Options.print_bound_var_types ()  in
           if uu____2669
           then
             let uu____2673 = bv_to_string x1  in
             let uu____2675 = term_to_string x1.FStar_Syntax_Syntax.sort  in
             FStar_Util.format2 "_wild_%s:%s" uu____2673 uu____2675
           else bv_to_string x1)

and (lbs_to_string :
  FStar_Syntax_Syntax.qualifier Prims.list ->
    FStar_Syntax_Syntax.letbindings -> Prims.string)
  =
  fun quals  ->
    fun lbs  ->
      let uu____2684 = quals_to_string' quals  in
      let uu____2686 =
        let uu____2688 =
          FStar_All.pipe_right (FStar_Pervasives_Native.snd lbs)
            (FStar_List.map
               (fun lb  ->
                  let uu____2708 =
                    attrs_to_string lb.FStar_Syntax_Syntax.lbattrs  in
                  let uu____2710 =
                    lbname_to_string lb.FStar_Syntax_Syntax.lbname  in
                  let uu____2712 =
                    let uu____2714 = FStar_Options.print_universes ()  in
                    if uu____2714
                    then
                      let uu____2718 =
                        let uu____2720 =
                          univ_names_to_string lb.FStar_Syntax_Syntax.lbunivs
                           in
                        Prims.op_Hat uu____2720 ">"  in
                      Prims.op_Hat "<" uu____2718
                    else ""  in
                  let uu____2727 =
                    term_to_string lb.FStar_Syntax_Syntax.lbtyp  in
                  let uu____2729 =
                    FStar_All.pipe_right lb.FStar_Syntax_Syntax.lbdef
                      term_to_string
                     in
                  FStar_Util.format5 "%s%s %s : %s = %s" uu____2708
                    uu____2710 uu____2712 uu____2727 uu____2729))
           in
        FStar_Util.concat_l "\n and " uu____2688  in
      FStar_Util.format3 "%slet %s %s" uu____2684
        (if FStar_Pervasives_Native.fst lbs then "rec" else "") uu____2686

and (attrs_to_string :
  FStar_Syntax_Syntax.attribute Prims.list -> Prims.string) =
  fun uu___6_2744  ->
    match uu___6_2744 with
    | [] -> ""
    | tms ->
        let uu____2752 =
          let uu____2754 =
            FStar_List.map
              (fun t  ->
                 let uu____2762 = term_to_string t  in paren uu____2762) tms
             in
          FStar_All.pipe_right uu____2754 (FStar_String.concat "; ")  in
        FStar_Util.format1 "[@ %s]" uu____2752

and (aqual_to_string' :
  Prims.string ->
    FStar_Syntax_Syntax.arg_qualifier FStar_Pervasives_Native.option ->
      Prims.string)
  =
  fun s  ->
    fun uu___7_2771  ->
      match uu___7_2771 with
      | FStar_Pervasives_Native.Some (FStar_Syntax_Syntax.Implicit (false ))
          -> Prims.op_Hat "#" s
      | FStar_Pervasives_Native.Some (FStar_Syntax_Syntax.Implicit (true ))
          -> Prims.op_Hat "#." s
      | FStar_Pervasives_Native.Some (FStar_Syntax_Syntax.Equality ) ->
          Prims.op_Hat "$" s
      | FStar_Pervasives_Native.Some (FStar_Syntax_Syntax.Meta t) when
          FStar_Syntax_Util.is_fvar FStar_Parser_Const.tcresolve_lid t ->
          Prims.op_Hat "[|" (Prims.op_Hat s "|]")
      | FStar_Pervasives_Native.Some (FStar_Syntax_Syntax.Meta t) ->
          let uu____2789 =
            let uu____2791 = term_to_string t  in
            Prims.op_Hat uu____2791 (Prims.op_Hat "]" s)  in
          Prims.op_Hat "#[" uu____2789
      | FStar_Pervasives_Native.None  -> s

and (imp_to_string :
  Prims.string ->
    FStar_Syntax_Syntax.arg_qualifier FStar_Pervasives_Native.option ->
      Prims.string)
  = fun s  -> fun aq  -> aqual_to_string' s aq

and (binder_to_string' :
  Prims.bool ->
    (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier
      FStar_Pervasives_Native.option) -> Prims.string)
  =
  fun is_arrow  ->
    fun b  ->
      let uu____2809 =
        let uu____2811 = FStar_Options.ugly ()  in
        Prims.op_Negation uu____2811  in
      if uu____2809
      then
        let uu____2815 =
          FStar_Syntax_Resugar.resugar_binder b FStar_Range.dummyRange  in
        match uu____2815 with
        | FStar_Pervasives_Native.None  -> ""
        | FStar_Pervasives_Native.Some e ->
            let d = FStar_Parser_ToDocument.binder_to_document e  in
            FStar_Pprint.pretty_string (FStar_Util.float_of_string "1.0")
              (Prims.of_int (100)) d
      else
        (let uu____2826 = b  in
         match uu____2826 with
         | (a,imp) ->
             let uu____2840 = FStar_Syntax_Syntax.is_null_binder b  in
             if uu____2840
             then
               let uu____2844 = term_to_string a.FStar_Syntax_Syntax.sort  in
               Prims.op_Hat "_:" uu____2844
             else
               (let uu____2849 =
                  (Prims.op_Negation is_arrow) &&
                    (let uu____2852 = FStar_Options.print_bound_var_types ()
                        in
                     Prims.op_Negation uu____2852)
                   in
                if uu____2849
                then
                  let uu____2856 = nm_to_string a  in
                  imp_to_string uu____2856 imp
                else
                  (let uu____2860 =
                     let uu____2862 = nm_to_string a  in
                     let uu____2864 =
                       let uu____2866 =
                         term_to_string a.FStar_Syntax_Syntax.sort  in
                       Prims.op_Hat ":" uu____2866  in
                     Prims.op_Hat uu____2862 uu____2864  in
                   imp_to_string uu____2860 imp)))

and (binder_to_string : FStar_Syntax_Syntax.binder -> Prims.string) =
  fun b  -> binder_to_string' false b

and (arrow_binder_to_string :
  (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier
    FStar_Pervasives_Native.option) -> Prims.string)
  = fun b  -> binder_to_string' true b

and (binders_to_string :
  Prims.string -> FStar_Syntax_Syntax.binders -> Prims.string) =
  fun sep  ->
    fun bs  ->
      let bs1 =
        let uu____2885 = FStar_Options.print_implicits ()  in
        if uu____2885 then bs else filter_imp bs  in
      if sep = " -> "
      then
        let uu____2896 =
          FStar_All.pipe_right bs1 (FStar_List.map arrow_binder_to_string)
           in
        FStar_All.pipe_right uu____2896 (FStar_String.concat sep)
      else
        (let uu____2924 =
           FStar_All.pipe_right bs1 (FStar_List.map binder_to_string)  in
         FStar_All.pipe_right uu____2924 (FStar_String.concat sep))

and (arg_to_string :
  (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.arg_qualifier
    FStar_Pervasives_Native.option) -> Prims.string)
  =
  fun uu___8_2938  ->
    match uu___8_2938 with
    | (a,imp) ->
        let uu____2952 = term_to_string a  in imp_to_string uu____2952 imp

and (args_to_string : FStar_Syntax_Syntax.args -> Prims.string) =
  fun args  ->
    let args1 =
      let uu____2964 = FStar_Options.print_implicits ()  in
      if uu____2964 then args else filter_imp args  in
    let uu____2979 =
      FStar_All.pipe_right args1 (FStar_List.map arg_to_string)  in
    FStar_All.pipe_right uu____2979 (FStar_String.concat " ")

and (comp_to_string : FStar_Syntax_Syntax.comp -> Prims.string) =
  fun c  ->
    let uu____3007 =
      let uu____3009 = FStar_Options.ugly ()  in Prims.op_Negation uu____3009
       in
    if uu____3007
    then
      let e = FStar_Syntax_Resugar.resugar_comp c  in
      let d = FStar_Parser_ToDocument.term_to_document e  in
      FStar_Pprint.pretty_string (FStar_Util.float_of_string "1.0")
        (Prims.of_int (100)) d
    else
      (match c.FStar_Syntax_Syntax.n with
       | FStar_Syntax_Syntax.Total (t,uopt) ->
           let uu____3030 =
             let uu____3031 = FStar_Syntax_Subst.compress t  in
             uu____3031.FStar_Syntax_Syntax.n  in
           (match uu____3030 with
            | FStar_Syntax_Syntax.Tm_type uu____3035 when
                let uu____3036 =
                  (FStar_Options.print_implicits ()) ||
                    (FStar_Options.print_universes ())
                   in
                Prims.op_Negation uu____3036 -> term_to_string t
            | uu____3038 ->
                (match uopt with
                 | FStar_Pervasives_Native.Some u when
                     FStar_Options.print_universes () ->
                     let uu____3041 = univ_to_string u  in
                     let uu____3043 = term_to_string t  in
                     FStar_Util.format2 "Tot<%s> %s" uu____3041 uu____3043
                 | uu____3046 ->
                     let uu____3049 = term_to_string t  in
                     FStar_Util.format1 "Tot %s" uu____3049))
       | FStar_Syntax_Syntax.GTotal (t,uopt) ->
           let uu____3062 =
             let uu____3063 = FStar_Syntax_Subst.compress t  in
             uu____3063.FStar_Syntax_Syntax.n  in
           (match uu____3062 with
            | FStar_Syntax_Syntax.Tm_type uu____3067 when
                let uu____3068 =
                  (FStar_Options.print_implicits ()) ||
                    (FStar_Options.print_universes ())
                   in
                Prims.op_Negation uu____3068 -> term_to_string t
            | uu____3070 ->
                (match uopt with
                 | FStar_Pervasives_Native.Some u when
                     FStar_Options.print_universes () ->
                     let uu____3073 = univ_to_string u  in
                     let uu____3075 = term_to_string t  in
                     FStar_Util.format2 "GTot<%s> %s" uu____3073 uu____3075
                 | uu____3078 ->
                     let uu____3081 = term_to_string t  in
                     FStar_Util.format1 "GTot %s" uu____3081))
       | FStar_Syntax_Syntax.Comp c1 ->
           let basic =
             let uu____3087 = FStar_Options.print_effect_args ()  in
             if uu____3087
             then
               let uu____3091 = sli c1.FStar_Syntax_Syntax.effect_name  in
               let uu____3093 =
                 let uu____3095 =
                   FStar_All.pipe_right c1.FStar_Syntax_Syntax.comp_univs
                     (FStar_List.map univ_to_string)
                    in
                 FStar_All.pipe_right uu____3095 (FStar_String.concat ", ")
                  in
               let uu____3110 =
                 term_to_string c1.FStar_Syntax_Syntax.result_typ  in
               let uu____3112 =
                 let uu____3114 =
                   FStar_All.pipe_right c1.FStar_Syntax_Syntax.effect_args
                     (FStar_List.map arg_to_string)
                    in
                 FStar_All.pipe_right uu____3114 (FStar_String.concat ", ")
                  in
               let uu____3141 = cflags_to_string c1.FStar_Syntax_Syntax.flags
                  in
               FStar_Util.format5 "%s<%s> (%s) %s (attributes %s)" uu____3091
                 uu____3093 uu____3110 uu____3112 uu____3141
             else
               (let uu____3146 =
                  (FStar_All.pipe_right c1.FStar_Syntax_Syntax.flags
                     (FStar_Util.for_some
                        (fun uu___9_3152  ->
                           match uu___9_3152 with
                           | FStar_Syntax_Syntax.TOTAL  -> true
                           | uu____3155 -> false)))
                    &&
                    (let uu____3158 = FStar_Options.print_effect_args ()  in
                     Prims.op_Negation uu____3158)
                   in
                if uu____3146
                then
                  let uu____3162 =
                    term_to_string c1.FStar_Syntax_Syntax.result_typ  in
                  FStar_Util.format1 "Tot %s" uu____3162
                else
                  (let uu____3167 =
                     ((let uu____3171 = FStar_Options.print_effect_args ()
                          in
                       Prims.op_Negation uu____3171) &&
                        (let uu____3174 = FStar_Options.print_implicits ()
                            in
                         Prims.op_Negation uu____3174))
                       &&
                       (FStar_Ident.lid_equals
                          c1.FStar_Syntax_Syntax.effect_name
                          FStar_Parser_Const.effect_ML_lid)
                      in
                   if uu____3167
                   then term_to_string c1.FStar_Syntax_Syntax.result_typ
                   else
                     (let uu____3180 =
                        (let uu____3184 = FStar_Options.print_effect_args ()
                            in
                         Prims.op_Negation uu____3184) &&
                          (FStar_All.pipe_right c1.FStar_Syntax_Syntax.flags
                             (FStar_Util.for_some
                                (fun uu___10_3190  ->
                                   match uu___10_3190 with
                                   | FStar_Syntax_Syntax.MLEFFECT  -> true
                                   | uu____3193 -> false)))
                         in
                      if uu____3180
                      then
                        let uu____3197 =
                          term_to_string c1.FStar_Syntax_Syntax.result_typ
                           in
                        FStar_Util.format1 "ALL %s" uu____3197
                      else
                        (let uu____3202 =
                           sli c1.FStar_Syntax_Syntax.effect_name  in
                         let uu____3204 =
                           term_to_string c1.FStar_Syntax_Syntax.result_typ
                            in
                         FStar_Util.format2 "%s (%s)" uu____3202 uu____3204))))
              in
           let dec =
             let uu____3209 =
               FStar_All.pipe_right c1.FStar_Syntax_Syntax.flags
                 (FStar_List.collect
                    (fun uu___11_3222  ->
                       match uu___11_3222 with
                       | FStar_Syntax_Syntax.DECREASES e ->
                           let uu____3229 =
                             let uu____3231 = term_to_string e  in
                             FStar_Util.format1 " (decreases %s)" uu____3231
                              in
                           [uu____3229]
                       | uu____3236 -> []))
                in
             FStar_All.pipe_right uu____3209 (FStar_String.concat " ")  in
           FStar_Util.format2 "%s%s" basic dec)

and (cflag_to_string : FStar_Syntax_Syntax.cflag -> Prims.string) =
  fun c  ->
    match c with
    | FStar_Syntax_Syntax.TOTAL  -> "total"
    | FStar_Syntax_Syntax.MLEFFECT  -> "ml"
    | FStar_Syntax_Syntax.RETURN  -> "return"
    | FStar_Syntax_Syntax.PARTIAL_RETURN  -> "partial_return"
    | FStar_Syntax_Syntax.SOMETRIVIAL  -> "sometrivial"
    | FStar_Syntax_Syntax.TRIVIAL_POSTCONDITION  -> "trivial_postcondition"
    | FStar_Syntax_Syntax.SHOULD_NOT_INLINE  -> "should_not_inline"
    | FStar_Syntax_Syntax.LEMMA  -> "lemma"
    | FStar_Syntax_Syntax.CPS  -> "cps"
    | FStar_Syntax_Syntax.DECREASES uu____3255 -> ""

and (cflags_to_string : FStar_Syntax_Syntax.cflag Prims.list -> Prims.string)
  = fun fs  -> FStar_Common.string_of_list cflag_to_string fs

and (formula_to_string :
  FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax -> Prims.string) =
  fun phi  -> term_to_string phi

and (metadata_to_string : FStar_Syntax_Syntax.metadata -> Prims.string) =
  fun uu___12_3265  ->
    match uu___12_3265 with
    | FStar_Syntax_Syntax.Meta_pattern (uu____3267,ps) ->
        let pats =
          let uu____3303 =
            FStar_All.pipe_right ps
              (FStar_List.map
                 (fun args  ->
                    let uu____3340 =
                      FStar_All.pipe_right args
                        (FStar_List.map
                           (fun uu____3365  ->
                              match uu____3365 with
                              | (t,uu____3374) -> term_to_string t))
                       in
                    FStar_All.pipe_right uu____3340
                      (FStar_String.concat "; ")))
             in
          FStar_All.pipe_right uu____3303 (FStar_String.concat "\\/")  in
        FStar_Util.format1 "{Meta_pattern %s}" pats
    | FStar_Syntax_Syntax.Meta_named lid ->
        let uu____3391 = sli lid  in
        FStar_Util.format1 "{Meta_named %s}" uu____3391
    | FStar_Syntax_Syntax.Meta_labeled (l,r,uu____3396) ->
        let uu____3401 = FStar_Range.string_of_range r  in
        FStar_Util.format2 "{Meta_labeled (%s, %s)}" l uu____3401
    | FStar_Syntax_Syntax.Meta_desugared msi -> "{Meta_desugared}"
    | FStar_Syntax_Syntax.Meta_monadic (m,t) ->
        let uu____3412 = sli m  in
        let uu____3414 = term_to_string t  in
        FStar_Util.format2 "{Meta_monadic(%s @ %s)}" uu____3412 uu____3414
    | FStar_Syntax_Syntax.Meta_monadic_lift (m,m',t) ->
        let uu____3424 = sli m  in
        let uu____3426 = sli m'  in
        let uu____3428 = term_to_string t  in
        FStar_Util.format3 "{Meta_monadic_lift(%s -> %s @ %s)}" uu____3424
          uu____3426 uu____3428

let (aqual_to_string : FStar_Syntax_Syntax.aqual -> Prims.string) =
  fun aq  -> aqual_to_string' "" aq 
let (comp_to_string' :
  FStar_Syntax_DsEnv.env -> FStar_Syntax_Syntax.comp -> Prims.string) =
  fun env  ->
    fun c  ->
      let uu____3451 = FStar_Options.ugly ()  in
      if uu____3451
      then comp_to_string c
      else
        (let e = FStar_Syntax_Resugar.resugar_comp' env c  in
         let d = FStar_Parser_ToDocument.term_to_document e  in
         FStar_Pprint.pretty_string (FStar_Util.float_of_string "1.0")
           (Prims.of_int (100)) d)
  
let (term_to_string' :
  FStar_Syntax_DsEnv.env -> FStar_Syntax_Syntax.term -> Prims.string) =
  fun env  ->
    fun x  ->
      let uu____3473 = FStar_Options.ugly ()  in
      if uu____3473
      then term_to_string x
      else
        (let e = FStar_Syntax_Resugar.resugar_term' env x  in
         let d = FStar_Parser_ToDocument.term_to_document e  in
         FStar_Pprint.pretty_string (FStar_Util.float_of_string "1.0")
           (Prims.of_int (100)) d)
  
let (binder_to_json :
  FStar_Syntax_DsEnv.env -> FStar_Syntax_Syntax.binder -> FStar_Util.json) =
  fun env  ->
    fun b  ->
      let uu____3494 = b  in
      match uu____3494 with
      | (a,imp) ->
          let n1 =
            let uu____3502 = FStar_Syntax_Syntax.is_null_binder b  in
            if uu____3502
            then FStar_Util.JsonNull
            else
              (let uu____3507 =
                 let uu____3509 = nm_to_string a  in
                 imp_to_string uu____3509 imp  in
               FStar_Util.JsonStr uu____3507)
             in
          let t =
            let uu____3512 = term_to_string' env a.FStar_Syntax_Syntax.sort
               in
            FStar_Util.JsonStr uu____3512  in
          FStar_Util.JsonAssoc [("name", n1); ("type", t)]
  
let (binders_to_json :
  FStar_Syntax_DsEnv.env -> FStar_Syntax_Syntax.binders -> FStar_Util.json) =
  fun env  ->
    fun bs  ->
      let uu____3544 = FStar_List.map (binder_to_json env) bs  in
      FStar_Util.JsonList uu____3544
  
let (enclose_universes : Prims.string -> Prims.string) =
  fun s  ->
    let uu____3562 = FStar_Options.print_universes ()  in
    if uu____3562 then Prims.op_Hat "<" (Prims.op_Hat s ">") else ""
  
let (tscheme_to_string : FStar_Syntax_Syntax.tscheme -> Prims.string) =
  fun s  ->
    let uu____3578 =
      let uu____3580 = FStar_Options.ugly ()  in Prims.op_Negation uu____3580
       in
    if uu____3578
    then
      let d = FStar_Syntax_Resugar.resugar_tscheme s  in
      let d1 = FStar_Parser_ToDocument.decl_to_document d  in
      FStar_Pprint.pretty_string (FStar_Util.float_of_string "1.0")
        (Prims.of_int (100)) d1
    else
      (let uu____3590 = s  in
       match uu____3590 with
       | (us,t) ->
           let uu____3602 =
             let uu____3604 = univ_names_to_string us  in
             FStar_All.pipe_left enclose_universes uu____3604  in
           let uu____3608 = term_to_string t  in
           FStar_Util.format2 "%s%s" uu____3602 uu____3608)
  
let (action_to_string : FStar_Syntax_Syntax.action -> Prims.string) =
  fun a  ->
    let uu____3618 = sli a.FStar_Syntax_Syntax.action_name  in
    let uu____3620 =
      binders_to_string " " a.FStar_Syntax_Syntax.action_params  in
    let uu____3623 =
      let uu____3625 =
        univ_names_to_string a.FStar_Syntax_Syntax.action_univs  in
      FStar_All.pipe_left enclose_universes uu____3625  in
    let uu____3629 = term_to_string a.FStar_Syntax_Syntax.action_typ  in
    let uu____3631 = term_to_string a.FStar_Syntax_Syntax.action_defn  in
    FStar_Util.format5 "%s%s %s : %s = %s" uu____3618 uu____3620 uu____3623
      uu____3629 uu____3631
  
let (wp_eff_combinators_to_string :
  FStar_Syntax_Syntax.wp_eff_combinators -> Prims.string) =
  fun combs  ->
    let tscheme_opt_to_string uu___13_3649 =
      match uu___13_3649 with
      | FStar_Pervasives_Native.Some ts -> tscheme_to_string ts
      | FStar_Pervasives_Native.None  -> "None"  in
    let uu____3655 =
      let uu____3659 = tscheme_to_string combs.FStar_Syntax_Syntax.ret_wp  in
      let uu____3661 =
        let uu____3665 = tscheme_to_string combs.FStar_Syntax_Syntax.bind_wp
           in
        let uu____3667 =
          let uu____3671 =
            tscheme_to_string combs.FStar_Syntax_Syntax.stronger  in
          let uu____3673 =
            let uu____3677 =
              tscheme_to_string combs.FStar_Syntax_Syntax.if_then_else  in
            let uu____3679 =
              let uu____3683 =
                tscheme_to_string combs.FStar_Syntax_Syntax.ite_wp  in
              let uu____3685 =
                let uu____3689 =
                  tscheme_to_string combs.FStar_Syntax_Syntax.close_wp  in
                let uu____3691 =
                  let uu____3695 =
                    tscheme_to_string combs.FStar_Syntax_Syntax.trivial  in
                  let uu____3697 =
                    let uu____3701 =
                      tscheme_opt_to_string combs.FStar_Syntax_Syntax.repr
                       in
                    let uu____3703 =
                      let uu____3707 =
                        tscheme_opt_to_string
                          combs.FStar_Syntax_Syntax.return_repr
                         in
                      let uu____3709 =
                        let uu____3713 =
                          tscheme_opt_to_string
                            combs.FStar_Syntax_Syntax.bind_repr
                           in
                        [uu____3713]  in
                      uu____3707 :: uu____3709  in
                    uu____3701 :: uu____3703  in
                  uu____3695 :: uu____3697  in
                uu____3689 :: uu____3691  in
              uu____3683 :: uu____3685  in
            uu____3677 :: uu____3679  in
          uu____3671 :: uu____3673  in
        uu____3665 :: uu____3667  in
      uu____3659 :: uu____3661  in
    FStar_Util.format
      "{\nret_wp       = %s\n; bind_wp      = %s\n; stronger     = %s\n; if_then_else = %s\n; ite_wp       = %s\n; close_wp     = %s\n; trivial      = %s\n; repr         = %s\n; return_repr  = %s\n; bind_repr    = %s\n}\n"
      uu____3655
  
let (layered_eff_combinators_to_string :
  FStar_Syntax_Syntax.layered_eff_combinators -> Prims.string) =
  fun combs  ->
    let to_str uu____3744 =
      match uu____3744 with
      | (ts_t,ts_ty) ->
          let uu____3752 = tscheme_to_string ts_t  in
          let uu____3754 = tscheme_to_string ts_ty  in
          FStar_Util.format2 "(%s) : (%s)" uu____3752 uu____3754
       in
    let uu____3757 =
      let uu____3761 =
        FStar_Ident.string_of_lid combs.FStar_Syntax_Syntax.l_base_effect  in
      let uu____3763 =
        let uu____3767 = to_str combs.FStar_Syntax_Syntax.l_repr  in
        let uu____3769 =
          let uu____3773 = to_str combs.FStar_Syntax_Syntax.l_return  in
          let uu____3775 =
            let uu____3779 = to_str combs.FStar_Syntax_Syntax.l_bind  in
            let uu____3781 =
              let uu____3785 = to_str combs.FStar_Syntax_Syntax.l_subcomp  in
              let uu____3787 =
                let uu____3791 =
                  to_str combs.FStar_Syntax_Syntax.l_if_then_else  in
                [uu____3791]  in
              uu____3785 :: uu____3787  in
            uu____3779 :: uu____3781  in
          uu____3773 :: uu____3775  in
        uu____3767 :: uu____3769  in
      uu____3761 :: uu____3763  in
    FStar_Util.format
      "{\nl_base_effect = %s\n; l_repr = %s\n; l_return = %s\n; l_bind = %s\n; l_subcomp = %s\n; l_if_then_else = %s\n\n  }\n"
      uu____3757
  
let (eff_combinators_to_string :
  FStar_Syntax_Syntax.eff_combinators -> Prims.string) =
  fun uu___14_3807  ->
    match uu___14_3807 with
    | FStar_Syntax_Syntax.Primitive_eff combs ->
        wp_eff_combinators_to_string combs
    | FStar_Syntax_Syntax.DM4F_eff combs ->
        wp_eff_combinators_to_string combs
    | FStar_Syntax_Syntax.Layered_eff combs ->
        layered_eff_combinators_to_string combs
  
let (eff_decl_to_string' :
  Prims.bool ->
    FStar_Range.range ->
      FStar_Syntax_Syntax.qualifier Prims.list ->
        FStar_Syntax_Syntax.eff_decl -> Prims.string)
  =
  fun for_free  ->
    fun r  ->
      fun q  ->
        fun ed  ->
          let uu____3840 =
            let uu____3842 = FStar_Options.ugly ()  in
            Prims.op_Negation uu____3842  in
          if uu____3840
          then
            let d = FStar_Syntax_Resugar.resugar_eff_decl r q ed  in
            let d1 = FStar_Parser_ToDocument.decl_to_document d  in
            FStar_Pprint.pretty_string (FStar_Util.float_of_string "1.0")
              (Prims.of_int (100)) d1
          else
            (let actions_to_string actions =
               let uu____3863 =
                 FStar_All.pipe_right actions
                   (FStar_List.map action_to_string)
                  in
               FStar_All.pipe_right uu____3863 (FStar_String.concat ",\n\t")
                in
             let eff_name =
               let uu____3880 = FStar_Syntax_Util.is_layered ed  in
               if uu____3880 then "layered_effect" else "new_effect"  in
             let uu____3888 =
               let uu____3892 =
                 let uu____3896 =
                   let uu____3900 =
                     lid_to_string ed.FStar_Syntax_Syntax.mname  in
                   let uu____3902 =
                     let uu____3906 =
                       let uu____3908 =
                         univ_names_to_string ed.FStar_Syntax_Syntax.univs
                          in
                       FStar_All.pipe_left enclose_universes uu____3908  in
                     let uu____3912 =
                       let uu____3916 =
                         binders_to_string " " ed.FStar_Syntax_Syntax.binders
                          in
                       let uu____3919 =
                         let uu____3923 =
                           tscheme_to_string ed.FStar_Syntax_Syntax.signature
                            in
                         let uu____3925 =
                           let uu____3929 =
                             eff_combinators_to_string
                               ed.FStar_Syntax_Syntax.combinators
                              in
                           let uu____3931 =
                             let uu____3935 =
                               actions_to_string
                                 ed.FStar_Syntax_Syntax.actions
                                in
                             [uu____3935]  in
                           uu____3929 :: uu____3931  in
                         uu____3923 :: uu____3925  in
                       uu____3916 :: uu____3919  in
                     uu____3906 :: uu____3912  in
                   uu____3900 :: uu____3902  in
                 (if for_free then "_for_free " else "") :: uu____3896  in
               eff_name :: uu____3892  in
             FStar_Util.format
               "%s%s { %s%s %s : %s \n  %s\nand effect_actions\n\t%s\n}\n"
               uu____3888)
  
let (eff_decl_to_string :
  Prims.bool -> FStar_Syntax_Syntax.eff_decl -> Prims.string) =
  fun for_free  ->
    fun ed  -> eff_decl_to_string' for_free FStar_Range.dummyRange [] ed
  
let (sub_eff_to_string : FStar_Syntax_Syntax.sub_eff -> Prims.string) =
  fun se  ->
    let tsopt_to_string ts_opt =
      if FStar_Util.is_some ts_opt
      then
        let uu____3987 = FStar_All.pipe_right ts_opt FStar_Util.must  in
        FStar_All.pipe_right uu____3987 tscheme_to_string
      else "<None>"  in
    let uu____3994 = lid_to_string se.FStar_Syntax_Syntax.source  in
    let uu____3996 = lid_to_string se.FStar_Syntax_Syntax.target  in
    let uu____3998 = tsopt_to_string se.FStar_Syntax_Syntax.lift  in
    let uu____4000 = tsopt_to_string se.FStar_Syntax_Syntax.lift_wp  in
    FStar_Util.format4 "sub_effect %s ~> %s : lift = %s ;; lift_wp = %s"
      uu____3994 uu____3996 uu____3998 uu____4000
  
let rec (sigelt_to_string : FStar_Syntax_Syntax.sigelt -> Prims.string) =
  fun x  ->
    let basic =
      match x.FStar_Syntax_Syntax.sigel with
      | FStar_Syntax_Syntax.Sig_pragma (FStar_Syntax_Syntax.LightOff ) ->
          "#light \"off\""
      | FStar_Syntax_Syntax.Sig_pragma (FStar_Syntax_Syntax.ResetOptions
          (FStar_Pervasives_Native.None )) -> "#reset-options"
      | FStar_Syntax_Syntax.Sig_pragma (FStar_Syntax_Syntax.ResetOptions
          (FStar_Pervasives_Native.Some s)) ->
          FStar_Util.format1 "#reset-options \"%s\"" s
      | FStar_Syntax_Syntax.Sig_pragma (FStar_Syntax_Syntax.SetOptions s) ->
          FStar_Util.format1 "#set-options \"%s\"" s
      | FStar_Syntax_Syntax.Sig_pragma (FStar_Syntax_Syntax.PushOptions
          (FStar_Pervasives_Native.None )) -> "#push-options"
      | FStar_Syntax_Syntax.Sig_pragma (FStar_Syntax_Syntax.PushOptions
          (FStar_Pervasives_Native.Some s)) ->
          FStar_Util.format1 "#push-options \"%s\"" s
      | FStar_Syntax_Syntax.Sig_pragma (FStar_Syntax_Syntax.RestartSolver )
          -> "#restart-solver"
      | FStar_Syntax_Syntax.Sig_pragma (FStar_Syntax_Syntax.PopOptions ) ->
          "#pop-options"
      | FStar_Syntax_Syntax.Sig_inductive_typ
          (lid,univs1,tps,k,uu____4035,uu____4036) ->
          let quals_str = quals_to_string' x.FStar_Syntax_Syntax.sigquals  in
          let binders_str = binders_to_string " " tps  in
          let term_str = term_to_string k  in
          let uu____4052 = FStar_Options.print_universes ()  in
          if uu____4052
          then
            let uu____4056 = univ_names_to_string univs1  in
            FStar_Util.format5 "%stype %s<%s> %s : %s" quals_str
              lid.FStar_Ident.str uu____4056 binders_str term_str
          else
            FStar_Util.format4 "%stype %s %s : %s" quals_str
              lid.FStar_Ident.str binders_str term_str
      | FStar_Syntax_Syntax.Sig_datacon
          (lid,univs1,t,uu____4065,uu____4066,uu____4067) ->
          let uu____4074 = FStar_Options.print_universes ()  in
          if uu____4074
          then
            let uu____4078 = univ_names_to_string univs1  in
            let uu____4080 = term_to_string t  in
            FStar_Util.format3 "datacon<%s> %s : %s" uu____4078
              lid.FStar_Ident.str uu____4080
          else
            (let uu____4085 = term_to_string t  in
             FStar_Util.format2 "datacon %s : %s" lid.FStar_Ident.str
               uu____4085)
      | FStar_Syntax_Syntax.Sig_declare_typ (lid,univs1,t) ->
          let uu____4091 = quals_to_string' x.FStar_Syntax_Syntax.sigquals
             in
          let uu____4093 =
            let uu____4095 = FStar_Options.print_universes ()  in
            if uu____4095
            then
              let uu____4099 = univ_names_to_string univs1  in
              FStar_Util.format1 "<%s>" uu____4099
            else ""  in
          let uu____4105 = term_to_string t  in
          FStar_Util.format4 "%sval %s %s : %s" uu____4091
            lid.FStar_Ident.str uu____4093 uu____4105
      | FStar_Syntax_Syntax.Sig_assume (lid,us,f) ->
          let uu____4111 = FStar_Options.print_universes ()  in
          if uu____4111
          then
            let uu____4115 = univ_names_to_string us  in
            let uu____4117 = term_to_string f  in
            FStar_Util.format3 "val %s<%s> : %s" lid.FStar_Ident.str
              uu____4115 uu____4117
          else
            (let uu____4122 = term_to_string f  in
             FStar_Util.format2 "val %s : %s" lid.FStar_Ident.str uu____4122)
      | FStar_Syntax_Syntax.Sig_let (lbs,uu____4126) ->
          lbs_to_string x.FStar_Syntax_Syntax.sigquals lbs
      | FStar_Syntax_Syntax.Sig_main e ->
          let uu____4132 = term_to_string e  in
          FStar_Util.format1 "let _ = %s" uu____4132
      | FStar_Syntax_Syntax.Sig_bundle (ses,uu____4136) ->
          let uu____4145 =
            let uu____4147 = FStar_List.map sigelt_to_string ses  in
            FStar_All.pipe_right uu____4147 (FStar_String.concat "\n")  in
          Prims.op_Hat "(* Sig_bundle *)" uu____4145
      | FStar_Syntax_Syntax.Sig_new_effect ed ->
          let uu____4159 = FStar_Syntax_Util.is_dm4f ed  in
          eff_decl_to_string' uu____4159 x.FStar_Syntax_Syntax.sigrng
            x.FStar_Syntax_Syntax.sigquals ed
      | FStar_Syntax_Syntax.Sig_sub_effect se -> sub_eff_to_string se
      | FStar_Syntax_Syntax.Sig_effect_abbrev (l,univs1,tps,c,flags) ->
          let uu____4171 = FStar_Options.print_universes ()  in
          if uu____4171
          then
            let uu____4175 =
              let uu____4180 =
                FStar_Syntax_Syntax.mk
                  (FStar_Syntax_Syntax.Tm_arrow (tps, c))
                  FStar_Pervasives_Native.None FStar_Range.dummyRange
                 in
              FStar_Syntax_Subst.open_univ_vars univs1 uu____4180  in
            (match uu____4175 with
             | (univs2,t) ->
                 let uu____4194 =
                   let uu____4199 =
                     let uu____4200 = FStar_Syntax_Subst.compress t  in
                     uu____4200.FStar_Syntax_Syntax.n  in
                   match uu____4199 with
                   | FStar_Syntax_Syntax.Tm_arrow (bs,c1) -> (bs, c1)
                   | uu____4229 -> failwith "impossible"  in
                 (match uu____4194 with
                  | (tps1,c1) ->
                      let uu____4238 = sli l  in
                      let uu____4240 = univ_names_to_string univs2  in
                      let uu____4242 = binders_to_string " " tps1  in
                      let uu____4245 = comp_to_string c1  in
                      FStar_Util.format4 "effect %s<%s> %s = %s" uu____4238
                        uu____4240 uu____4242 uu____4245))
          else
            (let uu____4250 = sli l  in
             let uu____4252 = binders_to_string " " tps  in
             let uu____4255 = comp_to_string c  in
             FStar_Util.format3 "effect %s %s = %s" uu____4250 uu____4252
               uu____4255)
      | FStar_Syntax_Syntax.Sig_splice (lids,t) ->
          let uu____4264 =
            let uu____4266 = FStar_List.map FStar_Ident.string_of_lid lids
               in
            FStar_All.pipe_left (FStar_String.concat "; ") uu____4266  in
          let uu____4276 = term_to_string t  in
          FStar_Util.format2 "splice[%s] (%s)" uu____4264 uu____4276
       in
    match x.FStar_Syntax_Syntax.sigattrs with
    | [] -> Prims.op_Hat "[@ ]" (Prims.op_Hat "\n" basic)
    | uu____4282 ->
        let uu____4285 = attrs_to_string x.FStar_Syntax_Syntax.sigattrs  in
        Prims.op_Hat uu____4285 (Prims.op_Hat "\n" basic)
  
let (format_error : FStar_Range.range -> Prims.string -> Prims.string) =
  fun r  ->
    fun msg  ->
      let uu____4302 = FStar_Range.string_of_range r  in
      FStar_Util.format2 "%s: %s\n" uu____4302 msg
  
let (sigelt_to_string_short : FStar_Syntax_Syntax.sigelt -> Prims.string) =
  fun x  ->
    match x.FStar_Syntax_Syntax.sigel with
    | FStar_Syntax_Syntax.Sig_let
        ((uu____4313,{ FStar_Syntax_Syntax.lbname = lb;
                       FStar_Syntax_Syntax.lbunivs = uu____4315;
                       FStar_Syntax_Syntax.lbtyp = t;
                       FStar_Syntax_Syntax.lbeff = uu____4317;
                       FStar_Syntax_Syntax.lbdef = uu____4318;
                       FStar_Syntax_Syntax.lbattrs = uu____4319;
                       FStar_Syntax_Syntax.lbpos = uu____4320;_}::[]),uu____4321)
        ->
        let uu____4344 = lbname_to_string lb  in
        let uu____4346 = term_to_string t  in
        FStar_Util.format2 "let %s : %s" uu____4344 uu____4346
    | uu____4349 ->
        let uu____4350 =
          FStar_All.pipe_right (FStar_Syntax_Util.lids_of_sigelt x)
            (FStar_List.map (fun l  -> l.FStar_Ident.str))
           in
        FStar_All.pipe_right uu____4350 (FStar_String.concat ", ")
  
let (modul_to_string : FStar_Syntax_Syntax.modul -> Prims.string) =
  fun m  ->
    let uu____4374 = sli m.FStar_Syntax_Syntax.name  in
    let uu____4376 =
      let uu____4378 =
        FStar_List.map sigelt_to_string m.FStar_Syntax_Syntax.declarations
         in
      FStar_All.pipe_right uu____4378 (FStar_String.concat "\n")  in
    let uu____4388 =
      let uu____4390 =
        FStar_List.map sigelt_to_string m.FStar_Syntax_Syntax.exports  in
      FStar_All.pipe_right uu____4390 (FStar_String.concat "\n")  in
    FStar_Util.format3
      "module %s\nDeclarations: [\n%s\n]\nExports: [\n%s\n]\n" uu____4374
      uu____4376 uu____4388
  
let list_to_string :
  'a . ('a -> Prims.string) -> 'a Prims.list -> Prims.string =
  fun f  ->
    fun elts  ->
      match elts with
      | [] -> "[]"
      | x::xs ->
          let strb = FStar_Util.new_string_builder ()  in
          (FStar_Util.string_builder_append strb "[";
           (let uu____4440 = f x  in
            FStar_Util.string_builder_append strb uu____4440);
           FStar_List.iter
             (fun x1  ->
                FStar_Util.string_builder_append strb "; ";
                (let uu____4449 = f x1  in
                 FStar_Util.string_builder_append strb uu____4449)) xs;
           FStar_Util.string_builder_append strb "]";
           FStar_Util.string_of_string_builder strb)
  
let set_to_string :
  'a . ('a -> Prims.string) -> 'a FStar_Util.set -> Prims.string =
  fun f  ->
    fun s  ->
      let elts = FStar_Util.set_elements s  in
      match elts with
      | [] -> "{}"
      | x::xs ->
          let strb = FStar_Util.new_string_builder ()  in
          (FStar_Util.string_builder_append strb "{";
           (let uu____4496 = f x  in
            FStar_Util.string_builder_append strb uu____4496);
           FStar_List.iter
             (fun x1  ->
                FStar_Util.string_builder_append strb ", ";
                (let uu____4505 = f x1  in
                 FStar_Util.string_builder_append strb uu____4505)) xs;
           FStar_Util.string_builder_append strb "}";
           FStar_Util.string_of_string_builder strb)
  
let (bvs_to_string :
  Prims.string -> FStar_Syntax_Syntax.bv Prims.list -> Prims.string) =
  fun sep  ->
    fun bvs  ->
      let uu____4527 = FStar_List.map FStar_Syntax_Syntax.mk_binder bvs  in
      binders_to_string sep uu____4527
  
let rec (emb_typ_to_string : FStar_Syntax_Syntax.emb_typ -> Prims.string) =
  fun uu___15_4540  ->
    match uu___15_4540 with
    | FStar_Syntax_Syntax.ET_abstract  -> "abstract"
    | FStar_Syntax_Syntax.ET_app (h,[]) -> h
    | FStar_Syntax_Syntax.ET_app (h,args) ->
        let uu____4556 =
          let uu____4558 =
            let uu____4560 =
              let uu____4562 =
                let uu____4564 = FStar_List.map emb_typ_to_string args  in
                FStar_All.pipe_right uu____4564 (FStar_String.concat " ")  in
              Prims.op_Hat uu____4562 ")"  in
            Prims.op_Hat " " uu____4560  in
          Prims.op_Hat h uu____4558  in
        Prims.op_Hat "(" uu____4556
    | FStar_Syntax_Syntax.ET_fun (a,b) ->
        let uu____4579 =
          let uu____4581 = emb_typ_to_string a  in
          let uu____4583 =
            let uu____4585 = emb_typ_to_string b  in
            Prims.op_Hat ") -> " uu____4585  in
          Prims.op_Hat uu____4581 uu____4583  in
        Prims.op_Hat "(" uu____4579
  