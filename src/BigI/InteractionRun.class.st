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
