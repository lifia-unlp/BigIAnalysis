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
		'variation'
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
	^ valueChangeSequences values collect: [ :clicksSequence | 
		  Correction fromClicks: clicksSequence andVariation: self variation ]
]

{ #category : #accessing }
PageVisit >> correctionsCount [

	^ self corrections size
]

{ #category : #accessing }
PageVisit >> endTime [

	^ endTime
]

{ #category : #accessing }
PageVisit >> endTime: anObject [

	endTime := anObject
]

{ #category : #testing }
PageVisit >> hasCorrections [

	^ self clicks
		  groupedBy: [ :click | click trackIdPrefix ]
		  having: [ :clicksGroup | 
		  (clicksGroup collect: #trackValue as: Set) size > 1 ]
]

{ #category : #initialization }
PageVisit >> initialize [

	clicks := OrderedCollection new
]

{ #category : #printing }
PageVisit >> printOn: aStream [
	super printOn: aStream.
	aStream << (' (',(self stepName copyUpTo: $?) allButFirst, ')')  
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
PageVisit >> version [

	^ version
]

{ #category : #accessing }
PageVisit >> version: anObject [

	version := anObject
]
