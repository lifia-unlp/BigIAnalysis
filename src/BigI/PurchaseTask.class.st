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
PurchaseTask >> attemptslinesString [

	^ String streamContents: [ :stream | 
		  self attempts withIndexDo: [ :attempt :n | 
			  | corrections |
			  corrections := attempt intraVisitCorrections.
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
			  stream cr ] ]
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
PurchaseTask >> fullTime [

	^ self endTime - self dateAndTime
]

{ #category : #testing }
PurchaseTask >> hasErrors [

	^ self wrongSelections > 0
]

{ #category : #accessing }
PurchaseTask >> interVisitCorrections [

	^ self lastSelections
		  groupedBy: #trackIdPrefix
		  having: [ :events | (events collect: #trackId) asSet size > 1 ]
]

{ #category : #accessing }
PurchaseTask >> interactionRuns [

	| areSeats seatVisits runsToSeat completeRuns |
	areSeats := [ :visit | visit stepName beginsWith: '/seat' ].
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

{ #category : #accessing }
PurchaseTask >> intraVisitCorrections [

	^ self pageVisits flatCollect: #corrections
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
		  self pageVisits do: [ :visit | 
			  stream << (visit stepName copyUpToSubstring: '?') allButFirst.
			  stream nextPut: $,.
			  visit clicks do: [ :click | 
				  click element printOn: stream.
				  stream nextPut: $,.
				  click trackId printOn: stream.
				  stream nextPut: $,.
				  click dateAndTime printOn: stream.
				  stream nextPut: $,].
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

{ #category : #accessing }
PurchaseTask >> prolificId [

	^ prolificId
]

{ #category : #accessing }
PurchaseTask >> prolificId: anObject [

	prolificId := anObject
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
