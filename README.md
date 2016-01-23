# ND: (yet another) Non-Deterministic programming language

This is a proof-of-concept programming language, inspired by Algol, Golog, and others. The syntax is just S-expressions (like LISP) because I don't want to define one.

The programming constructs are those from classical programming languages, plus some non-deterministic constructs.

## Programming constructs

```
(if condition program)
```
Executes `program` if `condition` holds. Condition can be any *boolean expression*.
&nbsp;

```
(while condition program)
```
Execute `program` if `condition` holds, and repeat it until `condition` doesn't hold anymore. `condition` can be any *boolean expression*.
&nbsp;

```
(set variable expression)
```
Assign to `variable` the value of `expression`. `expression` can be any *algebraic expression*.
&nbsp;

```
(print expression)
```
Print the value of `expression`. `expression` can be any *algebraic expression*.
&nbsp;

```
(program1 program2)
```
Sequence of programs. Execute `program1` followed by `program2`. Can be used with more than two arguments, like `(p1 p2 p3)` which is a shorthand for `((p1 p2) p3)`.
&nbsp;

```
(assert condition)
```
`condition` must hold, otherwise the program will backtrack and possibly fail to execute. `condition` can be any *boolean expression*.
&nbsp;

```
(choose program1 program2)
```
Non-deterministically execute `program1` or `program2`.
&nbsp;

```
(domain variable expr1 expr2 ... exprN)
```
Non-deterministically set the value of `variable` to one of the specified expressions. Has the same effect as `(choose (set variable expr1) (set variable expr2) ... (set variable exprN))`.
&nbsp;

```
(repeat program)
```
Non-deterministically repeat the execution of `program` (zero or more times).
&nbsp;

```
(def function (arg1 arg2 ... argN) program)
```
Define a procedure. The procedure can be called with `(function expr1 expr2 ... exprN)` where in the function body the value of `expr1` (evaluated as an *algebraic expression*) will be available as a variable named `arg1` and so on.
&nbsp;

## Boolean expressions
```
(and boolean_expr1 boolean_expr2)
```
Will evaluate to true if both expressions are true, otherwise will evaluate to false. Can be used with more than two arguments, like `(and e1 e2 e3)` which is a shorthand for `(and (and e1 e2) e3)`.
&nbsp;

```
(or boolean_expr1 boolean_expr2)
```
Will evaluate to false if both expressions are false, otherwise will evaluate to true. Can be used with more than two arguments, like `(or e1 e2 e3)` which is a shorthand for `(or (or e1 e2) e3)`.
&nbsp;

```
(not boolean_expr1)
```
Will evaluate to true if the expression is false and vice versa.
&nbsp;

```
(= expr1 expr2)
(> expr1 expr2)
(< expr1 expr2)
```
Will evaluate to true if the value of `expr1` is equal (`=`), greater (`>`) or less (`<`) than the value of `expr2`.
&nbsp;

## Algebraic expressions
```
const
```
A constant integer value.
&nbsp;

```
variable
```
A variable name. Will produce a runtime error if the variable does not exist.
&nbsp;

```
(+ expr1 expr2)
(- expr1 expr2)
(* expr1 expr2)
(/ expr1 expr2)
```
Mathematical operators. Can be used with more than two arguments, like `(+ e1 e2 e3)`, which is a shorthand for `(+ (+ e1 e2) e3)`.
&nbsp;

## Examples

TODO
&nbsp;

## TODO

- [ ] Examples
- [ ] Type system
- [ ] Lists
- [ ] more
