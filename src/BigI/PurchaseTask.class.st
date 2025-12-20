Class {
	#name : #PurchaseTask,
	#superclass : #Object,
	#instVars : [
		'prolificId',
		'variationId',
		'pageVisits',
		'dateAndTime',
		'endTime',
		'variation'
	],
	#category : #BigI
}

{ #category : #'instance creation' }
PurchaseTask class >> fromJSON: aJSON [

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
PurchaseTask >> allClicks [

	^ self pageVisits flatCollect: [ :visit | visit clicks ]
]

{ #category : #accessing }
PurchaseTask >> allMovieClicks [

	^ self clicksStartingWith: 'movie-card'
]

{ #category : #accessing }
PurchaseTask >> allScheduleClicks [

	^ self clicksStartingWith: 'schedule'
]

{ #category : #accessing }
PurchaseTask >> allTheatreClicks [

	^ self clicksStartingWith: 'theatre-card'
]

{ #category : #accessing }
PurchaseTask >> allTimeClicks [

	^ self clicksStartingWith: 'show-time'
]

{ #category : #accessing }
PurchaseTask >> attempts [

	^ self interactionRuns collect: [ :run | run withoutInitialBacktrack ]
]

{ #category : #printing }
PurchaseTask >> attemptsLinesString [

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
PurchaseTask >> attemptslinesString [

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

{ #category : #private }
PurchaseTask >> backtrackSequences [

	^ #( v1 theatre date show seat summary ) overlappingPairsCollect: [ 
		  :prev 
		  :next | 
		  { 
			  next.
			  prev.
			  next } collect: #asString ]
]

{ #category : #'selections-by click' }
PurchaseTask >> clickedMovieSelections [

	^ self allMovieClicks collect: #trackValue
]

{ #category : #'selections-by click' }
PurchaseTask >> clickedTimeSelections [

	^ self allTimeClicks collect: #trackValue
]

{ #category : #accessing }
PurchaseTask >> clicksStartingWith: prefix [

	^ self allClicks select: [ :click | 
		  click trackId isNotNil and: [ click trackId beginsWith: prefix ] ]
]

{ #category : #accessing }
PurchaseTask >> completionTime [

	^ self pageVisits
		  inject: Duration zero
		  into: [ :durartion :visit | durartion + visit totalTime ]
]

{ #category : #accessing }
PurchaseTask >> correctionsCount [

	^ self pageVisits sumNumbers: [ :visit | visit correctionsCount ]
]

{ #category : #accessing }
PurchaseTask >> correctionsToRight [

	^ self pageVisits flatCollect: #correctionsToRight
]

{ #category : #accessing }
PurchaseTask >> correctionsToRightCount [

	^ self correctionsToRight size
]

{ #category : #accessing }
PurchaseTask >> correctionsToWrong [

	^ self pageVisits flatCollect: #correctionsToWrong
]

{ #category : #accessing }
PurchaseTask >> correctionsToWrongCount [

	^ self correctionsToWrong size
]

{ #category : #accessing }
PurchaseTask >> dateAndTime [

	^ dateAndTime
]

{ #category : #accessing }
PurchaseTask >> dateAndTime: anObject [

	dateAndTime := anObject
]

{ #category : #accessing }
PurchaseTask >> endTime [

	^ endTime
]

{ #category : #accessing }
PurchaseTask >> endTime: anObject [

	endTime := anObject
]

{ #category : #analyzing }
PurchaseTask >> errors [

	^ self variation errorsIn: self pageVisits last urlParameters
]

{ #category : #accessing }
PurchaseTask >> errorsCount [

	^ self wrongSelections
]

{ #category : #accessing }
PurchaseTask >> finalSelections [

	^ self pageVisits last urlParameters
]

{ #category : #analyzing }
PurchaseTask >> freshSeatVisitAttempts [

	"Each first attempt with a particular set of selections"

	| fresh maxIteration ruleNumber |
	fresh := Dictionary new.
	maxIteration := self variation rules.
	ruleNumber := 0.
	self seatVisits do: [ :seatVisit | 
		| choicesAreRight |
		choicesAreRight := self variation choicesAreRight:
			                   seatVisit urlParameters.
		choicesAreRight ifTrue: [ 
			fresh
				at: seatVisit urlParameters
				ifAbsentPut: (self variation rules size - 1 min: ruleNumber).
			ruleNumber := ruleNumber + 1 ] ].
	^ fresh
]

{ #category : #analyzing }
PurchaseTask >> freshSeatVisitAttempts_ [

	"Each first attempt with a particular set of selections"

	| freshVisits theatreId newSelection theatreIsRight |
	freshVisits := OrderedCollection new.
	self seatVisits do: [ :visit | 
		theatreId := visit urlParameters at: #theatreId.
		theatreIsRight := self variation theatreIdIsRight: theatreId.
		newSelection := freshVisits noneSatisfy: [ :previous | 
			                theatreId = (previous urlParameters at: #theatreId) ].
		newSelection & theatreIsRight ifTrue: [ freshVisits add: visit ] ].
	^ freshVisits
]

{ #category : #accessing }
PurchaseTask >> fullTime [

	^ self endTime - self dateAndTime
]

{ #category : #testing }
PurchaseTask >> hasCorrections [

	^ self correctionsCount > 0
]

{ #category : #testing }
PurchaseTask >> hasErrors [

	^ self wrongSelections > 0
]

{ #category : #testing }
PurchaseTask >> hasLargeLoops [

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
PurchaseTask >> hasSimpleBacktracks [

	^ self simpleBacktracks size > 0
]

{ #category : #accessing }
PurchaseTask >> interVisitCorrections [

	^ self lastSelections
		  groupedBy: #trackIdPrefix
		  having: [ :events | (events collect: #trackId) asSet size > 1 ]
]

{ #category : #accessing }
PurchaseTask >> interactionRuns [
	"Simple split by visit to the seat selection page"

	| areSeats seatVisits runsToSeat completeRuns |
	areSeats := [ :visit | (visit stepName beginsWith: '/seat')].
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
PurchaseTask >> isPartOfLargeLoop: aSequence [

	^ self largeLoops anySatisfy: [ :largeLoop | 
		  largeLoop includes: aSequence first ]
]

{ #category : #testing }
PurchaseTask >> isStraightRun [

	^ (self pageVisits collect: #pageName)
	  = #( v1 theatre date show seat summary )
]

{ #category : #accessing }
PurchaseTask >> iterations [
	"Split by visit to the seat selection page with a new (and correct) theatre choice"

	| areFreshSeatVisits seatVisits runsToSeat completeRuns |
	areFreshSeatVisits := [ :visit | self freshSeatVisitAttempts includes: visit].
	seatVisits := (self pageVisits select: areFreshSeatVisits) asOrderedCollection.
	runsToSeat := (self pageVisits splitOn: areFreshSeatVisits) allButLast.
	completeRuns := runsToSeat
		                with: seatVisits
		                collect: [ :run :end | 
		                InteractionRun visits: (run copyWith: end) ].
	^ seatVisits
		  ifEmpty: [ (InteractionRun visits: self pageVisits) inOrderedCollection ]
		  ifNotEmpty: [ completeRuns ]
]

{ #category : #accessing }
PurchaseTask >> largeLoops [

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
PurchaseTask >> largeLoopsCount [

	^ self largeLoops size
]

{ #category : #accessing }
PurchaseTask >> largeLoopsTime [

	^ self largeLoops flattened
		  inject: Duration zero
		  into: [ :total :visit | total + visit totalTime ]
]

{ #category : #accessing }
PurchaseTask >> lastSelections [

	| withNils |
	withNils := self pageVisits collect: [ :visit | 
		            visit clicks reversed
			            detect: [ :click | click isSelectionClick ]
			            ifNone: nil ].
	^ withNils copyWithout: nil
]

{ #category : #printing }
PurchaseTask >> lineString [

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
PurchaseTask >> mergedAttempts [
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

{ #category : #printing }
PurchaseTask >> mergedAttemptsLinesString [

	^ String streamContents: [ :stream | 
		  self mergedAttempts withIndexDo: [ :attempt :n | 
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
			  stream << attempt visits first startTime asString.
			  stream << ','.
			  stream << attempt traceString.
			  stream cr ] ]
]

{ #category : #selections }
PurchaseTask >> movieSelections [

	| allParameters |
	allParameters := self pageVisits collect: [ :visit | 
		                 visit urlParameters ].
	^ allParameters
		  select: [ :parameters | parameters includesKey: 'movieId' ]
		  thenCollect: [ :parameters | parameters at: 'movieId' ]
]

{ #category : #accessing }
PurchaseTask >> onPageCorrections [

	^ self pageVisits flatCollect: #corrections
]

{ #category : #testing }
PurchaseTask >> outcomeAchieved [

	^ self variation outcomeAchievedFor: self
]

{ #category : #accessing }
PurchaseTask >> pageVisits [

	^ pageVisits
]

{ #category : #accessing }
PurchaseTask >> pageVisits: anObject [

	pageVisits := anObject.
	pageVisits do: [ :visit | visit variation: self variation ]
]

{ #category : #accessing }
PurchaseTask >> plannedIterations [

	^ self variation iterations asNumber
]

{ #category : #initializing }
PurchaseTask >> populateVisitsVariationRule [

	| ruleForUrl |
	ruleForUrl := self freshSeatVisitAttempts.
	self seatVisits do: [ :seatVisit | 
		seatVisit variationRule:
			(ruleForUrl at: seatVisit urlParameters ifAbsent: -1) ]
]

{ #category : #initializing }
PurchaseTask >> populateVisitsVariationRule_ [

	| seatVisits assignedIterations |
	assignedIterations := Dictionary new.
	seatVisits := self freshSeatVisitAttempts.
	seatVisits doWithIndex: [ :seatVisit :ruleNumber | 
		assignedIterations
			at: seatVisit urlParameters
			ifAbsentPut: ruleNumber - 1.
		seatVisit variationRule:
			((assignedIterations at: seatVisit urlParameters) max:
				 self variation rules size) ]
]

{ #category : #accessing }
PurchaseTask >> prolificId [

	^ prolificId
]

{ #category : #accessing }
PurchaseTask >> prolificId: anObject [

	prolificId := anObject
]

{ #category : #accessing }
PurchaseTask >> seatVisits [

	^ self pageVisits select: [ :visit | visit pageName = 'seat' ]
]

{ #category : #analyzing }
PurchaseTask >> selectionsSequence [
	self shouldBeImplemented.
]

{ #category : #testing }
PurchaseTask >> simpleBacktracks [

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

{ #category : #accessing }
PurchaseTask >> smallLoopsCount [

	^ self smallLoops size
]

{ #category : #accessing }
PurchaseTask >> smallLoopsTime [

	^ self smallLoops flattened
		  inject: Duration zero
		  into: [ :total :visit | total + visit totalTime ]
]

{ #category : #selections }
PurchaseTask >> timeSelections [

	| allParameters |
	allParameters := self pageVisits collect: [ :visit | 
		                 visit urlParameters ].
	^ allParameters
		  select: [ :parameters | parameters includesKey: 'time' ]
		  thenCollect: [ :parameters | parameters at: 'time' ]
]

{ #category : #analyzing }
PurchaseTask >> totalTime [

	^ self pageVisits sum: #totalTime
]

{ #category : #printing }
PurchaseTask >> traceString [

	^ String streamContents: [ :stream | 
		  self pageVisits
			  do: [ :visit | visit printTraceOn: stream ]
			  separatedBy: [ stream << ' -> ' ] ]
]

{ #category : #accessing }
PurchaseTask >> variation [

	^ variation ifNil: [ variation := Variation withId: self variationId ]
]

{ #category : #accessing }
PurchaseTask >> variationId [

	^ variationId
]

{ #category : #accessing }
PurchaseTask >> variationId: anObject [

	variationId := anObject
]

{ #category : #printing }
PurchaseTask >> visitsLinesString [

	" Format agreed on Dec 19 "

	^ String streamContents: [ :stream | 
		  self pageVisits do: [ :visit | 
			  stream
				  nextPutAll: self prolificId;
				  nextPutAll: ',';
				  nextPutAll: visit startTime asString;
				  nextPutAll: ',';
				  nextPutAll: self variationId;
				  nextPutAll: ',';
				  nextPutAll: self variation iterations printString;
				  nextPutAll: ','.
			  visit printLineOn: stream.
			  stream cr ] ]
]

{ #category : #testing }
PurchaseTask >> wrongMovieCount [

	^ self movieSelections collapseRuns count: [ :movieId | 
		  movieId ~= self variation movie ]
]

{ #category : #testing }
PurchaseTask >> wrongSelections [

	| wrongMovieCount wrongTimeCount |
	wrongMovieCount := self wrongMovieCount.
	wrongTimeCount := self wrongTimeCount.
	^ wrongMovieCount + wrongTimeCount
]

{ #category : #testing }
PurchaseTask >> wrongTimeCount [

	^ self timeSelections collapseRuns count: [ :time | 
		  time ~= self variation time ]
]
