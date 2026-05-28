Class {
	#name : #FlightPageVisit,
	#superclass : #PageVisit,
	#category : #BigI
}

{ #category : #'instance creation' }
FlightPageVisit class >> fromJSON: aJSON [

	| newVisit |
	newVisit := self new.
	newVisit stepName: (aJSON at: #page).
	newVisit clicks: ((aJSON at: #clicks) collect: [ :clickJSON | 
			 ClickEvent fromJSON: clickJSON ]).
	newVisit startTime: (aJSON at: #visitStartTime) asDateAndTime .
	newVisit endTime: (aJSON at: #visitEndTime) asDateAndTime.
	^ newVisit
]

{ #category : #accessing }
FlightPageVisit >> totalTime [

	^ self endTime - self startTime
]
