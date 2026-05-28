Class {
	#name : #FlightPurchaseTask,
	#superclass : #PurchaseTask,
	#category : #BigI
}

{ #category : #'instance creation' }
FlightPurchaseTask class >> fromJSON: aJSON [


	^ self new
		  prolificId: (aJSON at: #participantId);
		  variationId: (aJSON at: #experimentId);
		  pageVisits: ((aJSON at: #pages) collect: [ :visitJSON | 
					   FlightPageVisit fromJSON: visitJSON ]);
		  dateAndTime:
			  (DateAndTime fromString: (aJSON at: #experimentStartTime));
		  endTime:
			  (DateAndTime fromString: (aJSON at: #experimentEndTime));
		  yourself
]

{ #category : #accessing }
FlightPurchaseTask >> pageVisits: anObject [

	pageVisits := anObject.
	pageVisits do: [ :visit | visit variation: self variationId ]
]

{ #category : #printing }
FlightPurchaseTask >> visitsLinesString [

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
