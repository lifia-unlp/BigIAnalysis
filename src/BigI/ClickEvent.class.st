Class {
	#name : #ClickEvent,
	#superclass : #Object,
	#instVars : [
		'element',
		'dateAndTime',
		'trackId'
	],
	#category : #BigI
}

{ #category : #'instance creation' }
ClickEvent class >> element: aString dateAndTime: aDateAndTime [

	^ self new
		  element: aString;
		  dateAndTime: aDateAndTime;
		  yourself
]

{ #category : #'instance creation' }
ClickEvent class >> element: aString dateAndTime: aDateAndTime trackId: anotherString [

	^ self new
		  element: aString;
		  dateAndTime: aDateAndTime;
		  trackId: anotherString;
		  yourself
]

{ #category : #'instance creation' }
ClickEvent class >> fromJSON: aJSON [

	| dateAndTime |
	dateAndTime := DateAndTime fromUnixTime: (aJSON at: #time) / 1000.
	^ self element: (aJSON at: #element) dateAndTime: dateAndTime trackId: (aJSON at: #trackId)
]

{ #category : #accessing }
ClickEvent >> dateAndTime [

	^ dateAndTime
]

{ #category : #accessing }
ClickEvent >> dateAndTime: anObject [

	dateAndTime := anObject
]

{ #category : #accessing }
ClickEvent >> element [

	^ element
]

{ #category : #accessing }
ClickEvent >> element: anObject [

	element := anObject
]

{ #category : #testing }
ClickEvent >> isSelection [

	^ ({ nil. 'button="back"'. 'button="next"' } includes: self trackId)
		  not
]

{ #category : #testing }
ClickEvent >> isSelectionClick [

	^ self selectionTrackIds includes: self trackIdPrefix
]

{ #category : #accessing }
ClickEvent >> selectionKind [

	^ self trackIdPrefixesToSelectionKinds
		  at: self trackIdPrefix
		  "ifAbsent: 'N/A'"
]

{ #category : #'accessing - definitions' }
ClickEvent >> selectionTrackIds [

	^ { #'theatre-card='. #'schedule='. #'show-time='. #'movie-card='.
	  #'seat=' }
]

{ #category : #accessing }
ClickEvent >> trackId [

	^ trackId
]

{ #category : #accessing }
ClickEvent >> trackId: anObject [

	trackId := anObject
]

{ #category : #accessing }
ClickEvent >> trackIdPrefix [

	^ self trackId
		  ifNil: ''
		  ifNotNil: [ :text | (text splitOn: $") first ]
]

{ #category : #private }
ClickEvent >> trackIdPrefixesToSelectionKinds [

	^ { 
		  ('seat=' -> #seat).
		  ('show-time=' -> #time).
		  ('theatre-card=' -> #theatre).
		  ('schedule=' -> #date).
		  ('distance=' -> #distance).
		  ('movie-card=' -> #movie) } asDictionary
]

{ #category : #accessing }
ClickEvent >> trackValue [

	^ self trackId
		  ifNil: 'nil'
		  ifNotNil: [ :trackIdValue | 
		  (trackIdValue splitOn: $") allButLast last ]
]
