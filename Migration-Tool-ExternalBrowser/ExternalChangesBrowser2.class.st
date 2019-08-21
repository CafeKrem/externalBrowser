Class {
	#name : #ExternalChangesBrowser2,
	#superclass : #ComposablePresenter,
	#instVars : [
		'changes',
		'codePane',
		'changeSet',
		'selectAllButton',
		'deselectAllButton',
		'fileInSelectedButton'
	],
	#category : #'Migration-Tool-ExternalBrowser'
}

{ #category : #examples }
ExternalChangesBrowser2 class >> browseRecentLog [
	<example>
	
	^ self openOnStream: SourceFiles changesFileStream
]

{ #category : #specs }
ExternalChangesBrowser2 class >> defaultSpec [
	<spec: #default>
	
	^ SpecLayout composed 
		newColumn: [ :col | 
			col
				add: #changes;
				newRow: [ :row | 
					row
						add: #selectAllButton;
						add: #deselectAllButton;
						add: #fileInSelectedButton ] height: 32;
				add: #codePane ]; 
		yourself
]

{ #category : #examples }
ExternalChangesBrowser2 class >> example1 [
	<example>
	
	self new openWithSpec

]

{ #category : #examples }
ExternalChangesBrowser2 class >> example2 [
	<example>
	
	self openOn: Smalltalk changesFile fullName
]

{ #category : #'file service' }
ExternalChangesBrowser2 class >> fileReaderServicesForFile: fullName suffix: suffix [
	<fileService>
	| services |
	services := OrderedCollection new.
	(FileStream isSourceFileSuffix: suffix) | 
	(FileStream isChangesFileSuffix: suffix) | (suffix = '*')
		ifTrue: [ services add: self serviceBrowseCSOrSTFile ].
	^services
]

{ #category : #'instance creation' }
ExternalChangesBrowser2 class >> openOn: changeSetName [

	self new
		changeSetName: changeSetName;
		openWithSpec
]

{ #category : #'instance creation' }
ExternalChangesBrowser2 class >> openOnFileName: aFileName [

	self new
		changeSetName: aFileName;
		openWithSpec
]

{ #category : #'instance creation' }
ExternalChangesBrowser2 class >> openOnStream: aStream [

	| widget |
	widget := self new.
	widget changes items: (CodeImporter chunksFromStream: aStream).
	widget openWithSpec	
]

{ #category : #'tool registry' }
ExternalChangesBrowser2 class >> registerToolsOn: registry [

	registry register: self as: #changeList 
]

{ #category : #'file service' }
ExternalChangesBrowser2 class >> serviceBrowseCSOrSTFile [
	"Answer a service for opening a changelist browser on a file"

	^ (SimpleServiceEntry 
		provider: self 
		label: 'Changelist browser'
		selector: #openOnStream:
		description: 'Open a changelist tool on this file'
		buttonLabel: 'Changes')
		argumentGetter: [ :stream | stream readStream ]
]

{ #category : #'file service' }
ExternalChangesBrowser2 class >> services [
	"Answer potential file services associated with this class"

	^ { self serviceBrowseCSOrSTFile }
]

{ #category : #icons }
ExternalChangesBrowser2 class >> taskbarIconName [
	"Answer the icon for the receiver in a task bar."

	^#smallSaveIcon
]

{ #category : #menu }
ExternalChangesBrowser2 >> buildMenu: aMenu [

	aMenu
		add: 'File in all selected'
		target: self
		selector: #fileIn:
		argumentList: { changes selectedItems }.
	
	aMenu
		addToggle: 'Compare method to current'
		target: self
		selector: #compareToCurrent:
		getStateSelector:nil
		enablementSelector: #canCompareToCurrent
		argumentList: { changes selectedItem }.

	^ aMenu
]

{ #category : #menu }
ExternalChangesBrowser2 >> canCompareToCurrent [

	| aMethodDeclaration |
	(changes selectedItems size = 1) ifFalse: [ ^ false ].
	((aMethodDeclaration := changes selectedItem) isMethodDeclaration) ifFalse: [  ^ false ].
	
	( aMethodDeclaration existsBehavior) ifFalse: [ ^ false ].
	^ aMethodDeclaration targetClass includesSelector: aMethodDeclaration methodSelector
	
]

{ #category : #initialization }
ExternalChangesBrowser2 >> changeDescription: change [

	^ change description
]

{ #category : #initialization }
ExternalChangesBrowser2 >> changeSetName: aFileName [

	changeSet := CodeImporter fileNamed: aFileName.
	changeSet parseChunks.
	changes items: changeSet codeDeclarations.
]

{ #category : #accessing }
ExternalChangesBrowser2 >> changes [

	^ changes
]

{ #category : #accessing }
ExternalChangesBrowser2 >> codePane [

	^ codePane
]

{ #category : #menu }
ExternalChangesBrowser2 >> compareToCurrent: aMethodDeclaration [

	| class sourceString |
	class := aMethodDeclaration targetClass.
	sourceString := (class >> aMethodDeclaration methodSelector) sourceCode.
	UIManager default
		openComparisonFrom: aMethodDeclaration contents
		to: sourceString
		belongingTo: class
		from: aMethodDeclaration
		labeled: 'Current'
		inWindowLabeled: 'Comparison to Current Version'
]

{ #category : #accessing }
ExternalChangesBrowser2 >> deselectAllButton [

	^ deselectAllButton
]

{ #category : #menu }
ExternalChangesBrowser2 >> fileIn: aCodeDeclaration [

	aCodeDeclaration do: #import.
]

{ #category : #accessing }
ExternalChangesBrowser2 >> fileInSelectedButton [

	^ fileInSelectedButton
]

{ #category : #initialization }
ExternalChangesBrowser2 >> initialExtent [

	^ 500@600
]

{ #category : #initialization }
ExternalChangesBrowser2 >> initializePresenter [
	changes
		whenSelectionChangedDo: [ :selection | 
			[ :change | change ifNotNil: [ codePane text: change contents ] ]
				cull: selection selectedItem ].
	changes menu: [ :menu :shifted | self buildMenu: menu ].
	selectAllButton action: [ changes selectAll ].
	deselectAllButton action: [ changes unselectAll ].
	fileInSelectedButton
		action: [ self fileIn: changes selectedItemsSorted ]
]

{ #category : #initialization }
ExternalChangesBrowser2 >> initializeWidgets [

	self title: 'Changes Browser'.

	changes := self newList.
	changes displayBlock: [ :elem | self changeDescription: elem ].
	changes beMultipleSelection.

	selectAllButton := self newButton.
	selectAllButton
		label: 'select all'.

	deselectAllButton := self newButton.
	deselectAllButton
		label: 'deselect all'.
		
	fileInSelectedButton := self newButton.
	fileInSelectedButton
		label: 'file in selected'.

	codePane := self newCode.
]

{ #category : #accessing }
ExternalChangesBrowser2 >> selectAllButton [

	^ selectAllButton
]
