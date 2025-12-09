Class {
	#name : #BigIScriptsRunner,
	#superclass : #Object,
	#instVars : [
		'variations',
		'tasks'
	],
	#classVars : [
		'Instance'
	],
	#category : #BigI
}

{ #category : #accessing }
BigIScriptsRunner class >> instance [

	^ Instance ifNil: [ Instance := super new ]
]

{ #category : #accessing }
BigIScriptsRunner class >> new [

	^ self error:
		  'Yeah, don''t do that with a singleton. Better #resetInstance.'
]

{ #category : #accessing }
BigIScriptsRunner class >> resetInstance [

	Instance := nil
]

{ #category : #accessing }
BigIScriptsRunner >> allPurchases [

	^ (self directory , 'experiments/') asFileReference files collect: [ 
		  :fileReference | 
		  PurchaseTask fromJSON:
			  (NeoJSONReader fromString: fileReference contents) ]
]

{ #category : #accessing }
BigIScriptsRunner >> allVisits [

	^ (self tasks flatCollect: #pageVisits) reject: #isBuggy
]

{ #category : #accessing }
BigIScriptsRunner >> directory [

	^ '/Users/juliangrigera/Desktop/Big-I/'
]

{ #category : #intializing }
BigIScriptsRunner >> exclusionCriteria [

	^ [ :task | task totalTime > 15 minutes ]
]

{ #category : #intializing }
BigIScriptsRunner >> initialize [

	| allTasks |
	allTasks := (self directory , 'experiments/') asFileReference files 
		            collect: [ :fileReference | 
			            PurchaseTask fromJSON:
				            (NeoJSONReader fromString: fileReference contents) ].
	tasks := allTasks reject: self exclusionCriteria.
	variations := Variation all
]

{ #category : #'as yet unclassified' }
BigIScriptsRunner >> populateVisitsVariationRule [

	self tasks do: #populateVisitsVariationRule
]

{ #category : #accessing }
BigIScriptsRunner >> tasks [

	^ tasks
]

{ #category : #accessing }
BigIScriptsRunner >> tasks: anObject [

	tasks := anObject
]

{ #category : #accessing }
BigIScriptsRunner >> v1tasks [

	^ self tasks select: [ :task | task variation version = 'v1' ]
]

{ #category : #accessing }
BigIScriptsRunner >> variations [

	^ variations
]

{ #category : #accessing }
BigIScriptsRunner >> variations: anObject [

	variations := anObject
]

{ #category : #accessing }
BigIScriptsRunner >> writeAttemptsSummariesOn: filename [

	"Format agreed on Oct 10"

	(self directory , filename) asFileReference writeStreamDo: [ :stream | 
		#( prolific_id variationId attempt_number iterations type smallLoops
		   smallLoopsTimeSecs toRight toWrong correctionsTime
		   timeSecs interactionStepsCount trace )
			do: [ :header | stream << header ]
			separatedBy: [ stream << ',' ].
		stream cr.
		self v1tasks do: [ :task | stream << task attemptsLinesString ] ]
]

{ #category : #accessing }
BigIScriptsRunner >> writeCorrectionsPerAttemptOn: filename [

	(self directory , filename) asFileReference writeStreamDo: [ :stream | 
		#( prolific_id variationId attempt_number wrong_to_right
		   right_to_wrong wrong_to_wrong right_to_right all_corrections
		   errors visited_pages added_time_seconds large_loops large_loops_time)
			do: [ :header | stream << header ]
			separatedBy: [ stream << ',' ].
		stream cr.
		self tasks
			select: [ :task | task variation version = 'v1' ]
			thenDo: [ :task | stream << task attemptslinesString ] ]
]

{ #category : #accessing }
BigIScriptsRunner >> writeDataOn: filename [

	(self directory , filename) asFileReference writeStreamDo: [ :stream | 
		#( Participant_Id Variation_Id Version Attempts Total_Time
		   Corrections Errors )
			do: [ :header | stream << header ]
			separatedBy: [ stream << ',' ].
		stream cr.
		self tasks do: [ :task | 
			stream << task prolificId.
			stream << ','.
			stream << task variation id.
			stream << ','.
			stream << task variation version. "V1 or V2"
			stream << ','.
			stream << task variation iterations printString.
			stream << ','.
			stream << task completionTime printString.
			stream << ','.
			stream << task correctionsCount printString.
			stream << ','.
			stream << task errorsCount printString.
			stream cr ] ]
]

{ #category : #accessing }
BigIScriptsRunner >> writeIdsAndTimesOn: filename [

	| byId |
	byId := self tasks groupedBy: #prolificId.
	(self directory , filename) asFileReference writeStreamDo: [ :stream | 
		byId keysAndValuesDo: [ :prolificId :userTasks | 
			| totalDuration |
			totalDuration := userTasks
				                 inject: Duration zero
				                 into: [ :duration :task | 
				                 duration + task completionTime ].
			stream << prolificId.
			stream << ','.
			stream << totalDuration printString.
			stream cr ] ]
]

{ #category : #accessing }
BigIScriptsRunner >> writeSummarizedDataOn: filename [

	| byId |
	byId := self tasks groupedBy: #prolificId.
	(self directory , filename) asFileReference writeStreamDo: [ :stream | 
		byId keysAndValuesDo: [ :prolificId :userTasks | 
			| totalDuration |
			totalDuration := userTasks
				                 inject: Duration zero
				                 into: [ :duration :task | 
				                 duration + task completionTime ].
			stream << prolificId.
			stream << ','.
			stream << totalDuration printString.
			stream cr ] ]
]

{ #category : #accessing }
BigIScriptsRunner >> writeTasksSummariesOn: filename [

	"Format agreed on Sep 17"

	(self directory , filename) asFileReference writeStreamDo: [ :stream | 
		#( prolific_id variationId iterations type smallLoops smallLoopsTime smallLoopsTimeSecs largeLoops largeLoopsTime largeLoopsTimeSecs toRight toWrong time timeSecs trace)
			do: [ :header | stream << header ]
			separatedBy: [ stream << ',' ].
		stream cr.
		self tasks
			select: [ :task | task variation version = 'v1' ]
			thenDo: [ :task | stream << task lineString ] ]
]

{ #category : #accessing }
BigIScriptsRunner >> writeVisitsOn: filename [

	"Format agreed on Oct 31"

	(self directory , filename) asFileReference writeStreamDo: [ :stream | 
		#( visit_id steps_count corrections_count elements_count totalTime)
			do: [ :header | stream << header ]
			separatedBy: [ stream << ',' ].
		stream cr.
		self allVisits
			select: [ :visit | visit variation version = 'v1' ]
			thenDo: [ :visit | stream << visit lineString ] ]
]
