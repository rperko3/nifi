/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
lexer grammar AttributeExpressionLexer;

@header {
	package org.apache.nifi.attribute.expression.language.antlr;
	import org.apache.nifi.attribute.expression.language.exception.AttributeExpressionLanguageParsingException;
}

@rulecatch {
  catch(final Exception e) {
    throw new AttributeExpressionLanguageParsingException(e);
  }
}

@members {
  public void displayRecognitionError(String[] tokenNames, RecognitionException e) {
    final StringBuilder sb = new StringBuilder();
    if ( e.token == null ) {
    	sb.append("Unrecognized token ");
    } else {
    	sb.append("Unexpected token '").append(e.token.getText()).append("' ");
    }
    sb.append("at line ").append(e.line);
    if ( e.approximateLineInfo ) {
    	sb.append(" (approximately)");
    }
    sb.append(", column ").append(e.charPositionInLine);
    sb.append(". Query: ").append(e.input.toString());
    
    throw new AttributeExpressionLanguageParsingException(sb.toString());
  }

  public void recover(RecognitionException e) {
  	final StringBuilder sb = new StringBuilder();
    if ( e.token == null ) {
    	sb.append("Unrecognized token ");
    } else {
    	sb.append("Unexpected token '").append(e.token.getText()).append("' ");
    }
    sb.append("at line ").append(e.line);
    if ( e.approximateLineInfo ) {
    	sb.append(" (approximately)");
    }
    sb.append(", column ").append(e.charPositionInLine);
    sb.append(". Query: ").append(e.input.toString());
    
    throw new AttributeExpressionLanguageParsingException(sb.toString());
  } 
}


// PUNCTUATION & SPECIAL CHARACTERS
WHITESPACE : (' '|'\t'|'\n'|'\r')+ { $channel = HIDDEN; };
COMMENT : '#' ( ~('\n') )* '\n' { $channel = HIDDEN; };

DOLLAR : '$';
LPAREN	: '(';
RPAREN	: ')';
LBRACE  : '{';
RBRACE  : '}';
COLON	: ':';
COMMA	: ',';
DOT		: '.';
SEMICOLON : ';';
NUMBER	: ('0'..'9')+;

TRUE	: 'true';
FALSE	: 'false';

//
// FUNCTION NAMES
//

// ATTRIBUTE KEY SELECTION FUNCTIONS
ANY_ATTRIBUTE : 'anyAttribute';
ANY_MATCHING_ATTRIBUTE : 'anyMatchingAttribute';
ALL_ATTRIBUTES : 'allAttributes';
ALL_MATCHING_ATTRIBUTES : 'allMatchingAttributes';
ANY_DELINEATED_VALUE : 'anyDelineatedValue';
ALL_DELINEATED_VALUES : 'allDelineatedValues';

// NO-SUBJECT FUNCTIONS
NEXT_INT	: 'nextInt';
IP	: 'ip';
UUID : 'UUID';
HOSTNAME : 'hostname';	// requires boolean arg: prefer FQDN
NOW	: 'now';


// 0 arg functions
TO_UPPER : 'toUpper';
TO_LOWER : 'toLower';
TO_STRING : 'toString';
LENGTH : 'length';
TRIM	: 'trim';
IS_NULL	: 'isNull';
IS_EMPTY : 'isEmpty';
NOT_NULL : 'notNull';
TO_NUMBER : 'toNumber';
URL_ENCODE : 'urlEncode';
URL_DECODE : 'urlDecode';
NOT : 'not';
COUNT : 'count';
RANDOM : 'random';

// 1 arg functions
SUBSTRING_AFTER	: 'substringAfter';
SUBSTRING_BEFORE : 'substringBefore';
SUBSTRING_AFTER_LAST : 'substringAfterLast';
SUBSTRING_BEFORE_LAST : 'substringBeforeLast';
STARTS_WITH : 'startsWith';
ENDS_WITH : 'endsWith';
CONTAINS : 'contains';
PREPEND	: 'prepend';
APPEND	: 'append';
INDEX_OF : 'indexOf';
LAST_INDEX_OF : 'lastIndexOf';
REPLACE_NULL : 'replaceNull';
REPLACE_EMPTY : 'replaceEmpty';
FIND	: 'find';	// regex
MATCHES : 'matches';	// regex
EQUALS	: 'equals';
EQUALS_IGNORE_CASE : 'equalsIgnoreCase';
GREATER_THAN	: 'gt';
LESS_THAN		: 'lt';
GREATER_THAN_OR_EQUAL	: 'ge';
LESS_THAN_OR_EQUAL		: 'le';
FORMAT			: 'format'; // takes string date format; uses SimpleDateFormat
TO_DATE			: 'toDate'; // takes string date format; converts the subject to a Long based on the date format
MOD : 'mod';
PLUS : 'plus';
MINUS : 'minus';
MULTIPLY : 'multiply';
DIVIDE : 'divide';
TO_RADIX : 'toRadix';
OR : 'or';
AND : 'and';
JOIN : 'join';
TO_LITERAL : 'literal';

// 2 arg functions
SUBSTRING	: 'substring';
REPLACE	: 'replace';
REPLACE_ALL : 'replaceAll';

// 4 arg functions
GET_DELIMITED_FIELD	: 'getDelimitedField';

// STRINGS
STRING_LITERAL
@init{StringBuilder lBuf = new StringBuilder();}
	:
		(
			'"'
				(
					escaped=ESC {lBuf.append(getText());} |
				  	normal = ~( '"' | '\\' | '\n' | '\r' | '\t' ) { lBuf.appendCodePoint(normal);} 
				)*
			'"'
		)
		{
			setText(lBuf.toString());
		}
		|
		(
			'\''
				(
					escaped=ESC {lBuf.append(getText());} |
				  	normal = ~( '\'' | '\\' | '\n' | '\r' | '\t' ) { lBuf.appendCodePoint(normal);} 
				)*
			'\''
		)
		{
			setText(lBuf.toString());
		}
		;


fragment
ESC
	:	'\\'
		(
				'"'		{ setText("\""); }
			|	'\''	{ setText("\'"); }
			|	'r'		{ setText("\r"); }
			|	'n'		{ setText("\n"); }
			|	't'		{ setText("\t"); }
			|	'\\'	{ setText("\\\\"); }
			|	nextChar = ~('"' | '\'' | 'r' | 'n' | 't' | '\\')		
				{
					StringBuilder lBuf = new StringBuilder(); lBuf.append("\\\\").appendCodePoint(nextChar); setText(lBuf.toString());
				}
		)
	;

ATTRIBUTE_NAME : (
				  ~('$' | '{' | '}' | '(' | ')' | '[' | ']' | ',' | ':' | ';' | '/' | '*' | '\'' | ' ' | '\t' | '\r' | '\n' | '0'..'9')
				  ~('$' | '{' | '}' | '(' | ')' | '[' | ']' | ',' | ':' | ';' | '/' | '*' | '\'' | ' ' | '\t' | '\r' | '\n')*
				 );
