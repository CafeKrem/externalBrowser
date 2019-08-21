Class {
	#name : #ExternalBrowserUITest,
	#superclass : #TestCase,
	#instVars : [
		'externalBrowser'
	],
	#category : #'Migration-Tool-ExternalBrowser'
}

{ #category : #running }
ExternalBrowserUITest >> setUp [
	| internalStream |
	internalStream := (String new: 1000) writeStream.
	SystemOrganization 
		fileOutCategory: self class package name
		on: internalStream.
	externalBrowser :=  ExternalBrowser2 browseStream: internalStream contents readStream.
]

{ #category : #running }
ExternalBrowserUITest >> tearDown [ 
	externalBrowser application close
]

{ #category : #tests }
ExternalBrowserUITest >> testWhenClassSelectedShouldChangeClassDescription [
	"this test fail because the ringModel is broken"
	externalBrowser navigationSystem classList
		selectIndex:
			((externalBrowser navigationSystem classList items collect: #name)
				indexOf: TestedClassWithMethod name).
	self
		assert: externalBrowser classDescriptionNoteBookPage text 
		equals: TestedClassWithMethod definition 
]

{ #category : #tests }
ExternalBrowserUITest >> testWhenSelectingAClassWithoutMethodsShouldSuceed [
	externalBrowser navigationSystem classList selectItem:  TestedClassEmptyMethod.
	self deny: externalBrowser navigationSystem methodList items isNil.
	self assert: externalBrowser navigationSystem methodList items isEmpty
]
