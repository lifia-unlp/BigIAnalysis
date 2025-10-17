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

{ #category : #testing }
InteractionRun >> backtrackSequences [

	^ #( v1 theatre date show seat summary ) overlappingPairsCollect: [ 
		  :prev 
		  :next | 
		  { 
			  next.
			  prev.
			  next } collect: #asString ]
]

{ #category : #testing }
InteractionRun >> correctionsToRightCount [

	^ self onScreenCorrections count: #finalValueIsRight
]

{ #category : #testing }
InteractionRun >> correctionsToWrongCount [

	^ self onScreenCorrections count: #finalValueIsWrong
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

{ #category : #accessing }
InteractionRun >> hasCorrections [

	^ self onScreenCorrections isNotEmpty
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

{ #category : #testing }
InteractionRun >> hasSimpleBacktracks [

	^ self simpleBacktracks size > 0
]

{ #category : #testing }
InteractionRun >> isPartOfLargeLoop: aSequence [

	^ self largeLoops anySatisfy: [ :largeLoop | 
		  largeLoop includes: aSequence first ]
]

{ #category : #testing }
InteractionRun >> isStraightRun [

	| sequence |
	sequence := self pageVisits collect: #pageName.

	^ sequence = #( v1 theatre date show seat summary )
	  | (sequence = #( v1 theatre date show seat ))
	  | (sequence = #( theatre date show seat ))
]

{ #category : #testing }
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

{ #category : #accessing }
InteractionRun >> largeLoopsTime [

	^ self largeLoops flattened
		  inject: Duration zero
		  into: [ :total :visit | total + visit totalTime ]
]

{ #category : #analyzing }
InteractionRun >> mergedWith: anInteractionRun [

	"Attempt to merge with anInteractionRun if both are part of the same attempt"

	^ (self shouldMergeWith: anInteractionRun)
		  ifTrue: [ self withExtraVisits: anInteractionRun pageVisits ]
		  ifFalse: [ self ]
]

{ #category : #accessing }
InteractionRun >> onScreenCorrections [

	^ self pageVisits flatCollect: #corrections
]

{ #category : #testing }
InteractionRun >> outcomeAchieved [

	^ self variation outcomeAchievedForRun: self
]

{ #category : #accessing }
InteractionRun >> pageVisits [

	^ pageVisits
]

{ #category : #private }
InteractionRun >> populateFinalSelections [

	self finalSelections: self pageVisits last urlParameters
]

{ #category : #accessing }
InteractionRun >> seatSelection [

	^ self pageVisits last selectionClicks
		  ifEmpty: [ 'N/A' ]
		  ifNotEmpty: [ :clicks | clicks last trackValue ]
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
	noCorrections := anInteractionRun onScreenCorrections isEmpty.
	^ sameSelections & noCorrections
]

{ #category : #testing }
InteractionRun >> simpleBacktracks [

	| candidateBacktracks backtracks |
	candidateBacktracks := OrderedCollection new.
	self pageVisits doWithIndex: [ :visit :index | 
		| largeEnough |
		largeEnough := index <= (self pageVisits size - 2).
		largeEnough ifTrue: [ 
			| eachSequence |
			eachSequence := self pageVisits copyFrom: index to: index + 2.
			(self backtrackSequences includes:
				 (eachSequence collect: #pageName)) ifTrue: [ 
				candidateBacktracks add: eachSequence ] ] ].

	backtracks := candidateBacktracks reject: [ :candidate | 
		              self isPartOfLargeLoop: candidate ].

	^ backtracks
]

{ #category : #testing }
InteractionRun >> smallLoopsCount [

	^ self simpleBacktracks size
]

{ #category : #testing }
InteractionRun >> smallLoopsTime [

	^ self simpleBacktracks flattened
		  inject: Duration zero
		  into: [ :total :visit | total + visit totalTime ]
]

{ #category : #'accessing - task types' }
InteractionRun >> taskType [

	self type0aCondition ifTrue: [ ^ '0a' ].
	self type0nCondition ifTrue: [ ^ '0n' ].
	self type1aCondition ifTrue: [ ^ '1a' ].
	self type1nCondition ifTrue: [ ^ '1n' ].
	self type2aCondition ifTrue: [ ^ '2a' ].
	self type2nCondition ifTrue: [ ^ '2n' ].
	self type3aCondition ifTrue: [ ^ '3a' ].
	self type3nCondition ifTrue: [ ^ '3n' ].
	^ 'other'
]

{ #category : #analyzing }
InteractionRun >> totalTime [

	^ self pageVisits sum: #totalTime
]

{ #category : #printing }
InteractionRun >> traceString [

	^ String streamContents: [ :stream |
		  self visits
			  do: [ :visit | visit printTraceOn: stream ]
			  separatedBy: [ stream << ' -> ' ] ]
]

{ #category : #'accessing - task types' }
InteractionRun >> type0aCondition [

	^ self isStraightRun & self hasCorrections not & self outcomeAchieved
]

{ #category : #'accessing - task types' }
InteractionRun >> type0nCondition [

	^ self isStraightRun & self hasCorrections not & self outcomeAchieved not
]

{ #category : #'accessing - task types' }
InteractionRun >> type1aCondition [

	^ self isStraightRun & self hasCorrections & self outcomeAchieved
]

{ #category : #'accessing - task types' }
InteractionRun >> type1nCondition [

	^ self isStraightRun & self hasCorrections & self outcomeAchieved not
]

{ #category : #'accessing - task types' }
InteractionRun >> type2aCondition [

	^ self hasSimpleBacktracks & self hasCorrections not
	  & self outcomeAchieved
]

{ #category : #'accessing - task types' }
InteractionRun >> type2nCondition [

	^ self hasSimpleBacktracks & self hasCorrections not
	  & self outcomeAchieved not
]

{ #category : #'accessing - task types' }
InteractionRun >> type3aCondition [

	^ self hasSimpleBacktracks & self hasCorrections & self outcomeAchieved 
]

{ #category : #'accessing - task types' }
InteractionRun >> type3nCondition [

	^ self hasSimpleBacktracks & self hasCorrections & self outcomeAchieved not
]

{ #category : #accessing }
InteractionRun >> variation [

	^ self pageVisits last variation
]

{ #category : #accessing }
InteractionRun >> visits [
	"Just an alias for convenience"

	^ pageVisits
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

{ #category : #copying }
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
