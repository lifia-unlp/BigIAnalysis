"
This is a sequence of PageVisits that models an interaction from either
- beginning of a PurchaseTask
- a visit to the seat selection page
"
Class {
	#name : #InteractionRun,
	#superclass : #Object,
	#instVars : [
		'pageVisits',
		'finalSelections'
	],
	#category : #BigI
}

{ #category : #'instance creation' }
InteractionRun class >> visits: somePageVisits [

	^ self new
		  visits: somePageVisits;
		  yourself
]

{ #category : #accessing }
InteractionRun >> errorsCount [

	^ self variation errorsIn: self pageVisits last urlParameters
]

{ #category : #accessing }
InteractionRun >> finalSelections [

	^ finalSelections
]

{ #category : #accessing }
InteractionRun >> finalSelections: anObject [

	finalSelections := anObject
]

{ #category : #testing }
InteractionRun >> hasLargeLoops [

	| largeLoopSequence candidateLoopStart candidateLoop |
	largeLoopSequence := { 'show'. 'date'. 'theatre' }.
	candidateLoopStart := (self pageVisits collect: #pageName)
		                      asOrderedCollection
		                      indexOfSubCollection: largeLoopSequence
		                      startingAt: 1
		                      ifAbsent: [ ^ false ].
	candidateLoop := self pageVisits
		                 copyFrom: candidateLoopStart
		                 to: candidateLoopStart + 2.
	^ (candidateLoop first: 2) noneSatisfy: #hasSelectionClicks
]

{ #category : #accessing }
InteractionRun >> intraVisitCorrections [

	^ self pageVisits flatCollect: #corrections
]

{ #category : #analyzing }
InteractionRun >> mergedWith: anInteractionRun [

	"Attempt to merge with anInteractionRun if both are part of the same attempt"

	^ (self shouldMergeWith: anInteractionRun)
		  ifTrue: [ self withExtraVisits: anInteractionRun pageVisits ]
		  ifFalse: [ self ]
]

{ #category : #accessing }
InteractionRun >> pageVisits [

	^ pageVisits
]

{ #category : #private }
InteractionRun >> populateFinalSelections [

	self finalSelections: self pageVisits last urlParameters
]

{ #category : #analyzing }
InteractionRun >> shouldMergeWith: anInteractionRun [

	"Determine whether I should merge with anInteractionRun, i.e. we are part of the same attempt"
	"This means that"
	"(a) no selections differ between my last seat visit and the parameter's"
	"(b) anInteractionRun does not have interVisitCorrections"

	| sameSelections noCorrections |
	sameSelections := self finalSelections
	                  = anInteractionRun finalSelections.
	noCorrections := anInteractionRun intraVisitCorrections isEmpty.
	^ sameSelections & noCorrections
]

{ #category : #analyzing }
InteractionRun >> totalTime [

	^ self pageVisits sum: #totalTime
]

{ #category : #accessing }
InteractionRun >> variation [

	^ self pageVisits last variation
]

{ #category : #accessing }
InteractionRun >> visits: somePageVisits [

	pageVisits := somePageVisits.
	self populateFinalSelections
]

{ #category : #accessing }
InteractionRun >> visitsCount [

	^ self pageVisits size
]

{ #category : #copying }
InteractionRun >> withExtraVisits: aCollection [

	^ self copy visits: self pageVisits , aCollection
]
