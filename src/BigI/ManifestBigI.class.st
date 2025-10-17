"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestBigI,
	#superclass : #PackageManifest,
	#category : #'BigI-Manifest'
}

{ #category : #'code-critics' }
ManifestBigI class >> ruleBooleanPrecedenceRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#Variation #outcomeAchievedForRun: #false)) #'2025-10-17T08:49:17.275709-03:00') )
]

{ #category : #'code-critics' }
ManifestBigI class >> ruleGuardingClauseRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#PageVisit #printTraceOn: #false)) #'2025-09-16T14:09:40.554102-03:00') )
]

{ #category : #'code-critics' }
ManifestBigI class >> ruleReGuardClauseRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#PageVisit #printTraceOn: #false)) #'2025-09-16T14:09:44.85245-03:00') )
]
