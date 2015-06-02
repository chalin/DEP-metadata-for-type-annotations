@a library lib;
@a import 'anno.dart';
@a export 'anno.dart';
@a part 'some_part.dart';

// Class definition
@a class C<@a T extends /*@*/Object> 
  extends /*@*/Object 
  with /*@?*/ Mixin
  implements /*@*/Interface</*@*/ C>
{
  // Constructor, possibly qualified as external, const and/or factory
  @a external factory /*@*/ C();
  
  // Getter and setter, possibly external and/or static
  @a external /*@*/ T get v;
  @a external /*@*/ void set v(@a T _);
  
  // Operator, possibly external
  @a external /*@*/ T operator -();
  
  // Method, possibly external and/or static
  @a external /*@*/ T f(@a final /*@*/ T p, @a T g());

  // Instance variable, possibly static and/or final|const
  @a final /*@*/ T t;
  @a var /*@*/ d;
}

// Enum
@a enum E { e }

// Typedef
@a typedef int Id(int);

// Function, getter, setter, possibly external
@X external /*@!*/ int gf();
@X external /*@*/ int get gv;
@X external /*@*/ set gv(_);

// Library variable, possibly final|const
@a const /*@*/ int c = 0;

void statements() {
  // Local variable, possibly final|cost have extended 
  // support like for other variables
  // (also appears in for loops)
  @a var /*@*/ d = 0;
  @a final /*@*/ Object o
    // New/const expressions
    = new /*@*/ Object();
  
  // Tear-offs ?
  // ... = new /*@*/ Object#
  
  // try-catch statements
  try { 1; } 
  on /*@?*/ C</*@*/ int> catch (e) {
    
  }
  
  // Type cast & type test
  String s = o as /*@*/ String;
  bool b = o is /*@*/ String;
}
