"
This is a sequence of PageVisits that models an interaction from either
- beginning of a PurchaseTask
- a visit to the seat selection page
"
Class {
	#name : 'InteractionRun',
	#superclass : 'Object',
	#instVars : [
		'pageVisits',
		'finalSelections'
	],
	#category : 'BigI',
	#package : 'BigI'
}

{ #category : 'instance creation' }
InteractionRun class >> visits: somePageVisits [

	^ self new
		  visits: somePageVisits;
		  yourself
]

{ #category : 'accessing' }
InteractionRun >> errorsCount [

	^ self variation errorsIn: self pageVisits last urlParameters
]

{ #category : 'accessing' }
InteractionRun >> finalSelections [

	^ finalSelections
]

{ #category : 'accessing' }
InteractionRun >> finalSelections: anObject [

	finalSelections := anObject
]

{ #category : 'testing' }
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

{ #category : 'testing' }
InteractionRun >> largeLoops [

	| largeLoopSequence loops |
	largeLoopSequence := { 'show'. 'date'. 'theatre' }.
	loops := OrderedCollection new.
	self pageVisits doWithIndex: [ :visit :index | 
		| candidateLoop |
		visit pageName = 'show' & (index < (self pageVisits size - 2)) 
			ifTrue: [ 
				candidateLoop := self pageVisits copyFrom: index to: index + 2.
				largeLoopSequence = (candidateLoop collect: #pageName) ifTrue: [ 
					loops add: candidateLoop ] ] ].
	^ loops
]

{ #category : 'accessing' }
InteractionRun >> largeLoopsTime [

	^ self largeLoops flattened
		  inject: Duration zero
		  into: [ :total :visit | total + visit totalTime ]
]

{ #category : 'analyzing' }
InteractionRun >> mergedWith: anInteractionRun [

	"Attempt to merge with anInteractionRun if both are part of the same attempt"

	^ (self shouldMergeWith: anInteractionRun)
		  ifTrue: [ self withExtraVisits: anInteractionRun pageVisits ]
		  ifFalse: [ self ]
]

{ #category : 'accessing' }
InteractionRun >> onScreenCorrections [

	^ self pageVisits flatCollect: #corrections
]

{ #category : 'accessing' }
InteractionRun >> pageVisits [

	^ pageVisits
]

{ #category : 'private' }
InteractionRun >> populateFinalSelections [

	self finalSelections: self pageVisits last urlParameters
]

{ #category : 'analyzing' }
InteractionRun >> shouldMergeWith: anInteractionRun [

	"Determine whether I should merge with anInteractionRun, i.e. we are part of the same attempt"
	"This means that"
	"(a) no selections differ between my last seat visit and the parameter's"
	"(b) anInteractionRun does not have interVisitCorrections"

	| sameSelections noCorrections |
	sameSelections := self finalSelections
	                  = anInteractionRun finalSelections.
	noCorrections := anInteractionRun onScreenCorrections isEmpty.
	^ sameSelections & noCorrections
]

{ #category : 'analyzing' }
InteractionRun >> totalTime [

	^ self pageVisits sum: #totalTime
]

{ #category : 'printing' }
InteractionRun >> traceString [

	^ String streamContents: [ :stream |
		  self visits
			  do: [ :visit | visit printTraceOn: stream ]
			  separatedBy: [ stream << ' -> ' ] ]
]

{ #category : 'accessing' }
InteractionRun >> variation [

	^ self pageVisits last variation
]

{ #category : 'accessing' }
InteractionRun >> visits [
	"Just an alias for convenience"

	^ pageVisits
]

{ #category : 'accessing' }
InteractionRun >> visits: somePageVisits [

	pageVisits := somePageVisits.
	self populateFinalSelections
]

{ #category : 'accessing' }
InteractionRun >> visitsCount [

	^ self pageVisits size
]

{ #category : 'copying' }
InteractionRun >> withExtraVisits: aCollection [

	^ self copy visits: self pageVisits , aCollection
]

{ #category : 'copying' }
InteractionRun >> withoutInitialBacktrack [

	| first2Visits traceIsRight noCorrections remaindingVisits |
	self visits size <= 2 ifTrue: [ ^ self ].
	first2Visits := self visits first: 2.
	noCorrections := first2Visits noneSatisfy: #hasCorrections.
	traceIsRight := (first2Visits collect: #pageName) = #( show date ).
	traceIsRight & noCorrections
		ifTrue: [ ^ self copy visits: (self visits allButFirst: 2) ]
		ifFalse: [ ^ self ]
]
