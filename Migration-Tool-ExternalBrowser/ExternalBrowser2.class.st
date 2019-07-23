Class {
	#name : #ExternalBrowser2,
	#superclass : #ComposablePresenter,
	#instVars : [
		'classes',
		'packages',
		'protocols',
		'selectors',
		'method',
		'showClassSide',
		'model'
	],
	#category : #'Migration-Tool-ExternalBrowser'
}

{ #category : #'public access' }
ExternalBrowser2 class >> browseStream: aStream [

	self openOn: (RingChunkImporter fromStream: aStream)
]

{ #category : #specs }
ExternalBrowser2 class >> defaultSpec [
	<spec: #default>
	
	^ SpecLayout composed 
		newColumn: [ :col | 
			col newRow: [ :row | 
					row newColumn: [ :subcolumn |
						subcolumn add: #packages.
						subcolumn add: #showClassSide height: 16  ].
					row 
						add: #classes;
						add: #protocols;
						add: #selectors ] ;
			newRow: [ :row | 
					row add: #method ]]; 
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

	self basicNew
		model: model;
		initialize;
		openWithSpec
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
ExternalBrowser2 >> classes [

	^ classes
]

{ #category : #'structure accessing' }
ExternalBrowser2 >> classesOfPackage: aPackage [
	| theClasses |
	theClasses := aPackage classes.
	^ self showClassSide state
		ifTrue: [ theClasses collect: #classSide ]
		ifFalse: [ theClasses ]
]

{ #category : #initialize }
ExternalBrowser2 >> initialExtent [

	^ 800@600
]

{ #category : #initialize }
ExternalBrowser2 >> initializeClassList [
	classes := self newList
]

{ #category : #initialize }
ExternalBrowser2 >> initializeMethodBodyPane [
	method := self newCode
]

{ #category : #initialize }
ExternalBrowser2 >> initializePackageList [
	packages := self newList.
	self populatePackages.
	packages displayBlock: [ :m | m name ]
]

{ #category : #initialize }
ExternalBrowser2 >> initializePresenter [
	self wirePackages.
	self wireClasses.
	self wireProtocols.
	self wireSelectors.
	
	showClassSide 
		whenChangedDo: [ self refreshClasses: self packages selectedItem ].
]

{ #category : #initialize }
ExternalBrowser2 >> initializeProtocolList [
	protocols := self newList
]

{ #category : #initialize }
ExternalBrowser2 >> initializeSelectorList [

	selectors := self newList.
	
]

{ #category : #initialize }
ExternalBrowser2 >> initializeWidgets [
	self initializePackageList.
	self initializeClassList.
	self initializeProtocolList.
	self initializeSelectorList.
	self initializeMethodBodyPane.
	
	showClassSide := self newCheckBox.
	showClassSide label: 'Class side'.
	showClassSide state: false.
	
	self focusOrder
		add: packages;
		add: classes;
		add: protocols;
		add: selectors;
		add: method
]

{ #category : #accessing }
ExternalBrowser2 >> method [
	^ method
]

{ #category : #accessing }
ExternalBrowser2 >> method: anObject [
	method := anObject
]

{ #category : #'structure accessing' }
ExternalBrowser2 >> methodFor: aSelector [

	^ (self classes selectedItem methodNamed: aSelector) sourceCode
			
]

{ #category : #accessing }
ExternalBrowser2 >> model: aModel [

	model := aModel
]

{ #category : #accessing }
ExternalBrowser2 >> packages [

	^ packages
]

{ #category : #'selection operation' }
ExternalBrowser2 >> populatePackages [

	packages items: model packages.
]

{ #category : #accessing }
ExternalBrowser2 >> protocols [

	^ protocols
]

{ #category : #'structure accessing' }
ExternalBrowser2 >> protocolsOfClass: aClass [

	^ aClass protocols
]

{ #category : #initialize }
ExternalBrowser2 >> refreshClasses: pack [
	self resetClassSelection.
	pack 
		ifNil: [ classes items: #() ] 
		ifNotNil: [ classes items: (self classesOfPackage: pack)]. 

]

{ #category : #'selection operation' }
ExternalBrowser2 >> resetClassSelection [

	self classes resetSelection
]

{ #category : #'selection operation' }
ExternalBrowser2 >> resetMethodBodyPane [
	self method text: ''
	
]

{ #category : #'selection operation' }
ExternalBrowser2 >> resetProtocolSelection [

	self protocols resetSelection
]

{ #category : #'selection operation' }
ExternalBrowser2 >> resetSelectorSelection [

	self selectors resetSelection
]

{ #category : #accessing }
ExternalBrowser2 >> selectors [
	^ selectors
]

{ #category : #accessing }
ExternalBrowser2 >> selectors: anObject [
	selectors := anObject
]

{ #category : #'structure accessing' }
ExternalBrowser2 >> selectorsOfProtocol: aProtocol [ 
	
	| theSelectedClass |
	theSelectedClass := self showClassSide state
		ifFalse: [ self classes selectedItem ]
		ifTrue: [ self classes selectedItem classSide ].
	^ (theSelectedClass 
		methodsInProtocol: self protocols selectedItem) collect: #selector
]

{ #category : #'structure accessing' }
ExternalBrowser2 >> showClassDefinition [
	method text: (self classes selectedItem definition  ifNil:[''])
]

{ #category : #accessing }
ExternalBrowser2 >> showClassSide [

	^ showClassSide
]

{ #category : #accessing }
ExternalBrowser2 >> title [ 
	^ 'External Package Browser'
]

{ #category : #initialize }
ExternalBrowser2 >> wireClasses [
	classes
		whenSelectedItemChanged: [ :class | 
			self resetProtocolSelection.
			class 
				ifNil: [ protocols items: #() ] 
				ifNotNil: [ protocols items: (self protocolsOfClass: class).
					         self showClassDefinition ] ]
]

{ #category : #initialize }
ExternalBrowser2 >> wirePackages [
	packages whenSelectedItemChanged: [ :pack | 
		self refreshClasses: pack ].


	
]

{ #category : #initialize }
ExternalBrowser2 >> wireProtocols [
	protocols
		whenSelectedItemChanged: [ :protocol | 
			self resetSelectorSelection.
			protocol 
				ifNil: [ selectors items: #() ] 
				ifNotNil: [ selectors items: (self selectorsOfProtocol: protocol) ] ]
]

{ #category : #initialize }
ExternalBrowser2 >> wireSelectors [
	selectors
		whenSelectedItemChanged: [ :selector | 
			selector 
				ifNil: [ self resetMethodBodyPane ] 
				ifNotNil: [ method text:  (self methodFor: selector) ]]
]
