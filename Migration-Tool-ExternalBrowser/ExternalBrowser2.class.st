Class {
	#name : #ExternalBrowser2,
	#superclass : #SpPresenter,
	#instVars : [
		'navigationSystem',
		'noteBook',
		'model',
		'commentNoteBookPage',
		'classDescriptionNoteBookPage',
		'methodViewerNoteBookPage'
	],
	#category : #'Migration-Tool-ExternalBrowser'
}

{ #category : #'public access' }
ExternalBrowser2 class >> browseStream: aStream [

	^ self openOn: (RingChunkImporter fromStream: aStream)
]

{ #category : #specs }
ExternalBrowser2 class >> defaultSpec [
	^ SpPanedLayout newVertical
		add: #navigationSystem;
		add: #noteBook;
		yourself
]

{ #category : #examples }
ExternalBrowser2 class >> example [
	<example>

	self openOn: Smalltalk image
]

{ #category : #'System-FileRegistry' }
ExternalBrowser2 class >> fileReaderServicesForFile: fullName suffix: suffix [
	<fileService>

	^ (self sourceFileSuffixes includes: suffix)
		ifTrue: [ Array with: self serviceBrowseCode]
		ifFalse: [ #() ]
]

{ #category : #'instance creation' }
ExternalBrowser2 class >> openOn: model [
	| externalBrowser |
	externalBrowser := self new.
	externalBrowser
		model: model;
		openWithSpec.
	^ externalBrowser
]

{ #category : #'System-FileRegistry' }
ExternalBrowser2 class >> serviceBrowseCode [
	"Answer the service of opening a file-contents browser"

	^ (SimpleServiceEntry
		provider: self 
		label: 'Code-file browser'
		selector: #browseStream:
		description: 'Open a "file-contents browser" on this file, allowing you to view and selectively load its code'
		buttonLabel: 'Code')
		argumentGetter: [ :file| file readStream]
]

{ #category : #'System-FileRegistry' }
ExternalBrowser2 class >> services [
	"Answer potential file services associated with this class"

	^ {self serviceBrowseCode}.
]

{ #category : #'System-FileRegistry' }
ExternalBrowser2 class >> sourceFileSuffixes [

	^#('st' 'cs')


]

{ #category : #accessing }
ExternalBrowser2 >> classDescriptionNoteBookPage [
	^ classDescriptionNoteBookPage
]

{ #category : #accessing }
ExternalBrowser2 >> commentNoteBookPage [
	^ commentNoteBookPage
]

{ #category : #initialization }
ExternalBrowser2 >> initializePresenter [
	navigationSystem classList
		transmitTo: commentNoteBookPage
		transform: [ :selectedClass | 
			selectedClass
				ifNotNil: [ :selectClass | 
					selectClass comment
						ifNil: [ 'there is no comment in this class' ]
						ifNotNil: [ :comment | comment ] ] ].
	navigationSystem classList
		transmitTo: classDescriptionNoteBookPage
		transform:
			[ :selectedClass | selectedClass ifNotNil: [ :selectClass |selectClass  definition ] ]
		postTransmission: [ noteBook selectedPageIndex: 2 ].
	navigationSystem methodList
		transmitTo: methodViewerNoteBookPage
		transform:
			[ :selectedMethod | selectedMethod ifNotNil: [ :selectMethod | selectMethod sourceCode ] ]
		postTransmission: [ noteBook selectPageIndex: 3 ]
]

{ #category : #initialize }
ExternalBrowser2 >> initializeWidgets [
	navigationSystem := self instantiate: SpChooseMethodUI .
	noteBook := self newNotebook.
	commentNoteBookPage := self newText.
	classDescriptionNoteBookPage := self newCode.
	methodViewerNoteBookPage := self newCode.
	
	noteBook
		addPage: (SpNotebookPage title: 'Comment' provider: [ commentNoteBookPage ]);
		addPage:
			(SpNotebookPage
				title: 'Class description'
				provider: [ classDescriptionNoteBookPage ]);
		addPage:
			(SpNotebookPage
				title: 'Method viewer'
				provider: [ methodViewerNoteBookPage ]).
				
	self focusOrder
		add: navigationSystem;
		add: noteBook
]

{ #category : #initialize }
ExternalBrowser2 >> initializeWindow: aWindow [
	aWindow
		extent: 800 @ 800;
		title: 'External Package Browser'
]

{ #category : #accessing }
ExternalBrowser2 >> methodViewerNoteBookPage [
	^ methodViewerNoteBookPage
]

{ #category : #accessing }
ExternalBrowser2 >> model [
	^ model
]

{ #category : #accessing }
ExternalBrowser2 >> model: aModel [
	model := aModel.
	navigationSystem packageList
		items: model packages asOrderedCollection.
	navigationSystem packageList selectIndex: 1.
	noteBook selectedPageIndex: 2
]

{ #category : #accessing }
ExternalBrowser2 >> navigationSystem [
	^ navigationSystem
]

{ #category : #accessing }
ExternalBrowser2 >> noteBook [
	^ noteBook
]
