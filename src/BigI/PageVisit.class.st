Class {
	#name : #PageVisit,
	#superclass : #Object,
	#instVars : [
		'version',
		'stepName',
		'clicks',
		'startTime',
		'endTime',
		'transitionDuration',
		'variation',
		'variationRule'
	],
	#category : #BigI
}

{ #category : #'instance creation' }
PageVisit class >> fromJSON: aJSON [

	| newVisit |
	newVisit := self new.
	newVisit stepName: (aJSON at: #page).
	newVisit clicks: ((aJSON at: #clicks) collect: [ :clickJSON | 
			 ClickEvent fromJSON: clickJSON ]).
	newVisit startTime: (aJSON at: #visitStartTime) asDateAndTime .
	newVisit endTime: (aJSON at: #visitEndTime) asDateAndTime.
	newVisit transitionDuration: (Duration milliSeconds: (aJSON at: #pageTransitionDuration)).
	^ newVisit
]

{ #category : #testing }
PageVisit >> choicesAreRight [

	^ self variation choicesAreRight: self urlParameters
]

{ #category : #accessing }
PageVisit >> clicks [

	^ clicks
]

{ #category : #accessing }
PageVisit >> clicks: anObject [

	clicks := anObject
]

{ #category : #accessing }
PageVisit >> corrections [

	| valueChangeSequences |
	valueChangeSequences := (self clicks select: #isSelectionClick)
		                        groupedBy: [ :click | click trackIdPrefix ]
		                        having: [ :clicksGroup | 
		                        (clicksGroup collect: #trackValue as: Set)
			                        size > 1 ].
	^ valueChangeSequences values flatCollect: [ :clicksSequence | 
		  clicksSequence overlappingPairsCollect: [ :selection :correction | 
			  Correction
				  fromClicks: { 
						  selection.
						  correction } asOrderedCollection
				  andVariation: self variation ] ]
]

{ #category : #accessing }
PageVisit >> correctionsCount [

	^ self corrections size
]

{ #category : #accessing }
PageVisit >> correctionsTime [

	^ self corrections
		  inject: Duration zero
		  into: [ :totalTime :time | totalTime + time ]
]

{ #category : #accessing }
PageVisit >> correctionsToRight [

	^ self corrections select: #finalValueIsRight
]

{ #category : #accessing }
PageVisit >> correctionsToRightCount [

	^ self corrections count: #finalValueIsRight
]

{ #category : #accessing }
PageVisit >> correctionsToWrong [

	^ self corrections select: #finalValueIsWrong
]

{ #category : #accessing }
PageVisit >> correctionsToWrongCount [

	^ self corrections count: #finalValueIsWrong
]

{ #category : #accessing }
PageVisit >> endTime [

	^ endTime
]

{ #category : #accessing }
PageVisit >> endTime: anObject [

	endTime := anObject
]

{ #category : #accessing }
PageVisit >> errorsCount [

	^ self variation errorsIn: self pageVisits last urlParameters
]

{ #category : #testing }
PageVisit >> hasCorrections [

	^ self correctionsCount > 0
]

{ #category : #testing }
PageVisit >> hasSelectionClicks [

	^ self clicks anySatisfy: #isSelectionClick
]

{ #category : #initialization }
PageVisit >> initialize [

	clicks := OrderedCollection new
]

{ #category : #testing }
PageVisit >> isBuggy [

	^ (self clicks select: #isSelectionClick thenCollect: #selectionKind) asSet size > 1
]

{ #category : #printing }
PageVisit >> lineString [
	^String streamContents: [ :stream |
		stream << self pageName.
		stream << ','.
		stream << self clicks size asString.
		stream << ','.
		stream << self correctionsCount asString.
		stream << ','.
		stream << self numberOfChoices asString.
		stream << ','.
		stream << self totalTime asSeconds printString.
		stream cr.
		]
]

{ #category : #accessing }
PageVisit >> numberOfChoices [

	self pageName = 'v1' ifTrue: [ ^ 8 ].
	self pageName = 'theatre' ifTrue: [ ^ 7 ].
	self pageName = 'date' ifTrue: [ ^ 7 ].
	self pageName = 'show' ifTrue: [ ^ 6 ].
	self pageName = 'summary' ifTrue: [ ^ '-' ].
	self pageName = 'seat' ifTrue: [ 
		| rule |
		self variationRule ifNil: [ ^'N/A' ].
		rule := self variation rules at: (self variationRule - 1) printString.
		^ (rule at: 'availableSeats') size ]
]

{ #category : #accessing }
PageVisit >> pageName [

	^ (self stepName copyUpToSubstring: '?') allButFirst
]

{ #category : #printing }
PageVisit >> printOn: aStream [
	super printOn: aStream.
	aStream << (' (',(self stepName copyUpTo: $?) allButFirst, ')')  
]

{ #category : #printing }
PageVisit >> printTraceOn: aStream [

	aStream << (self stepName copyUpTo: $?) allButFirst.
	aStream space.
	self selectionClicksCount > 0 ifTrue: [
		self selectionClicksCount printOn: aStream.
		aStream << 's ' ].
	self correctionsToRightCount > 0 ifTrue: [
		self correctionsToRightCount printOn: aStream.
		aStream << 'c ' ].
	self correctionsToWrongCount > 0 ifTrue: [
		self correctionsToWrongCount printOn: aStream.
		aStream << 'e ' ]
]

{ #category : #testing }
PageVisit >> selectionClicks [

	^ self clicks select: #isSelectionClick
]

{ #category : #testing }
PageVisit >> selectionClicksCount [

	^ self selectionClicks size
]

{ #category : #accessing }
PageVisit >> startTime [

	^ startTime
]

{ #category : #accessing }
PageVisit >> startTime: anObject [

	startTime := anObject
]

{ #category : #accessing }
PageVisit >> stepName [

	^ stepName
]

{ #category : #accessing }
PageVisit >> stepName: anObject [

	stepName := anObject
]

{ #category : #accessing }
PageVisit >> totalTime [

	^ self endTime - self startTime + self transitionDuration
]

{ #category : #accessing }
PageVisit >> transitionDuration [

	^ transitionDuration
]

{ #category : #accessing }
PageVisit >> transitionDuration: anObject [

	transitionDuration := anObject
]

{ #category : #accessing }
PageVisit >> urlParameters [

	| parameters dictionary |
	dictionary := Dictionary new.
	parameters := self stepName copyAfterLast: $?.
	parameters splitOn: $& do: [ :parameterString | 
		| keyAndValue |
		keyAndValue := parameterString splitOn: $=.
		dictionary at: keyAndValue first put: keyAndValue second ].
	^ dictionary
]

{ #category : #accessing }
PageVisit >> variation [

	^ variation
]

{ #category : #accessing }
PageVisit >> variation: anObject [

	variation := anObject
]

{ #category : #accessing }
PageVisit >> variationRule [

	^ variationRule
]

{ #category : #accessing }
PageVisit >> variationRule: anObject [

	variationRule := anObject
]

{ #category : #accessing }
PageVisit >> version [

	^ version
]

{ #category : #accessing }
PageVisit >> version: anObject [

	version := anObject
]
