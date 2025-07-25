Extension { #name : #SequenceableCollection }

{ #category : #'*BigI' }
SequenceableCollection >> collapseRuns [

	"Returns a new collection with consecutive duplicate elements removed."

	| result |
	result := OrderedCollection new.

	self doWithIndex: [ :each :index | 
		(index = 1 or: [ each ~= (self at: index - 1) ]) ifTrue: [ 
			result add: each ] ].

	^ result as: self class
]
