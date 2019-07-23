Class {
	#name : #ExternalBrowserTest2,
	#superclass : #TestCase,
	#instVars : [
		'initialWindows',
		'file'
	],
	#category : #'Migration-Tool-ExternalBrowser'
}

{ #category : #running }
ExternalBrowserTest2 >> assert: serviceProvider dropFileWithSuffix: suffix [
	| allMatchingServices service |
	allMatchingServices := serviceProvider fileReaderServicesForFile: file pathString suffix: suffix.
	self deny: allMatchingServices isEmpty.
	service := allMatchingServices anyOne.
	self shouldnt: [service performServiceFor: file] raise: MessageNotUnderstood.

]

{ #category : #running }
ExternalBrowserTest2 >> classNameForTest [
	^#MyWonderfulClass
]

{ #category : #running }
ExternalBrowserTest2 >> fileForTestContent [
	^'''From Pharo7.0.0rc1 of 4 December 2018 [Build information: Pharo-7.0.0+rc1.build.1435.sha.4cd23cf7be1a90c7c52e9f8786860a6290b7c2a6 (64 Bit)] on 5 December 2018 at 9:30:34.922838 am''!
Object subclass: #', self classNameForTest,'
	instanceVariableNames: ''some iv''
	classVariableNames: ''''
	poolDictionaries: ''''
	category: #MyCategory!
!', self classNameForTest,' commentStamp: ''NouryBouraqadi 12/4/2018 17:19'' prior: 0!
My unique and explicit comment!


!', self classNameForTest,' methodsFor: ''protocol'' stamp: ''NouryBouraqadi 12/4/2018 17:12''!
myMethod
	! !
'
]

{ #category : #running }
ExternalBrowserTest2 >> fileNameForTest [
	^ 'fileForExternalBrowserTest'
]

{ #category : #running }
ExternalBrowserTest2 >> initFileWithSuffix: suffix [
	file := FileSystem workingDirectory / self fileNameForTest, '.', suffix.
	file
		writeStreamDo: [ :stream | stream nextPutAll: self fileForTestContent ].
	initialWindows := self currentWorld windowsSatisfying: [: each| true ].
]

{ #category : #running }
ExternalBrowserTest2 >> setUp [
	super setUp.
	initialWindows := self currentWorld windowsSatisfying: [: each| true ].
]

{ #category : #running }
ExternalBrowserTest2 >> tearDown [ 
	| newWindows |
	file deleteIfAbsent: [ ].
	self class environment at: self classNameForTest  ifPresent: [ : cl | cl removeFromSystem ].
	newWindows := self currentWorld windowsSatisfying: [ : each | (initialWindows includes: each) not ].
	newWindows do: #delete.
	super tearDown.
]

{ #category : #running }
ExternalBrowserTest2 >> testDropChangeFile [
	self initFileWithSuffix: 'changes'.
	self assert: ExternalChangesBrowser dropFileWithSuffix: 'changes'

]

{ #category : #running }
ExternalBrowserTest2 >> testDropStFile [
	self initFileWithSuffix: 'st'.
	self assert: ExternalBrowser dropFileWithSuffix: 'st'

]
