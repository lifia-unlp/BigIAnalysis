Class {
	#name : #InteractionAttempt,
	#superclass : #Object,
	#instVars : [
		'pageVisits',
		'finalSelections'
	],
	#category : #BigI
}

{ #category : #'instance creation' }
InteractionAttempt class >> visits: somePageVisits [

	^ self new
		  visits: somePageVisits;
		  yourself
]

{ #category : #accessing }
InteractionAttempt >> allClicks [

	^ self pageVisits flatCollect: [ :visit | visit clicks ]
]

{ #category : #accessing }
InteractionAttempt >> allMovieClicks [

	^ self clicksStartingWith: 'movie-card'
]

{ #category : #accessing }
InteractionAttempt >> allScheduleClicks [

	^ self clicksStartingWith: 'schedule'
]

{ #category : #accessing }
InteractionAttempt >> allTheatreClicks [

	^ self clicksStartingWith: 'theatre-card'
]

{ #category : #accessing }
InteractionAttempt >> allTimeClicks [

	^ self clicksStartingWith: 'show-time'
]

{ #category : #accessing }
InteractionAttempt >> clicksStartingWith: prefix [

	^ self allClicks select: [ :click | 
		  click trackId isNotNil and: [ click trackId beginsWith: prefix ] ]
]

{ #category : #accessing }
InteractionAttempt >> completionTime [

	^ self pageVisits
		  inject: Duration zero
		  into: [ :durartion :visit | durartion + visit totalTime ]
]

{ #category : #'analyzing - corrections' }
InteractionAttempt >> correctionsCount [

	^ self pageVisits sumNumbers: [ :visit | visit correctionsCount ]
]

{ #category : #'analyzing - corrections' }
InteractionAttempt >> correctionsToRight [

	^ self pageVisits flatCollect: #correctionsToRight
]

{ #category : #'analyzing - corrections' }
InteractionAttempt >> correctionsToRightCount [

	^ self correctionsToRight size
]

{ #category : #'analyzing - corrections' }
InteractionAttempt >> correctionsToWrong [

	^ self pageVisits flatCollect: #correctionsToWrong
]

{ #category : #'analyzing - corrections' }
InteractionAttempt >> correctionsToWrongCount [

	^ self correctionsToWrong size
]

{ #category : #accessing }
InteractionAttempt >> errorsCount [

	^ self variation errorsIn: self pageVisits last urlParameters
]

{ #category : #accessing }
InteractionAttempt >> finalSelections [

	^ finalSelections
]

{ #category : #accessing }
InteractionAttempt >> finalSelections: anObject [

	finalSelections := anObject
]

{ #category : #accessing }
InteractionAttempt >> hasCorrections [

	^ self onPageCorrections isNotEmpty
]

{ #category : #testing }
InteractionAttempt >> hasLargeLoops [

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
InteractionAttempt >> hasSmallLoops [

	^ self smallLoops isNotEmpty
]

{ #category : #'accessing - task types' }
InteractionAttempt >> interactionStepsCount [

	| onPageClicks navigations |
	onPageClicks := self visits sumNumbers: [ :visit | visit clicks size ].
	navigations := self visitsCount - 1.
	^ onPageClicks + navigations
]

{ #category : #testing }
InteractionAttempt >> isPartOfLargeLoop: aSequence [

	^ self largeLoops anySatisfy: [ :largeLoop | 
		  largeLoop includes: aSequence first ]
]

{ #category : #testing }
InteractionAttempt >> isStraightRun [

	| sequence |
	sequence := self pageVisits collect: #pageName.

	^ sequence = #( v1 theatre date show seat summary )
	  | (sequence = #( v1 theatre date show seat ))
	  | (sequence = #( theatre date show seat ))
]

{ #category : #testing }
InteractionAttempt >> largeLoops [

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
InteractionAttempt >> largeLoopsTime [

	^ self largeLoops flattened
		  inject: Duration zero
		  into: [ :total :visit | total + visit totalTime ]
]

{ #category : #analyzing }
InteractionAttempt >> mergedWith: anInteractionRun [

	"Attempt to merge with anInteractionRun if both are part of the same attempt"

	^ (self shouldMergeWith: anInteractionRun)
		  ifTrue: [ self withExtraVisits: anInteractionRun pageVisits ]
		  ifFalse: [ self ]
]

{ #category : #accessing }
InteractionAttempt >> onPageCorrections [

	^ self pageVisits flatCollect: #corrections
]

{ #category : #accessing }
InteractionAttempt >> onPageCorrectionsTime [

	^ self onPageCorrections
		  inject: Duration zero
		  into: [ :totalTime :correction | totalTime + correction time ]
]

{ #category : #testing }
InteractionAttempt >> outcomeAchieved [

	^ self variation outcomeAchievedForRun: self
]

{ #category : #accessing }
InteractionAttempt >> pageVisits [

	^ pageVisits
]

{ #category : #private }
InteractionAttempt >> populateFinalSelections [

	self finalSelections: self pageVisits last urlParameters
]

{ #category : #accessing }
InteractionAttempt >> seatSelection [

	^ self pageVisits last selectionClicks
		  ifEmpty: [ 'N/A' ]
		  ifNotEmpty: [ :clicks | clicks last trackValue ]
]

{ #category : #analyzing }
InteractionAttempt >> shouldMergeWith: anInteractionRun [

	"Determine whether I should merge with anInteractionRun, i.e. we are part of the same attempt"
	"This means that"
	"(a) no selections differ between my last seat visit and the parameter's"
	"(b) anInteractionRun does not have interVisitCorrections"

	| sameSelections noCorrections |
	sameSelections := self finalSelections
	                  = anInteractionRun finalSelections.
	noCorrections := anInteractionRun onPageCorrections isEmpty.
	^ sameSelections & noCorrections
]

{ #category : #testing }
InteractionAttempt >> simpleBacktracks [

	| candidateBacktracks backtracks |
	candidateBacktracks := OrderedCollection new.
	self pageVisits doWithIndex: [ :visit :index | 
		| largeEnough |
		largeEnough := index <= (self pageVisits size - 2).
		largeEnough ifTrue: [ 
			| eachSequence |
			eachSequence := self pageVisits copyFrom: index to: index + 2.
			(self smallLoopSequences includes:
				 (eachSequence collect: #pageName)) ifTrue: [ 
				candidateBacktracks add: eachSequence ] ] ].

	backtracks := candidateBacktracks reject: [ :candidate | 
		              self isPartOfLargeLoop: candidate ].

	^ backtracks
]

{ #category : #testing }
InteractionAttempt >> smallLoopSequences [

	| single all|
	single := #( v1 theatre date show seat ) overlappingPairsCollect: [ 
		          :prev 
		          :next | 
		          { next . prev . next } collect: #asString ].
	all:= single asOrderedCollection.
	all 
		add: #(date theatre v1 theatre date);
		add: #(show date theatre v1 theatre date show);
		add: #(seat show date theatre v1 theatre date show seat);
		add: #(show date theatre date show);
		add: #(seat show date show seat).
	^all
]

{ #category : #testing }
InteractionAttempt >> smallLoops [

	| candidateBacktracks |
	candidateBacktracks := OrderedCollection new.
	self pageVisits doWithIndex: [ :visit :index | 
		| largeEnough |
		largeEnough := index <= (self pageVisits size - 2).
		largeEnough ifTrue: [ 
			| eachSequence |
			eachSequence := self pageVisits copyFrom: index to: index + 2.
			(self smallLoopSequences includes:
				 (eachSequence collect: #pageName)) ifTrue: [ 
				candidateBacktracks add: eachSequence ] ] ].
	self pageVisits doWithIndex: [ :visit :index | 
		| largeEnough |
		largeEnough := index <= (self pageVisits size - 4).
		largeEnough ifTrue: [ 
			| eachSequence |
			eachSequence := self pageVisits copyFrom: index to: index + 4.
			(self smallLoopSequences includes:
				 (eachSequence collect: #pageName)) ifTrue: [
				candidateBacktracks add: eachSequence ] ] ].


	^ candidateBacktracks
]

{ #category : #testing }
InteractionAttempt >> smallLoopsCount [

	^ self smallLoops size
]

{ #category : #testing }
InteractionAttempt >> smallLoopsTime [

	^ self smallLoops flattened
		  inject: Duration zero
		  into: [ :total :visit | total + visit totalTime ]
]

{ #category : #'accessing - task types' }
InteractionAttempt >> taskType [

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
InteractionAttempt >> totalTime [

	^ self pageVisits sum: #totalTime
]

{ #category : #printing }
InteractionAttempt >> traceString [

	^ String streamContents: [ :stream |
		  self visits
			  do: [ :visit | visit printTraceOn: stream ]
			  separatedBy: [ stream << ' -> ' ] ]
]

{ #category : #'accessing - task types' }
InteractionAttempt >> type0aCondition [

	^ self isStraightRun & self hasCorrections not & self outcomeAchieved
]

{ #category : #'accessing - task types' }
InteractionAttempt >> type0nCondition [

	^ self isStraightRun & self hasCorrections not & self outcomeAchieved not
]

{ #category : #'accessing - task types' }
InteractionAttempt >> type1aCondition [

	^ self isStraightRun & self hasCorrections & self outcomeAchieved
]

{ #category : #'accessing - task types' }
InteractionAttempt >> type1nCondition [

	^ self isStraightRun & self hasCorrections & self outcomeAchieved not
]

{ #category : #'accessing - task types' }
InteractionAttempt >> type2aCondition [

	^ self hasSmallLoops & self hasCorrections not
	  & self outcomeAchieved
]

{ #category : #'accessing - task types' }
InteractionAttempt >> type2nCondition [

	^ self hasSmallLoops & self hasCorrections not
	  & self outcomeAchieved not
]

{ #category : #'accessing - task types' }
InteractionAttempt >> type3aCondition [

	^ self hasSmallLoops & self hasCorrections & self outcomeAchieved 
]

{ #category : #'accessing - task types' }
InteractionAttempt >> type3nCondition [

	^ self hasSmallLoops & self hasCorrections & self outcomeAchieved not
]

{ #category : #accessing }
InteractionAttempt >> variation [

	^ self pageVisits last variation
]

{ #category : #accessing }
InteractionAttempt >> visits [
	"Just an alias for convenience"

	^ pageVisits
]

{ #category : #accessing }
InteractionAttempt >> visits: somePageVisits [

	pageVisits := somePageVisits.
	self populateFinalSelections
]

{ #category : #accessing }
InteractionAttempt >> visitsCount [

	^ self pageVisits size
]

{ #category : #copying }
InteractionAttempt >> withExtraVisits: aCollection [

	^ self copy visits: self pageVisits , aCollection
]

{ #category : #copying }
InteractionAttempt >> withoutInitialBacktrack [

	| first2Visits traceIsRight noCorrections remaindingVisits |
	self visits size <= 2 ifTrue: [ ^ self ].
	first2Visits := self visits first: 2.
	noCorrections := first2Visits noneSatisfy: #hasCorrections.
	traceIsRight := (first2Visits collect: #pageName) = #( show date ).
	traceIsRight & noCorrections
		ifTrue: [ ^ self copy visits: (self visits allButFirst: 2) ]
		ifFalse: [ ^ self ]
]
