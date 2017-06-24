grammar A3Code;

//---------------------------------------------------------------------------------------------------
// Session 1: ANTLR API, You SHOULD NOT make any modification to this session
//---------------------------------------------------------------------------------------------------
@header {

import java.io.*;
}

@parser::members {

public enum DataType {
	INT, BOOLEAN, INVALID
}

public class Symbol {
	String name;
	DataType dt;

	Symbol (String n, DataType d) {
		name = n;
		dt = d;
	}

	Symbol (int id, DataType d) {
		name = "t_" + id;
		dt = d;
	}

	boolean Equal (String n) {
		return (name.equals(n));
	}

	DataType GetType () {
		return dt;
	}

	String GetName () {
		return name;
	}

	void Print() {
		System.out.println(name + "\t" + dt);
	}
}

public class SymTab {
	
	Symbol st[];
	int size;
	int temps;

	SymTab () {
		st = new Symbol[1000];
		size = 0;
		temps = 0;
	}

	int Find (String n) {
		for (int  i = 0; i < size; i ++) {
			if (st[i].Equal(n)) return i;
		}
		return -1;
	}

	int insert(String n, DataType d) {
		int id = Find(n);
		if (id != -1) return id;
	
		st[size] = new Symbol(n, d);
		return (size ++);
	}

	int Add (DataType d) {
		st [size] = new Symbol (temps, d);
		temps ++;
		return (size ++);
	}

	DataType GetType (int id) {
		if (id == -1) return DataType.INVALID;
		return (st[id].GetType());
	}

	String GetName (int id) {
		if (id == -1) return ("");
		return (st[id].GetName()); 
	}

	void Print() {
		for (int  i = 0; i < size; i ++) {
			st[i].Print();
		}
	}
}

SymTab s = new SymTab();

public class Quad {
	int label;
	String op;
	int src1;
	int src2;
	int dst;

	Quad (int l, int d, int s1, int s2, String o) {
		label = l;
		dst = d;
		src1 = s1;
		src2 = s2;
		op = o;
	}

	void Print () {
		System.out.println("L_" + label + ": " + s.GetName(dst) + " = " 
				+ s.GetName(src1) + " " + op + " " + s.GetName(src2));
	}
}

public class QuadTab {
	Quad qt[];
	int size;

	QuadTab () {
		qt = new Quad[1000];
		size = 0;
	}

	int Add(int dst, int src1, int src2, String op) {
		qt[size] = new Quad(size, dst, src1, src2, op);
		return (size ++);
	}

	void Print() {
		for (int  i = 0; i < size; i ++) {
			qt[i].Print();
		}
	}
}

QuadTab q = new QuadTab();

}

//---------------------------------------------------------------------------------------------------
// Session 2: Fill your code here
//---------------------------------------------------------------------------------------------------
prog
: Class Program '{' field_decls method_decls '}'
{
	s.Print();
	System.out.println("------------------------------------");
	q.Print();
}
;

field_decls 
: f=field_decls field_decl ';'
| f=field_decls inited_field_decl ';'
| 
;

field_decl returns [DataType t]
: f=field_decl ',' Ident
{
	$t = $f.t;
	s.insert($Ident.text, $t);
}
| f=field_decl ',' Ident '[' num ']'
{
}
| Type Ident
{
	$t = DataType.valueOf($Type.text.toUpperCase());
	s.insert($Ident.text, $t);
}
| Type Ident '[' num ']'
{
}
;

inited_field_decl returns [int id]
: Type Ident '=' literal 
{
}
;

method_decls 
: m=method_decls method_decl
|
;

method_decl
: Type Ident '(' params ')' block
{
	s.insert($Ident.text, DataType.valueOf($Type.text.toUpperCase()));
}
| Void Ident '(' params ')' block
{
}
;

params returns [int id]
: Type Ident nextParams
{
}
|
{
}
;

nextParams
: n=nextParams ',' Type Ident
{
}
|
{
}
;

block
: '{' var_decls statements '}'
;

var_decls
: v=var_decls var_decl ';'
| 
;

var_decl returns [DataType t]
: v=var_decl ',' Ident
{
	$t = $v.t;
	s.insert($Ident.text, $t);
}
| Type Ident
{
	$t = DataType.valueOf($Type.text.toUpperCase());
	s.insert($Ident.text, $t);
}
;

statements
: statement t=statements
|
;

statement
: location eqOp expr ';'          // TODO: add rules for other assignments
{
	q.Add($location.id, $expr.id, -1, "=");
}
| If '(' expr ')' block
{
}
| If '(' expr ')' b1=block Else b2=block
{
}
| For Ident '=' e1=expr ',' e2=expr block
{
}
| Ret ';'
{
}
| Ret '(' expr ')' ';'
{
}
| Brk ';'
{
}
| Cnt ';'
{
}
| block
{
}
| methodCall ';'
{
}
;

methodCall returns [int id]
: Ident '(' args ')'
{
}
| Callout '(' Str calloutArgs ')'
{
}
;

args 
: someArgs
{
}
|
{
}
;

someArgs
: t=someArgs ',' expr
{
}
| expr
{
}
;

calloutArgs 
: c=calloutArgs ',' expr
{
}
| c=calloutArgs ',' Str
{
}
|
{
}
;

expr returns [int id]
: literal
{
	$id = $literal.id;
}
| location
{
	$id = $location.id;
}
| '(' e=expr ')'
{
}
| SubOp e=expr
{
}
| '!' e=expr
{
}
| e1=expr MulDiv e2=expr
{
}
| e1=expr AddOp e2=expr
{
	$id = s.Add(s.GetType($e1.id));
	q.Add($id, $e1.id, $e2.id, "+");
}
| e1=expr SubOp e2=expr
{
}
| e1=expr RelOp e2=expr
{
}
| e1=expr AndOp e2=expr
{
}
| e1=expr OrOp e2=expr
{
}
| methodCall
{
}
;

location returns [int id]
:Ident
{
	$id = s.Find($Ident.text);
}
| Ident '[' expr ']'
{
}
;

num
: DecNum
| HexNum
;

literal returns [int id]
: num
{
	$id = s.insert($num.text, DataType.INT);
}
| Char
| BoolLit
;

eqOp
: '='
| AssignOp
;
//--------------------------------------------- END OF SESSION 2 -----------------------------------

//---------------------------------------------------------------------------------------------------
// Session 3: Lexical definition, You SHOULD NOT make any modification to this session
//---------------------------------------------------------------------------------------------------
fragment Delim
: ' '
| '\t'
| '\n'
;

fragment Letter
: [a-zA-Z]
;

fragment Digit
: [0-9]
;

fragment HexDigit
: Digit
| [a-f]
| [A-F]
;

fragment Alpha
: Letter
| '_'
;

fragment AlphaNum
: Alpha
| Digit
;

WhiteSpace
: Delim+ -> skip
;

Char
: '\'' ~('\\') '\''
| '\'\\' . '\'' 
;

Str
:'"' ((~('\\' | '"')) | ('\\'.))* '"'
; 

Class
: 'class'
;

Program
: 'Program'
;

Void
: 'void'
;

If
: 'if'
;

Else
: 'else'
;

For
: 'for'
;

Ret
: 'return'
;

Brk
: 'break'
;

Cnt
: 'continue'
;

Callout
: 'callout'
;

DecNum
: Digit+
;

HexNum
: '0x'HexDigit+
;

BoolLit
: 'true'
| 'false'
;

Type
: 'int'
| 'boolean'
;

Ident
: Alpha AlphaNum* 
;

RelOp
: '<='
| '>=' 
| '<'
| '>'
| '=='
| '!='
;

AssignOp
: '+='
| '-='
;

MulDiv
: '*'
| '/'
| '%'
;

AddOp
: '+'
;

SubOp
: '-'
;

AndOp
: '&&'
;

OrOp
: '||'
;
//--------------------------------------------- END ----------------------------------------------