# Metadata for Type Annotations

- v0.1.2, 2015-06-05.

## Contact information

- [Patrice Chalin][], @[chalin][], [chalin@dsrg.org](mailto:chalin@dsrg.org)
- **[DEP][] home**: [github.com/chalin/DEP-metadata-for-type-annotations][DEP-metadata-for-type-annotations].
+ **Additional stakeholders**:
    - Leaf Petersen, @[leafpetersen](https://github.com/leafpetersen), [Dart Dev Compiler][] team.

## Contents

- [1 Summary](#1-summary)
- [2 Motivation](#2-motivation)
    - [2.1 Precedent: JSR-308 - Type Annotations and Pluggable Type Systems](#21-precedent-jsr-308---type-annotations-and-pluggable-type-systems)
    - [2.2 Dart](#22-dart)
- [3 Examples](#3-examples)
- [4 Proposal details: syntax](#4-proposal-details-syntax)
    - [4.1 Introduction](#41-introduction)
    - [4.2 Library and part declarations](#42-library-and-part-declarations)
    - [4.3 Statements](#43-statements)
        - [(a) Local variable declarations](#a-local-variable-declarations)
        - [(b) Try-catch statements](#b-try-catch-statements)
    - [4.4 Expressions](#44-expressions)
        - [(a) New/const](#a-newconst)
        - [(b) Type cast and type test](#b-type-cast-and-type-test)
    - [4.5 Constructor and receiver qualification](#45-constructor-and-receiver-qualification)
        - [(a) Constructor qualification](#a-constructor-qualification)
        - [(b) Receiver qualification](#b-receiver-qualification)
        - [(c) Literals](#c-literals)
- [5 Proposal details: semantics](#5-proposal-details-semantics)
    - [5.1 Static semantics: no change](#51-static-semantics-no-change)
    - [5.2 Dynamic semantics](#52-dynamic-semantics)
- [6 Alternatives, implications and limitations](#6-alternatives-implications-and-limitations)
- [7 Deliverables](#7-deliverables)
- [References](#references)

## 1 Summary

Metadata in Dart is ([DSS][] 15):

> used to attach user defined annotations to program structures. ... Metadata is associated with the abstract syntax tree of the program construct p that immediately follows the metadata ...

In the spirit of [JSR-308][], this is a proposal to extend the places where metadata can appear to include all type annotations.

## 2 Motivation

<a name="precedent"></a>

### 2.1 Precedent: JSR-308 - Type Annotations and Pluggable Type Systems

In the spring of 2014, the Java 8 release included support for [JSR-308][], which (like this proposal) extended the use of Java metadata to include (essentially) all places where types are used. Enabling type annotation qualification in this manner effectively provides a mechanisms for _modularly_ **extending** the static **type system**. Concretely, this is achieved through the use of static checkers implemented as compiler plug-ins. For more information concerning these features, see the Java tutorial on "_[Type Annotations and Pluggable Type Systems][]_". Such Java type system extensions exist for, e.g.:

- Non-null types ([Nullness Checker][])
- Immutable types ([IGJ][], [Javari][])
- Regular expression types (encoded as strings, [Regex Checker][])
- Tainted value types ([Tainting Checker][])

These are among the 20 checkers of the [Checker Framework][], which was created by the team that lead the development of the JSR itself. Further details concerning [JSR-308][], including a discussion of the utility of type annotations, can be found in the [JSR-308 FAQ][], and the Oracle Technology Network article "_[JSR 308 Explained: Java Type Annotations][JSR-308 explained]_".

### 2.2 Dart

Broadening support for metadata was first mentioned at the [DEP 2015/03/18][] meeting. Realization of this proposal will provide a core mechanism in support of Dart nullity meta type annotations ([DEP-non-null][]), and a forthcoming proposal on immutable types.

## 3 Examples

Here are some Dart examples inspired, in part, by the type system extensions listed in [Section 2.1](#precedent):

```dart
@NonNull E e = new List<@NonNull E>.from(...).sort(f).first;
@FixedLength List<T> list = new @FixedLength List<T>(10);
@Immutable Map m = new @Immutable Map<String,int>.unmodifiable(...);
@RegExp(1) String pattern = r"^http://www.example.com/#([^?]+)";

class DbConnection {
  Future<Results> query(@Untainted String sql)
  ...
}
```

## 4 Proposal details: syntax

### 4.1 Introduction

According to the language specification ([DSS][] 15):

> Metadata can appear before a library, part header, class, typedef, type parameter, constructor, factory, function, field, parameter, or variable declaration and before an import, export or part directive.

Consider the following declaration of a metadata annotation class and two metadata annotations:

```dart
class Anno { const Anno(); }
const a = const Anno();
const X = a;
```

The next section provides a prototypical library definition containing 

- `@a` at all program points where metadata annotations are currently valid.
- `/*@*/` at program points where metadata annotation support is to be added.

As is mentioned in [Section 7](#7-deliverables), there are discrepancies between the grammar contained in the language specification ([DSS][]) and the language accepted by current tools. `@X` marks program points where annotations are accepted by tooling but should be rejected according to the grammar. The converse situation is marked using `/*@!*/`.

The following auxiliary definitions are also used:

```dart
class Mixin {}
abstract class Interface<T> {}
```

### 4.2 Library and part declarations

```dart
@a library lib;
@a import 'anno.dart';
@a export 'anno.dart';
@a part 'some_part.dart';

// Class definition
@a class C<@a T extends /*@*/Object> 
  extends /*@*/Object 
  with /*@*/ Mixin
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
@a typedef /*@*/ int Id(/*@*/ int);

// Function, getter, setter, possibly external
@X external /*@!*/ int gf();
@X external /*@*/ int get gv;
@X external /*@*/ set gv(_);

// Library variable, possibly final|const
@a const /*@*/ int c = 0;
```

Hence, metadata annotation support is being added for:

1. Class supertype, mixin and interface specifications.
2. Type parameter upper bounds.
3. Constructors.
4. Getter, setter, operator and method:
    - Return types.
    - Parameter types.
5. Instance variable types.
6. Library function, getter and setter:
    - Return types.
    - Parameter types.
7. Library variable types.

Here is the library part used above:

```dart
@a part of lib;
...
```

No new syntax is needed specifically for parts. We cover statements and expressions next.

### 4.3 Statements

#### (a) Local variable declarations

New metadata annotations locations for local variable declarations (including for-loop instances) shall be the same as for variable declarations treated in the previous section.

#### (b) Try-catch statements

```dart
  try {
    ...
  } on /*@*/ T catch (e) {
    ...
  }
```

### 4.4 Expressions

#### (a) New/const

> Comment. Including tear-offs ([DEP-generalizedTearOffs][]).

```dart
  new /*@*/ Object();
  new /*@*/ Object#
```

#### (b) Type cast and type test


```dart
  String s = o as /*@*/ String;
  bool b = o is /*@*/ String;
```

### 4.5 Constructor and receiver qualification

#### (a) Constructor qualification

Beyond the simple qualification of (factory or generative) constructors with metadata annotations as presented above, it is sometimes necessary to also qualify type parameters of individual generic constructors as we illustrate next. Consider the following two hypothetical factory constructors for the [`List<E>` type][Dart List API] (the example is hypothetical only because we have split the `factory List([int length])` constructor in two):

```dart
abstract class List<E> implements Iterable<E>, EfficientLength {
  external factory List();
  external factory @FixedLength List<@Nullable E>.nullFilled(int length);
  ...
}
```

This declares

- `List()` as returning a (growable) list of elements of type `E` (which itself may be non-null or nullable);
- `List.nullFilled(int length)` yields a fixed-size list of `null` elements (of type `@Nullable E`).

E.g., the type of `new List<@NonNull int>.nullFilled(10)` would be `List<@Nullable int>`. The declaration of `List.nullFilled()` would constrain the type parameter `E` to be nullable.

#### (b) Receiver qualification

Similar to what has been described for constructors, receiver qualification for methods, getters, setters and operators places constraints on the type of `this`. E.g.,

```dart
int @Readonly Iterable<@Readonly E>.get length {...}
```

can be interpreted as documenting the constraint that the `Iterable` getter named `length` changes neither the iterable elements, nor the receiver; i.e., the type of the receiver must be a subtype of `@Readonly Iterable<@Readonly E>`.

> Comment. JSR-308 introduced special syntax for [receiver qualification][]: `this` can be added as an explicit first parameter to an instance method. Our example above would be written in Java 8 as a method as follows: `int getLength(@Readonly Iterable<@Readonly E> this)`.

[receiver qualification]: http://types.cs.washington.edu/jsr308/specification/java-annotation-design.html#receivers

#### (c) Literals

We extend the constructor qualification to `List` and `Map` literals (given that such literals can be seen as an implicit application of an appropriate constructor). E.g.,

```dart
  @FixedLength <@Immutable T>[...]
```

> Comment. It may be useful to consider allowing, as part of this proposal, all literals to be annotated with metadata.

## 5 Proposal details: semantics

### 5.1 Static semantics: no change

This proposal does not impact Dart's static semantics. I.e., occurrences of metadata annotations at the new program points permitted by this proposal, will be processed in the same manner as annotations in other locations are currently processed.

> Comment. It may be useful to consider how the Dart Analyzer, or Analyzer Server, could be enhanced to support checker plug-ins.

### 5.2 Dynamic semantics

With respect to runtime support, the language specification reads ([DSS][] 15, "Metadata"):

> Metadata can be retrieved at runtime via a reflective call, provided the annotated program construct p is accessible via reflection.

Metadata type annotations such as immutability could be useful at runtime, e.g., for [Angular][] apps. In both the [Angular][] core and generated apps, every effort is being made to avoid the use of reflection. Hence, it may be beneficial to consider allowing "query access" to metadata associated with an object instance (as associated with the instance at the point of creation via an [annotated `new`/`const` expression](#a-newconst). For example:

```dart
@Immutable List<String> list = new @Immutable List<String>.from(...);
List<String> list2 = list;
...
if(list2 is @Mutable List) {
  list2.add(...);
}
```

## 6 Alternatives, implications and limitations

The [DEP][] on _Non-null types and non-null-by-default_ ([DEP-non-null][]) can be seen as a concrete application of this proposal, although it makes use of the (now somewhat conventional) specialized tokens `?` and `!` instead of `@Nullable` and `@NonNull`, respectively ([DEP-non-null, B.4.6][]).

The changes proposed here are, in a technical sense, entirely backwards compatible. Practically speaking though, some fielded code may need to have annotations moved (to the right of one or more keywords) so that they are immediately preceding a type annotation; e.g., from

```dart
@NonNull final int i = 0;
```

to

```dart
final @NonNull int i = 0;
```

In Java, metadata annotations have a:

- [RetentionPolicy][]: source, class or runtime.
- Target [ElementType][]s.

Dart has only one retention policy, namely runtime, and there is no target specification. Consideration of the latter might be useful.

Going beyond support of metadata annotations for types, one might consider further extending support to any expression. But this is not considered here, as our current use cases are support of newly proposed type system enhancements.

## 7 Deliverables

Our original intent was to describe specific changes to the Dart grammar as it is documented in the [DSS][], but unfortunately, the [DSS][] grammar does not match the language accepted by tools (e.g., see occurrences of `@X` and `/*@!*/` in the library example of [Section 4.2](#42-library-and-part-declarations)). Once discrepancies are addressed we will produce an updated version of the language specification and its grammar rules.

## References

The main normative reference for this proposal is the *ECMA [Dart Specification Standard][DSS]*, 2nd Edition (December 2014, Dart v1.6) which we abbreviate as [DSS][]. 

[Angular]: https://angular.io
[Checker Framework]: http://checkerframework.org
[DEP 2015/03/18]: https://github.com/dart-lang/dart_enhancement_proposals/blob/master/Meetings/2015-03-18%20DEP%20Committee%20Meeting.md#more-proposals
[DEP-generalizedTearOffs]: https://github.com/gbracha/generalizedTearOffs
[DEP-metadata-for-type-annotations]: https://github.com/chalin/DEP-metadata-for-type-annotations
[DEP-non-null, B.4.6]: https://github.com/chalin/DEP-non-null/blob/master/doc/dep-non-null-AUTOGENERATED-DO-NOT-EDIT.md#type-anno-alt
[DEP-non-null]: https://github.com/chalin/DEP-non-null
[DEP]: https://github.com/dart-lang/dart_enhancement_proposals
[DSS]: http://www.ecma-international.org/publications/standards/Ecma-408.htm
[Dart Dev Compiler]: https://github.com/dart-lang/dev_compiler
[Dart List API]: https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart:core.List
[ElementType]: http://docs.oracle.com/javase/8/docs/api/java/lang/annotation/ElementType.html
[IGJ]: http://types.cs.washington.edu/checker-framework/current/checker-framework-manual.html#igj-checker
[JSR-308 FAQ]: http://types.cs.washington.edu/jsr308/current/jsr308-faq.html
[JSR-308 explained]: http://www.oracle.com/technetwork/articles/java/ma14-architect-annotations-2177655.html
[JSR-308]: https://jcp.org/en/jsr/detail?id=308
[Java]: http://java.com
[Javari]: http://types.cs.washington.edu/checker-framework/current/checker-framework-manual.html#javari-checker
[Nullness Checker]: http://types.cs.washington.edu/checker-framework/current/checker-framework-manual.html#nullness-checker
[Patrice Chalin]: https://plus.google.com/+PatriceChalin
[Regex Checker]: http://types.cs.washington.edu/checker-framework/current/checker-framework-manual.html#regex-checker
[RetentionPolicy]: http://docs.oracle.com/javase/8/docs/api/java/lang/annotation/RetentionPolicy.html
[Tainting Checker]: http://types.cs.washington.edu/checker-framework/current/checker-framework-manual.html#tainting-checker
[Type Annotations and Pluggable Type Systems]: https://docs.oracle.com/javase/tutorial/java/annotations/type_annotations.html
[chalin]: https://github.com/chalin
