Class {
	#name : #Correction,
	#superclass : #Object,
	#instVars : [
		'clicks',
		'variation'
	],
	#category : #BigI
}

{ #category : #'instance creation' }
Correction class >> fromClicks: someClicks andVariation: aVariation [

	^ self new
		  clicks: someClicks;
		  variation: aVariation;
		  yourself
]

{ #category : #accessing }
Correction >> clicks [

	^ clicks
]

{ #category : #accessing }
Correction >> clicks: someClicks [

	clicks := someClicks
]

{ #category : #testing }
Correction >> finalValueIsRight [

	^ self variation selectionClickIsRight: self clicks last
]

{ #category : #testing }
Correction >> finalValueIsWrong [

	^ self finalValueIsRight not
]

{ #category : #testing }
Correction >> initialValueIsRight [

	^ self variation selectionClickIsRight: self clicks first
]

{ #category : #testing }
Correction >> matchesPattern: aPattern [

	"Obscure method :) a pattern is a string asking for initial and final values combinations"

	"Can be ww, rr, wr, rw. For instance 'rw' -> initial value (r)ight / final value (w)rong"

	| matchesFirst matchesSecond |
	matchesFirst := self initialValueIsRight = (aPattern first = $r).
	matchesSecond := self finalValueIsRight = (aPattern second = $r).
	^ matchesFirst & matchesSecond
]

{ #category : #printing }
Correction >> printOn: aStream [

	| from to |
	from := self initialValueIsRight
		        ifTrue: [ 'r' ]
		        ifFalse: [ 'w' ].
	to := self finalValueIsRight
		      ifTrue: [ 'r' ]
		      ifFalse: [ 'w' ].
	super printOn: aStream.
	aStream << ' ('.
	aStream << self clicks first selectionKind.
	aStream << ' | '.
	aStream << (from , to).
	aStream << ')'
]

{ #category : #accessing }
Correction >> time [

	^ self clicks last dateAndTime - self clicks first dateAndTime
]

{ #category : #accessing }
Correction >> variation [

	^ variation
]

{ #category : #accessing }
Correction >> variation: aVariation [

	variation := aVariation
]
