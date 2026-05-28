Class {
	#name : #InteractionTask,
	#superclass : #InteractionAttempt,
	#instVars : [
		'prolificId',
		'variationId',
		'dateAndTime',
		'endTime',
		'variation'
	],
	#category : #BigI
}

{ #category : #'instance creation' }
InteractionTask class >> fromJSON: aJSON [

	| subjectValue numericKeys fixedText prolificId |
	prolificId := (aJSON at: #subject) at: #PROLIFIC_PID ifAbsent: [ 
		              subjectValue := aJSON at: #subject.
		              numericKeys := (subjectValue keys
			                              select: #isAllDigits
			                              thenCollect: #asNumber) sorted.
		              fixedText := String withAll:
			                           (numericKeys flatCollect: [ :key | 
				                            subjectValue at: key printString ]).
		              (NeoJSONReader fromString: fixedText) at:
			              #PROLIFIC_PID ifAbsent: 'NO-PROLIFIC-ID'].

	^ self new
		  prolificId: prolificId;
		  variationId: (aJSON at: #version);
		  pageVisits: ((aJSON at: #pages) collect: [ :visitJSON | 
					   PageVisit fromJSON: visitJSON ]);
		  dateAndTime:
			  (DateAndTime fromString: (aJSON at: #experimentStartTime));
		  endTime:
			  (DateAndTime fromString: (aJSON at: #experimentEndTime));
		  yourself
]

{ #category : #accessing }
InteractionTask >> attempts [

	^ self interactionRuns collect: [ :run | run withoutInitialBacktrack ]
]

{ #category : #printing }
InteractionTask >> attemptsLinesString [

	^ String streamContents: [ :stream | 
		  self attempts withIndexDo: [ :attempt :n | 
			  stream << self prolificId.
			  stream << ','.
			  stream << self variationId.
			  stream << ','.
			  stream << n printString.
			  stream << ','.
			  stream << self plannedIterations asString.
			  stream << ','.
			  stream << attempt taskType.
			  stream << ','.
			  stream << attempt smallLoopsCount asString.
			  stream << ','.
			  stream << attempt smallLoopsTime asSeconds asString.
			  stream << ','.
			  stream << attempt correctionsToRightCount asString.
			  stream << ','.
			  stream << attempt correctionsToWrongCount asString.
			  stream << ','.
			  stream << attempt onPageCorrectionsTime asSeconds asString.
			  stream << ','.
			  stream << attempt totalTime asSeconds asString.
			  stream << ','.
			  stream << attempt interactionStepsCount asString.
			  stream << ','.
			  stream << attempt traceString.
			  stream cr ] ]
]

{ #category : #printing }
InteractionTask >> attemptslinesString [

	^ String streamContents: [ :stream | 
		  self attempts withIndexDo: [ :attempt :n | 
			  | corrections |
			  corrections := attempt onPageCorrections.
			  self prolificId printOn: stream.
			  stream nextPut: $,.
			  self variationId asNumber printOn: stream.
			  stream nextPut: $,.
			  n printOn: stream.
			  stream nextPut: $,.
			  (corrections count: [ :correction | 
				   correction matchesPattern: 'wr' ]) printOn: stream.
			  stream nextPut: $,.
			  (corrections count: [ :correction | 
				   correction matchesPattern: 'rw' ]) printOn: stream.
			  stream nextPut: $,.
			  (corrections count: [ :correction | 
				   correction matchesPattern: 'ww' ]) printOn: stream.
			  stream nextPut: $,.
			  (corrections count: [ :correction | 
				   correction matchesPattern: 'rr' ]) printOn: stream.
			  stream nextPut: $,.
			  corrections size printOn: stream.
			  stream nextPut: $,.
			  attempt errorsCount printOn: stream.
			  stream nextPut: $,.
			  attempt visitsCount printOn: stream.
			  stream nextPut: $,.
			  attempt totalTime asSeconds printOn: stream.
			  stream nextPut: $,.
			  attempt hasLargeLoops printOn: stream.
			  stream nextPut: $,.
			  attempt largeLoopsTime asSeconds printOn: stream.
			  stream cr ] ]
]

{ #category : #'selections-by click' }
InteractionTask >> clickedMovieSelections [

	^ self allMovieClicks collect: #trackValue
]

{ #category : #'selections-by click' }
InteractionTask >> clickedTimeSelections [

	^ self allTimeClicks collect: #trackValue
]

{ #category : #accessing }
InteractionTask >> dateAndTime [

	^ dateAndTime
]

{ #category : #accessing }
InteractionTask >> dateAndTime: anObject [

	dateAndTime := anObject
]

{ #category : #accessing }
InteractionTask >> endTime [

	^ endTime
]

{ #category : #accessing }
InteractionTask >> endTime: anObject [

	endTime := anObject
]

{ #category : #analyzing }
InteractionTask >> errors [

	^ self variation errorsIn: self pageVisits last urlParameters
]

{ #category : #accessing }
InteractionTask >> errorsCount [

	^ self wrongSelections
]

{ #category : #accessing }
InteractionTask >> finalSelections [

	^ self pageVisits last urlParameters
]

{ #category : #accessing }
InteractionTask >> fullTime [

	^ self endTime - self dateAndTime
]

{ #category : #testing }
InteractionTask >> hasCorrections [

	^ self correctionsCount > 0
]

{ #category : #testing }
InteractionTask >> hasErrors [

	^ self wrongSelections > 0
]

{ #category : #testing }
InteractionTask >> hasLargeLoops [

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
InteractionTask >> interVisitCorrections [

	^ self lastSelections
		  groupedBy: #trackIdPrefix
		  having: [ :events | (events collect: #trackId) asSet size > 1 ]
]

{ #category : #accessing }
InteractionTask >> interactionRuns [
	"Simple split by visit to the seat selection page"

	| areSeats seatVisits runsToSeat completeRuns |
	areSeats := [ :visit | (visit stepName beginsWith: '/seat') & visit hasSelectionClicks ].
	seatVisits := (self pageVisits select: areSeats) asOrderedCollection.
	runsToSeat := (self pageVisits splitOn: areSeats) allButLast.
	completeRuns := runsToSeat
		                with: seatVisits
		                collect: [ :run :end | 
		                InteractionRun visits: (run copyWith: end) ].
	^ seatVisits
		  ifEmpty: [ (InteractionRun visits: self pageVisits) inOrderedCollection ]
		  ifNotEmpty: [ completeRuns ]
]

{ #category : #'private - testing' }
InteractionTask >> isPartOfLargeLoop: aSequence [

	^ self largeLoops anySatisfy: [ :largeLoop | 
		  largeLoop includes: aSequence first ]
]

{ #category : #testing }
InteractionTask >> isStraightRun [

	^ (self pageVisits collect: #pageName)
	  = #( v1 theatre date show seat summary )
]

{ #category : #accessing }
InteractionTask >> largeLoops [

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
InteractionTask >> largeLoopsCount [

	^ self largeLoops size
]

{ #category : #accessing }
InteractionTask >> largeLoopsTime [

	^ self largeLoops flattened
		  inject: Duration zero
		  into: [ :total :visit | total + visit totalTime ]
]

{ #category : #accessing }
InteractionTask >> lastSelections [

	| withNils |
	withNils := self pageVisits collect: [ :visit | 
		            visit clicks reversed
			            detect: [ :click | click isSelectionClick ]
			            ifNone: nil ].
	^ withNils copyWithout: nil
]

{ #category : #printing }
InteractionTask >> lineString [

	^ String streamContents: [ :stream | 
		  stream << self prolificId.
		  stream << ','.
		  stream << self variationId.
		  stream << ','.
		  stream << self plannedIterations asString.
		  stream << ','.
		  stream << self taskType.
		  stream << ','.
		  stream << self smallLoopsCount asString.
		  stream << ','.
		  stream << self smallLoopsTime asString.
		  stream << ','.
		  stream << self smallLoopsTime asSeconds asString.
		  stream << ','.
		  stream << self largeLoopsCount asString.
		  stream << ','.
		  stream << self largeLoopsTime asString.
		  stream << ','.
		  stream << self largeLoopsTime asSeconds asString.
		  stream << ','.
		  stream << self correctionsToRightCount asString.
		  stream << ','.
		  stream << self correctionsToWrongCount asString.
		  stream << ','.
		  stream << self totalTime asString.
		  stream << ','.
		  stream << self totalTime asSeconds asString.
		  stream << ','.
		  stream << self traceString.
		  stream cr ]
]

{ #category : #accessing }
InteractionTask >> mergedAttempts [
	"Return interaction runs but merged when there is no adjustment between them"

	| collapsed current |
	collapsed := OrderedCollection new.
	current := self interactionRuns first.

	self interactionRuns allButFirst do: [ :next | 
		(current shouldMergeWith: next)
			ifTrue: [ current := current mergedWith: next ]
			ifFalse: [ 
				collapsed add: current.
				current := next ] ].
	collapsed add: current.
	^ collapsed asOrderedCollection
]

{ #category : #selections }
InteractionTask >> movieSelections [

	| allParameters |
	allParameters := self pageVisits collect: [ :visit | 
		                 visit urlParameters ].
	^ allParameters
		  select: [ :parameters | parameters includesKey: 'movieId' ]
		  thenCollect: [ :parameters | parameters at: 'movieId' ]
]

{ #category : #accessing }
InteractionTask >> onPageCorrections [

	^ self pageVisits flatCollect: #corrections
]

{ #category : #testing }
InteractionTask >> outcomeAchieved [

	^ self variation outcomeAchievedFor: self
]

{ #category : #accessing }
InteractionTask >> pageVisits [

	^ pageVisits
]

{ #category : #accessing }
InteractionTask >> pageVisits: anObject [

	pageVisits := anObject.
	pageVisits do: [ :visit | visit variation: self variation ]
]

{ #category : #accessing }
InteractionTask >> plannedIterations [

	^ self variation iterations asNumber
]

{ #category : #accessing }
InteractionTask >> prolificId [

	^ prolificId
]

{ #category : #accessing }
InteractionTask >> prolificId: anObject [

	prolificId := anObject
]

{ #category : #testing }
InteractionTask >> simpleBacktracks [

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

{ #category : #accessing }
InteractionTask >> smallLoopsCount [

	^ self simpleBacktracks size
]

{ #category : #accessing }
InteractionTask >> smallLoopsTime [

	^ self simpleBacktracks flattened
		  inject: Duration zero
		  into: [ :total :visit | total + visit totalTime ]
]

{ #category : #selections }
InteractionTask >> timeSelections [

	| allParameters |
	allParameters := self pageVisits collect: [ :visit | 
		                 visit urlParameters ].
	^ allParameters
		  select: [ :parameters | parameters includesKey: 'time' ]
		  thenCollect: [ :parameters | parameters at: 'time' ]
]

{ #category : #accessing }
InteractionTask >> variation [

	^ variation ifNil: [ variation := Variation withId: self variationId ]
]

{ #category : #accessing }
InteractionTask >> variationId [

	^ variationId
]

{ #category : #accessing }
InteractionTask >> variationId: anObject [

	variationId := anObject
]

{ #category : #testing }
InteractionTask >> wrongMovieCount [

	^ self movieSelections collapseRuns count: [ :movieId | 
		  movieId ~= self variation movie ]
]

{ #category : #testing }
InteractionTask >> wrongSelections [

	| wrongMovieCount wrongTimeCount |
	wrongMovieCount := self wrongMovieCount.
	wrongTimeCount := self wrongTimeCount.
	^ wrongMovieCount + wrongTimeCount
]

{ #category : #testing }
InteractionTask >> wrongTimeCount [

	^ self timeSelections collapseRuns count: [ :time | 
		  time ~= self variation time ]
]
