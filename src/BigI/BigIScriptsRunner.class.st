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

	^ Instance ifNil: [ Instance := self new ]
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
BigIScriptsRunner >> directory [

	^ '/Users/juliangrigera/Desktop/Big-I/'
]

{ #category : #intializing }
BigIScriptsRunner >> initialize [

	tasks := (self directory , 'experiments/') asFileReference files 
		         collect: [ :fileReference | 
			         PurchaseTask fromJSON:
				         (NeoJSONReader fromString: fileReference contents) ].

	variations := Variation all
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
BigIScriptsRunner >> variations [

	^ variations
]

{ #category : #accessing }
BigIScriptsRunner >> variations: anObject [

	variations := anObject
]

{ #category : #accessing }
BigIScriptsRunner >> writeCorrectionsPerAttemptOn: filename [

	(self directory , filename) asFileReference writeStreamDo: [ :stream | 
		#( prolific_id variationId attempt_number wrong_to_right
		   right_to_wrong wrong_to_wrong right_to_right all_corrections
		   errors visited_pages added_time_seconds large_loops)
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
