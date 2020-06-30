(**
 * @author YAMATODANI Kiyoshi
 * @copyright 2010, Tohoku University.
 *)
structure Grep =
struct

  structure MBS = MultiByteText.String
  structure MBSS = MultiByteText.Substring

  fun grep pattern =
      let
        val regexp = RegExp.compileString pattern
      in
        fn text =>
           case RegExp.find regexp MBSS.getc text
            of SOME(MatchTree.Match (SOME{len, pos}, _), _) =>
               SOME(MBSS.string(MBSS.slice(pos, 0, SOME len)))
             | _ => NONE
      end
          
  fun grep' pattern =
      let
        val search =
            Option.map MBS.MBSToString o (grep (MBS.stringToMBS pattern))
      in
        fn text => search (MBSS.full (MBS.stringToMBS text))
      end

  fun main (commandName, codec :: pattern :: args) =
      let
        val _ = MultiByteText.setDefaultCodec(MultiByteText.getCodec codec)
        val instream = 
            case args
             of [] => TextIO.stdIn
              | fileName :: _ => TextIO.openIn fileName
        val search = grep (MBS.stringToMBS pattern)
        fun loop () =
            case TextIO.inputLine instream
             of NONE => ()
              | SOME line => 
                (
                  case search (MBSS.full (MBS.stringToMBS line))
                   of NONE => ()
                    | SOME matched =>
                      (print (MBS.MBSToString matched); print "\n");
                  loop ()
                )
      in
        loop (); OS.Process.success (* file will be closed at exit. *)
      end
end;

(* unix, mac
SMLofNJ.exportFn ("grep", Grep.main);
*)
(* windows
SMLofNJ.exportFn ("grep", fn (c, args) => Grep.main (c, tl args));
*)

(*
structure MB = MultiByteString;
structure MBS = MBString;
structure MBSS = MBSubstring;

MB.setDefaultCodecName "Shift_JIS";
MB.setDefaultCodecName "ASCII";
Option.map print (Grep.grep' "(��|�p)a.��?��+"  "abc�p��ab����ccd");
Option.map print (Grep.grep' "��..." "abc�����a123����xyz");
Grep.grep' "(x|y)a" "abcxabc";
Grep.grep' "c(x|y)a" "xabcxabc";
Grep.grep' "b" "abcccd";
*)