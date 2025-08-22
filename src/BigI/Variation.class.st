Class {
	#name : #Variation,
	#superclass : #Object,
	#instVars : [
		'id',
		'movie',
		'version',
		'time',
		'iterations',
		'distance',
		'seat'
	],
	#classVars : [
		'variations'
	],
	#category : #BigI
}

{ #category : #'instance creation' }
Variation class >> all [

	^ self variations
]

{ #category : #'instance creation' }
Variation class >> fromJSON: aDictionary [

	^ self new
		  id: (aDictionary at: #id);
		  movie: (aDictionary at: #movie);
		  version: (aDictionary at: #version);
		  time: (aDictionary at: #time);
		  distance: (aDictionary at: #distance);
		  seat: (aDictionary at: #seat);
		  iterations: (aDictionary at: #iterationLimit);
		  yourself
]

{ #category : #'instance creation' }
Variation class >> resetVariations [

	variations := nil
]

{ #category : #'instance creation' }
Variation class >> variations [

	variations ifNil: [ 
		| variationsJson |
		variationsJson := NeoJSONReader fromString:
			                  '/Users/juliangrigera/Desktop/Big-I/flat_variations.js'
				                  asFileReference contents.

		variations := variationsJson collect: [ :json | self fromJSON: json ] ].
	^ variations
]

{ #category : #'instance creation' }
Variation class >> withId: anId [

	^ self all detect: [ :variation | variation id asNumber == anId asNumber ]
]

{ #category : #testing }
Variation >> dateIsRight: aClickEvent [

	^ true
]

{ #category : #accessing }
Variation >> distance [

	^ distance
]

{ #category : #accessing }
Variation >> distance: aString [

	distance := aString
]

{ #category : #private }
Variation >> distanceFor: aTheatreId [

	| distances |
	distances := { 
		             (1 -> '0.5 km'). "Luxor"
		             (2 -> '0.9 km'). "Garden"
		             (3 -> '2.3 km'). "Avalon"
		             (4 -> '2.8 km'). "The Strand"
		             (5 -> '4.5 km'). "Regent"
		             (6 -> '7.5 km'). "Movox"
		             (7 -> '0.4 km') "Oasis" } asDictionary.
	^ (distances at: aTheatreId asNumber) asNumber
]

{ #category : #testing }
Variation >> distanceIsRight: aClickEvent [

	"Only for V2"

	^ aClickEvent trackValue asNumber <= self distance asNumber
]

{ #category : #analyzing }
Variation >> errorsIn: selectionsDictionary [

	| errors |
	errors := 0.
	self movie = (selectionsDictionary at: 'movieId' ifAbsent: [  ]) 
		ifFalse: [ errors := errors + 1 ].
	self time = (selectionsDictionary at: 'time' ifAbsent: [  ]) 
		ifFalse: [ errors := errors + 1 ].
	selectionsDictionary at: 'theatreId' ifPresent: [ :theatreId | 
		(self distanceFor: theatreId) < self distance asNumber ifFalse: [ 
			errors := errors + 1 ] ].
	self seat = (selectionsDictionary at: 'seat' ifAbsent: [  ]) 
		ifFalse: [ errors := errors + 1 ].
	^ errors
]

{ #category : #accessing }
Variation >> id [

	^ id
]

{ #category : #accessing }
Variation >> id: anObject [

	id := anObject
]

{ #category : #accessing }
Variation >> iterations [

	^ iterations
]

{ #category : #accessing }
Variation >> iterations: anObject [

	iterations := anObject
]

{ #category : #accessing }
Variation >> movie [

	^ movie
]

{ #category : #accessing }
Variation >> movie: anObject [

	movie := anObject
]

{ #category : #testing }
Variation >> movieIsRight: aClickEvent [

	^ self movie = aClickEvent trackValue
]

{ #category : #accessing }
Variation >> printOn: aStream [

	super printOn: aStream.
	aStream << (' (',self version, ')')
]

{ #category : #accessing }
Variation >> requiredSelections [
	self shouldBeImplemented.
]

{ #category : #accessing }
Variation >> seat [

	^ seat
]

{ #category : #accessing }
Variation >> seat: aString [

	seat := aString
]

{ #category : #testing }
Variation >> seatIsRight: aClickEvent [

	^ self seat = aClickEvent trackValue
]

{ #category : #testing }
Variation >> selectionClickIsRight: aClickEvent [

	| methodName |
	methodName := (aClickEvent selectionKind , 'IsRight:') asSymbol.
	^ self perform: methodName with: aClickEvent
]

{ #category : #testing }
Variation >> theatreIsRight: aClickEvent [

	^ (self distanceFor: aClickEvent trackValue) < self distance asNumber
]

{ #category : #accessing }
Variation >> time [

	^ time
]

{ #category : #accessing }
Variation >> time: anObject [

	time := anObject
]

{ #category : #testing }
Variation >> timeIsRight: aClickEvent [

	^ self time = aClickEvent trackValue
]

{ #category : #accessing }
Variation >> version [

	^ version
]

{ #category : #accessing }
Variation >> version: anObject [

	version := anObject
]
